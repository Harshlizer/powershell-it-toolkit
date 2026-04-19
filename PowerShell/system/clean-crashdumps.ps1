$usersPath = "C:\Users"
$targetSubPath = "AppData\Local\CrashDumps"
$totalFreed = 0

$userFolders = Get-ChildItem -Path $usersPath -Directory

foreach ($user in $userFolders) {
    $fullPath = Join-Path -Path $user.FullName -ChildPath $targetSubPath

    if (Test-Path $fullPath) {
        try {
            $files = Get-ChildItem -Path $fullPath -Recurse -File -ErrorAction SilentlyContinue
            if ($files) {
                $size = ($files | Measure-Object -Property Length -Sum).Sum
                $totalFreed += $size
                $files | Remove-Item -Force -ErrorAction SilentlyContinue
            }
        }
        catch {
            Write-Host "Access error for user $($user.Name)." -ForegroundColor Red
        }
    }
}

$totalMB = [math]::Round($totalFreed / 1MB, 2)
Write-Host "Completed. Total freed: $totalMB MB" -ForegroundColor Yellow
