# Firewall status
Get-NetFirewallProfile | Format-Table Name, Enabled

# Create a firewall rule
New-NetFirewallRule -DisplayName "zabbix" -Direction Inbound -Profile Inbound -Action Allow -LocalPort 10050-10051 -Protocol TCP

# Windows Update
Install-Module -Name PSWindowsUpdate
Get-WindowsUpdate -Install -AcceptAll -AutoReboot -RecurseCycle 5 -MicrosoftUpdate

# Check available updates on remote computers
Get-WUList -ComputerName <SERVER_NAME>
Get-WUList -ComputerName <DOMAIN_CONTROLLER_NAME>

# Change DNS servers
Get-NetAdapter | Select-Object InterfaceAlias, InterfaceIndex
Set-DnsClientServerAddress -InterfaceIndex 4 -ServerAddresses ("<DNS_SERVER_1>", "<DNS_SERVER_2>")

# Create a self-signed certificate
New-SelfSignedCertificate -DnsName "<DOMAIN_NAME>" -CertStoreLocation cert:\LocalMachine\My

# Check whether a port is open
Test-NetConnection -ComputerName localhost -Port 1433

# Check reboot log
Get-WinEvent -FilterHashtable @{ logname = 'System'; id = 1074 } | Format-Table -Wrap

# Export user status from Active Directory
Import-Module ActiveDirectory
Get-ADUser -Filter * -Properties displayName, Enabled, givenName, sn, distinguishedname, mail, mobile, telephoneNumber, facsimileTelephoneNumber, title |
    Select-Object displayName, Enabled, givenName, sn, distinguishedname, mail, mobile, telephoneNumber, facsimileTelephoneNumber, title |
    Export-Csv "C:\Temp\export.csv" -NoTypeInformation

# Register a scheduled PowerShell job
Register-ScheduledJob -Name PingDC -FilePath "C:\Temp\script.ps1" `
    -Trigger (New-JobTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 15) -RepeatIndefinitely)

# Get shadow session logs
$EventIds = 20508, 20503, 20504
Get-WinEvent -FilterHashTable @{ LogName = 'Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational'; ID = $EventIds }

# Shadow connect
qwinsta /server:localhost
mstsc.exe /shadow:25 /noConsentPrompt /control /v:localhost

# Example filtered cloud storage search
gsutil ls "gs://<BUCKET_NAME>/audio/**/*<SEARCH_VALUE>*"

# Last local logon usage
Get-WmiObject Win32_UserProfile |
    Where-Object { $_.LocalPath -match "C:\\Users\\.+$" } |
    Select-Object LocalPath, LastUseTime |
    Sort-Object LastUseTime -Descending |
    Format-Table -AutoSize

# AD group search by name
Get-ADGroup -Filter 'Name -like "*DevOps*"' | Select-Object Name
