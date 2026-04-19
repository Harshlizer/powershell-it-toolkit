$domainController = "localhost"
$certStorePaths = @("Cert:\LocalMachine\My", "Cert:\LocalMachine\Root")
$alertDays = 21

$smtpServer = "<SMTP_SERVER>"
$smtpPort = 587
$fromEmail = "<FROM_EMAIL>"
$toEmail = "<TO_EMAIL>"
$subject = "Certificate expiration notification"
$smtpUser = "<SMTP_USERNAME>"
$smtpPassword = ConvertTo-SecureString "<SMTP_PASSWORD>" -AsPlainText -Force

$smtpCredential = New-Object System.Management.Automation.PSCredential($smtpUser, $smtpPassword)
$expiringCerts = @()

function Add-CertToList {
    param (
        [string]$certName,
        [DateTime]$expirationDate,
        [string]$certStore
    )

    $script:expiringCerts += "Certificate: $certName, Store: $certStore, Expires: $($expirationDate.ToString('yyyy-MM-dd'))"
}

foreach ($certStorePath in $certStorePaths) {
    $certificates = Invoke-Command -ComputerName $domainController -ScriptBlock {
        param ($path)
        Get-ChildItem -Path $path
    } -ArgumentList $certStorePath

    $currentDate = Get-Date

    foreach ($cert in $certificates) {
        $expirationDate = $cert.NotAfter
        $daysLeft = ($expirationDate - $currentDate).Days

        if ($daysLeft -le $alertDays) {
            Add-CertToList -certName $cert.Subject -expirationDate $expirationDate -certStore $certStorePath
        }
    }
}

if ($expiringCerts.Count -gt 0) {
    $body = "The following certificates expire within the next $alertDays days:" + [Environment]::NewLine + [Environment]::NewLine
    $body += ($expiringCerts -join [Environment]::NewLine)
}
else {
    $body = "No certificates expire within the next $alertDays days."
}

Send-MailMessage -From $fromEmail -To $toEmail -Subject $subject -Body $body `
    -SmtpServer $smtpServer -Port $smtpPort -UseSsl -Credential $smtpCredential -Encoding ([System.Text.Encoding]::UTF8)
