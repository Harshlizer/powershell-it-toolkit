$TenantId = "<TENANT_ID>"
$ClientId = "<CLIENT_ID>"
$ClientSecret = "<CLIENT_SECRET>"

try {
    $secureSecret = ConvertTo-SecureString $ClientSecret -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential ($ClientId, $secureSecret)
    Connect-MgGraph -TenantId $TenantId -ClientSecretCredential $credential -NoWelcome
}
catch {
    Write-Host "Microsoft Graph connection failed: $_" -ForegroundColor Red
    exit 1
}

$licensePrices = @{
    "O365_BUSINESS_ESSENTIALS"  = 4.75
    "O365_BUSINESS_PREMIUM"     = 10.03
    "SPB"                       = 10.03
    "O365_STANDARD"             = 10.03
    "O365_BUSINESS"             = 10.05
    "OFFICESUBSCRIPTION"        = 10.05
    "TEAMS_ESSENTIALS"          = 3.80
    "TEAMS_PREMIUM"             = 8.63
    "ENTERPRISEPACK"            = 25.80
    "STANDARDPACK"              = 9.58
    "POWER_BI_PRO"              = 8.05
    "POWER_BI_PREMIUM_PER_USER" = 19.23
}

$users = Get-MgUser -All -Property Id, DisplayName, Department, AssignedLicenses
$departmentLicenses = @{}

foreach ($user in $users) {
    if ($user.Department -and $user.AssignedLicenses.Count -gt 0) {
        $department = $user.Department

        if (-not $departmentLicenses.ContainsKey($department)) {
            $departmentLicenses[$department] = @{
                TotalCost = 0
            }
        }

        $licenses = Get-MgUserLicenseDetail -UserId $user.Id
        foreach ($license in $licenses) {
            $skuName = $license.SkuPartNumber
            if ($licensePrices.ContainsKey($skuName)) {
                $departmentLicenses[$department].TotalCost += $licensePrices[$skuName]
            }
        }
    }
}

$output = foreach ($department in $departmentLicenses.Keys | Sort-Object) {
    [PSCustomObject]@{
        Department = $department
        TotalCost  = [math]::Round($departmentLicenses[$department].TotalCost, 2)
    }
}

$outputFile = "C:\Temp\DepartmentLicenses_$(Get-Date -Format 'yyyy-MM-dd').csv"
$output | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8
Write-Host "Script completed. Data was saved to $outputFile"
Disconnect-MgGraph
