param(
    [switch]$CreateSession
)

$Module = Get-Module -Name Microsoft.Graph -ListAvailable
if ($Module.Count -eq 0) {
    $Confirm = Read-Host "Are you sure you want to install the module? [Y] Yes [N] No"
    if ($Confirm -match "[yY]") {
        Install-Module Microsoft.Graph -Repository PSGallery -Scope CurrentUser -AllowClobber -Force
    }
    else {
        Exit
    }
}

if ($CreateSession.IsPresent) {
    Disconnect-MgGraph
}

Connect-MgGraph -Scopes "User.Read.All", "UserAuthenticationMethod.Read.All"
