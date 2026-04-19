$smtpServer = "<SMTP_SERVER>"
$smtpPort = 587
$smtpUsername = "<SMTP_USERNAME>"
$smtpPassword = ConvertTo-SecureString -String "<SMTP_PASSWORD>" -AsPlainText -Force
$smtpCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $smtpUsername, $smtpPassword
$TaskResults = Get-ScheduledTaskInfo -TaskName "<TASK_NAME>"

if ($TaskResults.LastTaskResult) {
    Send-MailMessage -To "<RECIPIENT_EMAIL>" -From "<SENDER_EMAIL>" -Subject "Scheduled task failed" -Body ($TaskResults | Out-String) -SmtpServer $smtpServer -Port $smtpPort -UseSSL -Credential $smtpCredential
}
else {
    Send-MailMessage -To "<RECIPIENT_EMAIL>" -From "<SENDER_EMAIL>" -Subject "Scheduled task completed successfully" -Body ($TaskResults | Out-String) -SmtpServer $smtpServer -Port $smtpPort -UseSSL -Credential $smtpCredential
}
