<#
===============================================================================
SharePoint Version Audit (Top Versioned Files)
===============================================================================
#>

# ================= CONFIG =================
$SiteSearchName = "PowerBianalysts"
$OutputFile = "c:\temp\SharePoint_Version_Audit.csv"

# ================= FUNCTIONS =================

function Invoke-GraphSafe {
    param($Uri)

    $retry = 0
    while ($retry -lt 5) {
        try {
            return Invoke-MgGraphRequest -Method GET -Uri $Uri
        }
        catch {
            if ($_.Exception.Message -match "429") {
                Start-Sleep -Seconds (5 * ($retry + 1))
                $retry++
            }
            else {
                throw
            }
        }
    }
}

function Get-AllFiles {
    param($DriveId, $FolderId, $Path)

    $uri = "https://graph.microsoft.com/v1.0/drives/$DriveId/items/$FolderId/children?`$top=999"
    $results = @()

    do {
        $response = Invoke-GraphSafe -Uri $uri

        foreach ($item in $response.value) {
            $currentPath = "$Path/$($item.name)"

            if ($item.folder) {
                $results += Get-AllFiles -DriveId $DriveId -FolderId $item.id -Path $currentPath
            }
            elseif ($item.file) {
                $results += [PSCustomObject]@{
                    Name      = $item.name
                    Id        = $item.id
                    DriveId   = $DriveId
                    SizeMB    = [math]::Round($item.size / 1MB, 2)
                    Path      = $currentPath
                    WebUrl    = $item.webUrl
                }
            }
        }

        $uri = $response.'@odata.nextLink'

    } while ($uri)

    return $results
}

function Get-VersionCount {
    param($DriveId, $ItemId)

    $uri = "https://graph.microsoft.com/v1.0/drives/$DriveId/items/$ItemId/versions?`$top=999"
    $count = 0

    do {
        $response = Invoke-GraphSafe -Uri $uri
        $count += $response.value.Count
        $uri = $response.'@odata.nextLink'
    } while ($uri)

    return $count
}

# ================= START =================

Write-Host "Connecting..."
Connect-MgGraph -Scopes "Sites.Read.All","Files.Read.All" -NoWelcome

$site = Get-MgSite -Search $SiteSearchName | Select-Object -First 1

if (-not $site) {
    throw "Site not found"
}

Write-Host "Site: $($site.WebUrl)"

$drives = Invoke-GraphSafe -Uri "https://graph.microsoft.com/v1.0/sites/$($site.Id)/drives"

$allFiles = @()

foreach ($drive in $drives.value) {
    Write-Host "Scanning drive: $($drive.name)"
    $allFiles += Get-AllFiles -DriveId $drive.id -FolderId "root" -Path $drive.name
}

Write-Host "Total files: $($allFiles.Count)"

$results = @()

foreach ($file in $allFiles) {
    Write-Host "Checking versions: $($file.Name)"

    $versionCount = Get-VersionCount -DriveId $file.DriveId -ItemId $file.Id

    if ($versionCount -ge 20) {
        $results += [PSCustomObject]@{
            Name             = $file.Name
            Versions         = $versionCount
            SizeMB           = $file.SizeMB
            EstimatedTotalMB = [math]::Round($file.SizeMB * $versionCount, 2)
            Path             = $file.Path
            WebUrl           = $file.WebUrl
            Level            = if ($versionCount -ge 100) { "100+" } else { "20+" }
        }
    }
}

# сортировка по количеству версий
$results = $results | Sort-Object Versions -Descending

$results | Export-Csv $OutputFile -NoTypeInformation -Encoding UTF8

Write-Host "DONE 🔥 Report: $OutputFile"