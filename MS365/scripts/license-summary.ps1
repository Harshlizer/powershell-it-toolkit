<#
.SYNOPSIS
    Generate a Microsoft 365 license summary by department.
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
Write-Host "Implement department license aggregation with Microsoft Graph as needed."
