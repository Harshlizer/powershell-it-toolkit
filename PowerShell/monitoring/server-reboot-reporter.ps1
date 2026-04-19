$tenantId = "<TENANT_ID>"
$clientId = "<CLIENT_ID>"
$clientSecret = "<CLIENT_SECRET>"
$fromAddress = "<FROM_EMAIL>"
$csvPath = "\\<FILESERVER>\<SHARE>\server-reboots.csv"

$recipients = @(
    @{ emailAddress = @{ address = "<RECIPIENT_EMAIL_1>" } },
    @{ emailAddress = @{ address = "<RECIPIENT_EMAIL_2>" } }
)

$serverName = $env:COMPUTERNAME
$now = Get-Date

$shutdown = Get-WinEvent -FilterHashtable @{ LogName = 'System'; ID = 6006 } -MaxEvents 1 | Select-Object -ExpandProperty TimeCreated
$startup = Get-WinEvent -FilterHashtable @{ LogName = 'System'; ID = 6005 } -MaxEvents 1 | Select-Object -ExpandProperty TimeCreated

$event1074 = Get-WinEvent -FilterHashtable @{ LogName = 'System'; ID = 1074 } -MaxEvents 1
$user = $null
$reason = $null
if ($event1074) {
    $user = ($event1074.Properties[6].Value) -replace '^.*\\'
    $reason = $event1074.Properties[4].Value
}

$htmlBody = @"
<html>
<body>
<h2>Server reboot report [$serverName]</h2>
<table>
  <tr><th>Server</th><td>$serverName</td></tr>
  <tr><th>Shutdown</th><td>$shutdown</td></tr>
  <tr><th>Startup</th><td>$startup</td></tr>
  <tr><th>Initiator</th><td>$user</td></tr>
  <tr><th>Reason</th><td>$reason</td></tr>
  <tr><th>Generated</th><td>$now</td></tr>
</table>
</body>
</html>
"@

$mailPayload = @{
    message = @{
        subject = "[$serverName] Reboot report"
        body = @{
            contentType = "HTML"
            content = $htmlBody
        }
        toRecipients = $recipients
        from = @{
            emailAddress = @{ address = $fromAddress }
        }
    }
    saveToSentItems = "false"
}

$tokenResponse = Invoke-RestMethod -Method POST -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Body @{
    client_id = $clientId
    scope = "https://graph.microsoft.com/.default"
    client_secret = $clientSecret
    grant_type = "client_credentials"
}
$accessToken = $tokenResponse.access_token

$jsonBytes = [System.Text.Encoding]::UTF8.GetBytes(($mailPayload | ConvertTo-Json -Depth 10 -Compress))
$stream = New-Object System.IO.MemoryStream (,$jsonBytes)

Invoke-RestMethod -Method POST `
    -Uri "https://graph.microsoft.com/v1.0/users/$fromAddress/sendMail" `
    -Headers @{ Authorization = "Bearer $accessToken" } `
    -Body $stream `
    -ContentType "application/json; charset=utf-8"

$logEntry = [PSCustomObject]@{
    ServerName    = $serverName
    ShutdownTime  = $shutdown
    StartupTime   = $startup
    Initiator     = $user
    Reason        = $reason
    ReportTimeUTC = $now.ToUniversalTime()
}

if (!(Test-Path $csvPath)) {
    $logEntry | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
}
else {
    $logEntry | Export-Csv -Path $csvPath -NoTypeInformation -Append -Encoding UTF8
}
