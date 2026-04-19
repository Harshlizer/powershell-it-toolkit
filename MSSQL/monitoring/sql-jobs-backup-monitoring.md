# SQL Jobs Monitoring for Backup Jobs

This example collects the status of SQL Agent jobs whose names match `*Backup*` from multiple SQL Servers, groups them by environment, and sends an HTML report by email through Microsoft Graph API.

## Requirements

1. A Windows host with network access to SQL Servers and outbound internet access.
2. The PowerShell `SqlServer` module:

```powershell
Install-Module -Name SqlServer -Scope AllUsers -Force -AllowClobber
```

3. An Azure AD application registration with `Mail.Send` application permissions.

## Files

- `create-sql-monitor-login.sql` - one-time SQL script to create a least-privilege monitoring login.
- `sql-jobs-backup-monitoring.ps1` - PowerShell reporting script with sanitized placeholders.

## Suggested Automation

Create a scheduled task that runs the PowerShell script every morning under a service account or `SYSTEM`.

Example:

```powershell
$TaskName = "SQL Daily Backup Report"
$ScriptPath = "C:\Scripts\sql-jobs-backup-monitoring.ps1"
$Time = "07:08"

$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""
$Trigger = New-ScheduledTaskTrigger -Daily -At $Time
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 30)

Register-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings -TaskName $TaskName -User "System" -RunLevel Highest -Force
```
