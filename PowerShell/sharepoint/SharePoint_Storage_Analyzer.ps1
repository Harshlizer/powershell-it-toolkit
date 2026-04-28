<#
===============================================================================
SharePoint Storage Analyzer (STABLE VERSION via Graph REST)
===============================================================================
#>

# ================= CONFIG =================
$SiteSearchName = "PowerBianalysts"
$TopN = 100
$OutputFile = "c:\temp\Top_SharePoint_Files.csv"
$LogFile = "c:\temp\spo_scan.log"

# ================= FUNCTIONS =================

function Write-Log {
    param($Message)
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$time $Message" | Out-File -FilePath $LogFile -Append -Encoding utf8
}

function Invoke-GraphSafe {
    param($Uri)

    $retry = 0
    while ($retry -lt 5) {
        try {
            return Invoke-MgGraphRequest -Method GET -Uri $Uri
        }
        catch {
            if ($_.Exception.Message -match "429") {
                $delay = 5 * ($retry + 1)
                Write-Log "Throttled. Retry in $delay sec"
                Start-Sleep -Seconds $delay
                $retry++
            }
            else {
                Write-Log "ERROR: $($_.Exception.Message)"
                throw
            }
        }
    }
}

function Get-AllItemsRecursive {
    param(
        $DriveId,
        $FolderId,
        $Path
    )

    $uri = "https://graph.microsoft.com/v1.0/drives/$DriveId/items/$FolderId/children?`$top=999"

    $results = @()

    do {
        $response = Invoke-GraphSafe -Uri $uri

        foreach ($item in $response.value) {
            $currentPath = "$Path/$($item.name)"

            if ($item.folder) {
                $results += Get-AllItemsRecursive -DriveId $DriveId -FolderId $item.id -Path $currentPath
            }
            elseif ($item.file) {
                $results += [PSCustomObject]@{
                    Name      = $item.name
                    SizeMB    = [math]::Round($item.size / 1MB, 2)
                    SizeBytes = $item.size
                    Path      = $currentPath
                    WebUrl    = $item.webUrl
                    Modified  = $item.lastModifiedDateTime
                    Created   = $item.createdDateTime
                }
            }
        }

        $uri = $response.'@odata.nextLink'

    } while ($uri)

    return $results
}

# ================= START =================

Write-Host "Connecting to Graph..."
Connect-MgGraph -Scopes "Sites.Read.All","Files.Read.All" -NoWelcome

Write-Log "Started scan"

# Получаем сайт
$site = Get-MgSite -Search $SiteSearchName | Select-Object -First 1

if (-not $site) {
    throw "Site not found"
}

Write-Log "Site: $($site.WebUrl)"

# Получаем drives (документ библиотеки)
$drives = Invoke-GraphSafe -Uri "https://graph.microsoft.com/v1.0/sites/$($site.Id)/drives"

$allFiles = @()

foreach ($drive in $drives.value) {
    Write-Host "Scanning drive: $($drive.name)"
    Write-Log "Scanning drive: $($drive.name)"

    # root = "root"
    $files = Get-AllItemsRecursive -DriveId $drive.id -FolderId "root" -Path $drive.name
    $allFiles += $files
}

Write-Log "Files collected: $($allFiles.Count)"

# ТОП файлов
$topFiles = $allFiles |
    Sort-Object SizeBytes -Descending |
    Select-Object -First $TopN

# Экспорт
$topFiles | Export-Csv $OutputFile -NoTypeInformation -Encoding UTF8

Write-Log "Export done: $OutputFile"

Write-Host "DONE 🔥 Top $TopN files exported"