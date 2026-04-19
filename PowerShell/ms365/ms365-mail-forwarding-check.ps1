$smtpUser = "<SMTP_USERNAME>"
$smtpPass = "<SMTP_PASSWORD>"
$smtpServer = "smtp.office365.com"
$smtpPort = 587
$useSsl = $true

$from = "<FROM_EMAIL>"
$to = @("<RECIPIENT_EMAIL_1>", "<RECIPIENT_EMAIL_2>")
$subject = "External forwarding in Microsoft 365 - violations detected"

if (-not (Get-Command Get-Mailbox -ErrorAction SilentlyContinue)) {
    Import-Module ExchangeOnlineManagement
    Connect-ExchangeOnline -UserPrincipalName $smtpUser
}

$allowedDomains = @("<ALLOWED_DOMAIN_1>", "<ALLOWED_DOMAIN_2>", "<ALLOWED_DOMAIN_3>")

$violations = Get-Mailbox -ResultSize Unlimited | Where-Object {
    $_.ForwardingSMTPAddress
} | ForEach-Object {
    $fwd = $_.ForwardingSMTPAddress
    $domain = ($fwd -split "@")[-1].ToLower()
    if ($allowedDomains -notcontains $domain) {
        [PSCustomObject]@{
            DisplayName       = $_.DisplayName
            UserPrincipalName = $_.UserPrincipalName
            ForwardTo         = $fwd
            Domain            = $domain
            IsAllowedDomain   = $false
        }
    }
}

if ($violations.Count -gt 0) {
    $htmlHeader = @"
<html><body>
<h2>External forwarding to non-approved domains was detected</h2>
<table border='1' cellpadding='4' cellspacing='0' style='border-collapse:collapse; font-family:sans-serif;'>
<tr><th>Display Name</th><th>UserPrincipalName</th><th>Forward To</th><th>Domain</th></tr>
"@

    $htmlBody = $violations | ForEach-Object {
        "<tr><td>$($_.DisplayName)</td><td>$($_.UserPrincipalName)</td><td>$($_.ForwardTo)</td><td>$($_.Domain)</td></tr>"
    } | Out-String

    $htmlFooter = @"
</table>
<br><p style='color:gray;'>Generated automatically.</p>
</body></html>
"@

    $htmlContent = $htmlHeader + $htmlBody + $htmlFooter
    $securePassword = ConvertTo-SecureString $smtpPass -AsPlainText -Force
    $cred = New-Object PSCredential($smtpUser, $securePassword)

    Send-MailMessage -From $from -To $to -Subject $subject -Body $htmlContent -BodyAsHtml `
        -SmtpServer $smtpServer -Port $smtpPort -UseSsl:$useSsl -Credential $cred -Encoding ([System.Text.Encoding]::UTF8)
}
