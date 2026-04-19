$smtpServer = "<SMTP_SERVER>"
$smtpFrom = "<FROM_EMAIL>"
$smtpTo = "<TO_EMAIL>"
$smtpUser = "<SMTP_USERNAME>"
$smtpPass = "<SMTP_PASSWORD>"
$smtpPort = 587

$currentDateTime = Get-Date
$previousDateTime = $currentDateTime.AddHours(-24)

$events = Get-WinEvent -FilterHashtable @{ LogName = 'Microsoft-Windows-DNSServer/Audit'; Id = @(512, 513, 515, 516); StartTime = $previousDateTime }

function Get-EventMessage($eventId) {
    switch ($eventId) {
        512 { return "<b><span style='color: darkblue;'>Zone created</span></b>" }
        515 { return "<b><span style='color: blue;'>Record created</span></b>" }
        513 { return "<b><span style='color: darkred;'>Zone deleted</span></b>" }
        516 { return "<b><span style='color: red;'>Record deleted</span></b>" }
        default { return $eventId }
    }
}

function Convert-SIDToUserName {
    param ([string]$SID)

    try {
        $user = (New-Object System.Security.Principal.SecurityIdentifier($SID)).Translate([System.Security.Principal.NTAccount]).Value
        $username = $user.Split('\')[-1]
    }
    catch {
        $username = $SID
    }

    return $username
}

if ($events) {
    $reportString = "<h2>DNS changes in the last 24 hours</h2><table border='1'><tr><th>Time</th><th>Event</th><th>Name</th><th>User</th><th>Message</th></tr>"
    foreach ($event in $events) {
        $time = "<b><span style='color: grey;'>" + $event.TimeCreated.ToString("HH:mm:ss") + "</span></b>"
        $name = "<b><span style='color: green;'>" + $event.Properties[1].Value + "</span></b>"
        $user = Convert-SIDToUserName -SID $event.UserId
        $message = $event.Message -replace " TTL \d+ and RDATA \w+", "" -replace "\[virtualization instance: \.\]", ""
        $eventMessage = Get-EventMessage($event.Id)
        $reportString += "<tr><td>$time</td><td>$eventMessage</td><td>$name</td><td>$user</td><td>$message</td></tr>"
    }
    $reportString += "</table>"

    $securePass = ConvertTo-SecureString $smtpPass -AsPlainText -Force
    $credentials = New-Object PSCredential($smtpUser, $securePass)

    Send-MailMessage -SmtpServer $smtpServer -From $smtpFrom -To $smtpTo -Subject "DNS Report" -BodyAsHtml $reportString -Port $smtpPort -Credential $credentials -UseSsl -Encoding ([System.Text.Encoding]::UTF8)
}
else {
    Write-Host "No DNS audit events with IDs 512, 513, 515, or 516 were found in the last 24 hours."
}
