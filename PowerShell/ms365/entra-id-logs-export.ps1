$DaysBack = 7
$OutputPath = "C:\EntraLogs"

if (!(Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
}

Connect-MgGraph -Scopes `
"AuditLog.Read.All", `
"Directory.Read.All", `
"IdentityRiskyUser.Read.All", `
"IdentityRiskEvent.Read.All"

$StartDate = (Get-Date).AddDays(-$DaysBack).ToString("yyyy-MM-ddTHH:mm:ssZ")

$signins = Get-MgAuditLogSignIn -Filter "createdDateTime ge $StartDate" -All
$signins | Select-Object createdDateTime, userPrincipalName, appDisplayName, ipAddress, location, clientAppUsed, riskLevelDuringSignIn, status |
    Export-Csv "$OutputPath\SigninLogs.csv" -NoTypeInformation
