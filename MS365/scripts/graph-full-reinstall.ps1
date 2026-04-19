# Remove older Microsoft Graph modules and install the latest version.

Get-Module Microsoft.Graph* -ListAvailable | ForEach-Object {
    try {
        Write-Host "Removing $($_.Name) version $($_.Version)"
        Uninstall-Module -Name $_.Name -AllVersions -Force -ErrorAction SilentlyContinue
    }
    catch {
    }
}

$paths = @(
    "$env:ProgramFiles\WindowsPowerShell\Modules\Microsoft.Graph*",
    "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\Microsoft.Graph*"
)

foreach ($path in $paths) {
    Get-ChildItem $path -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            Write-Host "Deleting folder: $($_.FullName)"
            Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
        catch {
        }
    }
}

Write-Host "`nInstalling the latest Microsoft.Graph package..."
Install-Module Microsoft.Graph -Force -AllowClobber

Write-Host "`nInstalled versions:"
Get-Module Microsoft.Graph* -ListAvailable |
    Sort-Object Version -Descending |
    Select-Object -First 10 Name, Version
