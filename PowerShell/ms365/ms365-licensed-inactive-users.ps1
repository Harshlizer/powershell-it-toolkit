Install-Module -Name AzureAD
Install-Module -Name Microsoft.Graph

Connect-AzureAD
Connect-MgGraph -Scopes "User.Read.All"

$users = Get-MgUser -All -Property Id, DisplayName, Department, AssignedLicenses
$departmentLicenses = @{}
$totalLicensedUsers = 0

foreach ($user in $users) {
    if ($user.Department) {
        if (-not $departmentLicenses.ContainsKey($user.Department)) {
            $departmentLicenses[$user.Department] = @{
                Users = 0
                LicensedUsers = 0
            }
        }

        $departmentLicenses[$user.Department].Users++
        if ($user.AssignedLicenses.Count -gt 0) {
            $departmentLicenses[$user.Department].LicensedUsers++
            $totalLicensedUsers++
        }
    }
}

$output = @()
foreach ($department in $departmentLicenses.Keys) {
    $percentLicensed = ($departmentLicenses[$department].LicensedUsers / $departmentLicenses[$department].Users) * 100
    $output += [PSCustomObject]@{
        Department       = $department
        Users            = $departmentLicenses[$department].Users
        LicensedUsers    = $departmentLicenses[$department].LicensedUsers
        PercentLicensed  = [math]::Round($percentLicensed, 2)
    }
}

$output | Export-Csv -Path "C:\Temp\DepartmentLicenses_Detailed.csv" -NoTypeInformation
Write-Host "Script completed. Data was saved to DepartmentLicenses_Detailed.csv"
