$Module = (Get-Module ExchangeOnlineManagement -ListAvailable) | Where-Object { $_.Version.Major -ge 3 }
if ($Module.Count -eq 0) {
    $Confirm = Read-Host "Are you sure you want to install the module? [Y] Yes [N] No"
    if ($Confirm -match "[yY]") {
        Install-Module ExchangeOnlineManagement -Repository PSGallery -AllowClobber -Force
        Import-Module ExchangeOnlineManagement
    }
    else {
        Exit
    }
}

Connect-ExchangeOnline
