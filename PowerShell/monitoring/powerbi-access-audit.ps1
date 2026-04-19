param(
    [string]$OutputFolder = "C:\Temp\PowerBI_Access_Audit"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
}

Import-Module MicrosoftPowerBIMgmt.Profile
Connect-PowerBIServiceAccount

function Invoke-PbiAdminGet {
    param([Parameter(Mandatory)] [string]$Url)
    Invoke-PowerBIRestMethod -Url $Url -Method Get | ConvertFrom-Json
}

function Get-AllAdminItems {
    param([Parameter(Mandatory)] [string]$BaseUrl)

    $all = @()
    $skip = 0
    $top = 5000

    while ($true) {
        $separator = if ($BaseUrl -match "\?") { "&" } else { "?" }
        $url = "$BaseUrl${separator}`$top=$top&`$skip=$skip"
        $resp = Invoke-PbiAdminGet -Url $url

        if ($null -eq $resp.value -or $resp.value.Count -eq 0) { break }
        $all += $resp.value
        if ($resp.value.Count -lt $top) { break }
        $skip += $top
    }

    return $all
}

$workspaces = Get-AllAdminItems -BaseUrl "admin/groups"
$workspaceAccess = New-Object System.Collections.Generic.List[object]

foreach ($ws in $workspaces) {
    $workspaceId = $ws.id
    $workspaceName = $ws.name

    try {
        $wsUsers = Invoke-PbiAdminGet -Url "admin/groups/$workspaceId/users"
        foreach ($u in $wsUsers.value) {
            $workspaceAccess.Add([pscustomobject]@{
                WorkspaceName        = $workspaceName
                WorkspaceId          = $workspaceId
                PrincipalType        = $u.principalType
                Identifier           = $u.identifier
                DisplayName          = $u.displayName
                EmailAddress         = $u.emailAddress
                WorkspaceAccessRight = $u.groupUserAccessRight
            })
        }
    }
    catch {
        Write-Warning "Failed to get workspace users for $workspaceName : $($_.Exception.Message)"
    }
}

$workspaceFile = Join-Path $OutputFolder "PowerBI_Workspace_Access.csv"
$workspaceAccess | Sort-Object WorkspaceName, DisplayName | Export-Csv -Path $workspaceFile -NoTypeInformation -Encoding UTF8
Write-Host "Workspace access exported to: $workspaceFile"
