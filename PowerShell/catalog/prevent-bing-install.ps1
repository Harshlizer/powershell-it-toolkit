$RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\Common\Officeupdate"
$Name = "preventbinginstall"
$value = "00000001"

if (!(Test-Path $RegistryPath)) {
    Write-Host "Office 365 ProPlus is not available." -ForegroundColor Yellow
}
else {
    New-ItemProperty -Path $RegistryPath -Name $Name -Value $value -PropertyType DWORD -Force | Out-Null
    Write-Host "Successfully added the registry key to prevent Bing install in Chrome." -ForegroundColor Green
}
