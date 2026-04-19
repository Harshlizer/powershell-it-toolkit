$ReportPath = "C:\bi_report"
if (!(Test-Path $ReportPath)) { New-Item -ItemType Directory -Path $ReportPath -Force | Out-Null }

$TenantId = "<TENANT_ID>"
$ClientId = "<CLIENT_ID>"
$ClientSecret = "<CLIENT_SECRET>"

if (!(Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Install-Module Microsoft.Graph -Force -AllowClobber -Scope CurrentUser
}

try {
    $secureSecret = ConvertTo-SecureString $ClientSecret -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential ($ClientId, $secureSecret)
    Connect-MgGraph -TenantId $TenantId -ClientSecretCredential $credential -NoWelcome
    Write-Host "Connected to Microsoft Graph using App Registration." -ForegroundColor Green
}
catch {
    Write-Host "Failed to connect to Microsoft Graph: $_" -ForegroundColor Red
    exit 1
}
