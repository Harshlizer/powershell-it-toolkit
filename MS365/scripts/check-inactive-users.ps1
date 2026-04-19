<#
.SYNOPSIS
    Generate a report for inactive Microsoft 365 users older than 30 days.

.DESCRIPTION
    Uses Microsoft Graph application authentication with placeholders instead of real secrets.
#>

$ErrorActionPreference = "Stop"
$ReportPath = "C:\bi_report"
if (-not (Test-Path $ReportPath)) {
    New-Item -ItemType Directory -Path $ReportPath -Force | Out-Null
}

$TenantId = "<TENANT_ID>"
$ClientId = "<CLIENT_ID>"
$ClientSecret = "<CLIENT_SECRET>"

Write-Host "Placeholder-based configuration loaded."
Write-Host "Implement report logic against Microsoft Graph and Exchange Online as needed."
