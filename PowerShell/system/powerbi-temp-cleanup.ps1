$usersDirectory = "C:\Users"
$daysOld = 4

$users = Get-ChildItem $usersDirectory | Where-Object { $_.PSIsContainer }

foreach ($user in $users) {
    $powerBiDirectory = Join-Path -Path $usersDirectory -ChildPath "$($user.Name)\AppData\Local\Microsoft\Power BI Desktop\TempSaves"

    if (Test-Path $powerBiDirectory -PathType Container) {
        $oldFiles = Get-ChildItem $powerBiDirectory | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$daysOld) }

        foreach ($file in $oldFiles) {
            Remove-Item $file.FullName -Force
            Write-Host "Deleted file: $($file.FullName)"
        }
    }
}
