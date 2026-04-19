param(
    [switch]$CheckStatus,
    [switch]$Enable,
    [switch]$Disable
)

$Module = Get-Module ExchangeOnlineManagement -ListAvailable
if ($Module.Count -eq 0) {
    $Confirm = Read-Host "Are you sure you want to install the module? [Y] Yes [N] No"
    if ($Confirm -match "[yY]") {
        Install-Module ExchangeOnlineManagement -Repository PSGallery -AllowClobber -Force
    }
    else {
        Exit
    }
}

Connect-ExchangeOnline

if ($CheckStatus.IsPresent) {
    $Status = Get-OrganizationConfig | Select-Object AllowPlusAddressInRecipients
    if ($Status.AllowPlusAddressInRecipients -eq $true) {
        Write-Host "Plus addressing is currently enabled in your organization."
    }
    else {
        Write-Host "Plus addressing is currently disabled in your organization."
    }
}

if ($Enable.IsPresent) {
    Set-OrganizationConfig -AllowPlusAddressInRecipients $true
}

if ($Disable.IsPresent) {
    Set-OrganizationConfig -AllowPlusAddressInRecipients $false
}
