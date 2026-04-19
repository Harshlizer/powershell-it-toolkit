$DaysBack = 7
$outRoot = 'C:\Temp'
$since = (Get-Date).AddDays(-$DaysBack)
$stamp = Get-Date -Format yyyyMMdd_HHmmss
$outDir = Join-Path $outRoot "Spool_Audit_$stamp"
$driversPath = 'C:\Windows\System32\spool\drivers\*\3\New'

New-Item -ItemType Directory -Path $outDir -Force | Out-Null

$files = Get-ChildItem $driversPath -Include *.dll, *.exe -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -ge $since } |
    ForEach-Object {
        $sig = Get-AuthenticodeSignature $_.FullName -ErrorAction SilentlyContinue
        [pscustomobject]@{
            Time           = $_.LastWriteTime
            Name           = $_.Name
            Path           = $_.FullName
            SizeKB         = [math]::Round($_.Length / 1kb, 1)
            ProductVersion = $_.VersionInfo.ProductVersion
            Signer         = $sig.SignerCertificate.Subject -replace '^CN='
            SigStatus      = $sig.Status
            SHA256         = (Get-FileHash -Algorithm SHA256 -Path $_.FullName -ErrorAction SilentlyContinue).Hash
        }
    }

$files | Export-Csv (Join-Path $outDir 'Spool_Files.csv') -NoTypeInformation -Encoding UTF8
Write-Host "Completed: $outDir"
