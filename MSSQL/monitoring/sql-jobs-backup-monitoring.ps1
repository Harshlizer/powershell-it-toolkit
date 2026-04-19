# Configuration
$SqlUser = "<SQL_MONITOR_USER>"
$SqlPass = "<SQL_MONITOR_PASSWORD>"

$TenantId = "<TENANT_ID>"
$ClientId = "<CLIENT_ID>"
$ClientSecret = "<CLIENT_SECRET>"

$SenderEmail = "<SENDER_EMAIL>"
$Recipients = @("<RECIPIENT_EMAIL_1>", "<RECIPIENT_EMAIL_2>")
$Subject = "SQL Backup Report for $(Get-Date -Format 'yyyy-MM-dd')"

$ServerGroups = @(
    @{
        GroupName = "Production - Cluster A"
        Servers = @("<SERVER_A1>", "<SERVER_A2>", "<SERVER_A3>")
    },
    @{
        GroupName = "Production - Cluster B"
        Servers = @("<SERVER_B1>", "<SERVER_B2>")
    },
    @{
        GroupName = "Test Environment"
        Servers = @("<TEST_SERVER_1>", "<TEST_SERVER_2>")
    }
)

$Query = @"
SELECT
    @@SERVERNAME AS [ServerName],
    j.name AS [JobName],
    CASE
        WHEN h.run_status = 0 THEN 'Failed'
        WHEN h.run_status = 1 THEN 'Succeeded'
        WHEN h.run_status = 2 THEN 'Retry'
        WHEN h.run_status = 3 THEN 'Canceled'
        WHEN h.run_status = 4 THEN 'In Progress'
        ELSE 'Unknown'
    END AS [LastStatus],
    CASE
        WHEN h.run_date IS NULL OR h.run_time IS NULL THEN NULL
        ELSE
            CAST(h.run_date AS VARCHAR(8)) + ' ' +
            STUFF(STUFF(RIGHT('000000' + CAST(h.run_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
    END AS [LastRunTime],
    h.message AS [Message]
FROM msdb.dbo.sysjobs j
CROSS APPLY (
    SELECT TOP 1 run_status, run_date, run_time, message
    FROM msdb.dbo.sysjobhistory jh
    WHERE jh.job_id = j.job_id
      AND jh.step_id = 0
    ORDER BY jh.run_date DESC, jh.run_time DESC
) h
WHERE j.name LIKE '%Backup%'
ORDER BY [LastStatus] ASC, [ServerName]
"@

$AllTablesHTML = ""

foreach ($Group in $ServerGroups) {
    $GroupRows = @()
    $AllTablesHTML += "<h3>$($Group.GroupName)</h3>"

    foreach ($Server in $Group.Servers) {
        try {
            $Result = Invoke-Sqlcmd -ServerInstance $Server -Query $Query -Username $SqlUser -Password $SqlPass -TrustServerCertificate -ConnectionTimeout 30 -ErrorAction Stop

            foreach ($Row in $Result) {
                $StatusColor = "black"
                $BgColor = "white"

                if ($Row.LastStatus -eq 'Failed') {
                    $StatusColor = "red"
                    $BgColor = "#ffe6e6"
                }
                elseif ($Row.LastStatus -eq 'Succeeded') {
                    $StatusColor = "green"
                }

                $HTMLRow = @"
<tr style='background-color: $BgColor'>
    <td>$($Row.ServerName)</td>
    <td>$($Row.JobName)</td>
    <td style='font-weight:bold; color: $StatusColor'>$($Row.LastStatus)</td>
    <td>$($Row.LastRunTime)</td>
    <td style='font-size: 0.9em; color: #555'>$($Row.Message)</td>
</tr>
"@
                $GroupRows += $HTMLRow
            }
        }
        catch {
            $ErrorMsg = $_.Exception.Message
            $GroupRows += "<tr style='background-color: #ffcccc'><td colspan='5'><b>Connection error to $($Server):</b><br><span style='font-size:0.8em'>$ErrorMsg</span></td></tr>"
        }
    }

    if ($GroupRows.Count -eq 0) {
        $AllTablesHTML += "<p style='color:#666; font-style:italic; margin-bottom:20px;'>No data returned or no backup jobs were found.</p>"
    }
    else {
        $AllTablesHTML += @"
<table>
    <tr><th>Server</th><th>Job</th><th>Status</th><th>Time</th><th>Info</th></tr>
    $($GroupRows -join "`n")
</table><br>
"@
    }
}

$Style = @"
<style>
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; color: #333; }
    h3 { background-color: #f4f4f4; padding: 10px; border-left: 5px solid #004d99; margin-bottom: 5px; color: #004d99; }
    table { border-collapse: collapse; width: 100%; margin-bottom: 20px; }
    th { background: #004d99; color: white; padding: 8px; text-align: left; font-size: 0.9em; }
    td { border: 1px solid #ddd; padding: 6px; font-size: 0.9em; }
</style>
"@

$BodyContent = @"
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    $Style
</head>
<body>
    <h2>Daily SQL Backup Report</h2>
    $AllTablesHTML
</body>
</html>
"@

try {
    $TokenBody = @{
        grant_type = "client_credentials"
        scope = "https://graph.microsoft.com/.default"
        client_id = $ClientId
        client_secret = $ClientSecret
    }

    $TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" -Method POST -Body $TokenBody
    $AccessToken = $TokenResponse.access_token

    if (-not $AccessToken) {
        throw "Failed to obtain Azure AD access token."
    }

    $RecipientList = @()
    foreach ($email in $Recipients) {
        $RecipientList += @{ emailAddress = @{ address = $email } }
    }

    $MailBody = @{
        message = @{
            subject = $Subject
            body = @{ contentType = "HTML"; content = $BodyContent }
            toRecipients = $RecipientList
        }
        saveToSentItems = $false
    } | ConvertTo-Json -Depth 10

    Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users/$SenderEmail/sendMail" -Headers @{ Authorization = "Bearer $AccessToken"; "Content-Type" = "application/json; charset=utf-8" } -Method POST -Body ([System.Text.Encoding]::UTF8.GetBytes($MailBody))

    Write-Host "Email sent successfully." -ForegroundColor Green
}
catch {
    Write-Error "Send error: $_"
}
