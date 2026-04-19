Param
(
    [String] $SiteUrl,
    [String] $UserName, 
    [String] $Password,
    [String] $ClientId,
    [String] $CertificateThumbprint,
    [String] $TenantName,
    [String] $LibraryName,
    [Switch] $SiteLevel,
    [String] $FilePath,
    [String] $FolderPath,
    [int] $KeepTopVersionCount,
    [int] $KeepMajorCount,
    [int] $KeepMinorCount,
    [String] $DeleteDateFrom,
    [String] $DeleteDateTo,
    [String[]] $SpecificVersionsToDelete,
    [String[]] $SpecificVersionsToKeep,
    [String[]] $VersionsCreatedBy,
    [Switch] $HardDelete
)

Function Installation-Module {
    $Module = Get-InstalledModule -Name PnP.PowerShell -MinimumVersion 1.12.0 -ErrorAction SilentlyContinue
    If ($Module -eq $null) {
        Write-Host SharePoint PnP PowerShell Module is not available -ForegroundColor Yellow
        $Confirm = Read-Host Are you sure you want to install module? [Yy] Yes [Nn] No
        If ($Confirm -match "[yY]") { 
            Write-Host "Installing PnP PowerShell module..."
            Install-Module PnP.PowerShell -Force -AllowClobber -Scope CurrentUser       
        } 
        Else { 
            Write-Host "PnP PowerShell module is required to connect SharePoint Online.Please install module using 'Install-Module PnP.PowerShell' cmdlet."
            Exit
        }
        Import-Module -Name Pnp.Powershell 
    }
    Write-Host `nConnecting to SharePoint Online... -ForegroundColor Green
}

Function Connect_SharePoint {
    param
    (
        [Parameter(Mandatory = $true)]
        [String] $Url
    )
    if (($UserName -ne "") -and ($Password -ne "")) {
        $SecuredPassword = ConvertTo-SecureString -AsPlainText $Password -Force
        $Credential = New-Object System.Management.Automation.PSCredential $UserName, $SecuredPassword
        Connect-PnPOnline -Url $Url -ClientId $ClientId -Credential $Credential
    }
    elseif ($TenantName -ne "" -and $ClientId -ne "" -and $CertificateThumbprint -ne "") {
        Connect-PnPOnline -Url $Url -ClientId $ClientId -Thumbprint $CertificateThumbprint  -Tenant "$TenantName.onmicrosoft.com" 
    }
    else {
        Connect-PnPOnline -Url $Url -ClientId $ClientId -interactive
    }
}
Function LogEntry {
    param (
        [string]$FileRelativeUrl,
        [string]$Filename,
        [string]$Status,
        [string]$ErrorDetails = "",
        [int]$TotalVersions = 0,
        [int]$DeletedCount = 0,
        [int]$RemainingVersionsAvailable = 0,
        [int]$KeptMajorVersions = 0,
        [int]$KeptMinorVersions = 0
    )

    $logEntry = [PSCustomObject]@{
        "CleanUp Time"                             = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        "File Name"                                = if ($Filename) { $Filename } else { "" }
        "File Path"                                = if ($FileRelativeUrl) { if ($FilePath) { [System.Uri]::UnescapeDataString($FilePath) } else { "$SiteUrl$FileRelativeUrl" } } else { "" }
        "Total Versions Count"                     = $TotalVersions
        "Deleted Versions Count"                   = $DeletedCount
        "Remaining Available Versions Count"       = $RemainingVersionsAvailable
        "Retained Major Versions Count"            = $KeptMajorVersions
        "Retained Minor Versions Count"            = $KeptMinorVersions
        "Deletion Type"                             = $(if ($HardDelete) { "Permanent Delete" } else { "Moved to RecycleBin" })
        "Status"                                   = $Status
        "Error Details"                             = $ErrorDetails
    }

    if (-not (Test-Path $OutputCSV)) {
        $logEntry | Export-Csv -Path $OutputCSV -NoTypeInformation -Encoding UTF8
    }
    else {
        $logEntry | Export-Csv -Path $OutputCSV -Append -NoTypeInformation -Encoding UTF8
    }
}

# Cleanup function
Function Cleanup-FileVersions {
    param (
        [string]$FileRelativeUrl,
        [string[]]$SpecificVersionsToDelete,
        [string[]]$SpecificVersionsToKeep,
        [string[]]$VersionsCreatedBy,
        [string]$DeleteDateFrom,
        [string]$DeleteDateTo,
        [int] $KeepMajorCount,
        [int]$KeepMinorCount,
        [int] $KeepTopVersionCount

    )
    
    $versionErrors = @()

    try {

        $file = Get-PnPFile -Url $FileRelativeUrl -AsListItem -ErrorAction Stop
        $versions = Get-PnPProperty -ClientObject $file -Property Versions
        $totalVersions = $versions.Count

        $TimeZoneOffsetHours = -8

        if ($totalVersions -eq 0) {
            LogEntry -FileRelativeUrl $FileRelativeUrl -Status "No Versions Found"
            return
        }
        
        $eligibleVersions = $versions


        $eligibleVersions = $versions | Where-Object { -not $_.IsCurrentVersion }

        if ($DeleteDateFrom) {
            $DeleteDateFrom = ([datetime]::Parse($DeleteDateFrom)).AddHours(-$TimeZoneOffsetHours)
        }
        if ($DeleteDateTo) {
            $DeleteDateTo = ([datetime]::Parse($DeleteDateTo)).AddDays(1).AddSeconds(-1).AddHours(-$TimeZoneOffsetHours)
        }

        if ($DeleteDateFrom -or $DeleteDateTo) {
            $eligibleVersions = $eligibleVersions | Where-Object {
                (!$DeleteDateFrom -or $_.Created -ge $DeleteDateFrom) -and
                (!$DeleteDateTo -or $_.Created -le $DeleteDateTo)
            }
        }

        # User filter
        if ($VersionsCreatedBy) {
            $VersionsCreatedByLower = $VersionsCreatedBy | ForEach-Object { $_.ToLower() }
            $eligibleVersions = $eligibleVersions | Where-Object {
                ($_.FieldValues["Modified_x0020_By"] -replace '^.*\|', '').ToLower() -in $VersionsCreatedByLower
            }
        }

        $keepList = @()

        if ($KeepTopVersionCount -gt 0) {

            $keepList = $eligibleVersions |
            Sort-Object { [version]$_.VersionLabel } -Descending |
            Select-Object -First $KeepTopVersionCount
        }
        else {

            if ($KeepMajorCount -gt 0) {
                $majorVersions = $eligibleVersions |
                Where-Object { $_.VersionLabel -match '^\d+\.0$' } |
                Sort-Object { [version]$_.VersionLabel } -Descending |
                Select-Object -First $KeepMajorCount
            }

            $keepList += $majorVersions

            if ($KeepMinorCount -gt 0) {
                $minorVersions = $eligibleVersions |
                Where-Object { $_.VersionLabel -match '^\d+\.\d+$' -and $_.VersionLabel -notmatch '\.0$' } |
                Sort-Object { [version]$_.VersionLabel } -Descending |
                Select-Object -First $KeepMinorCount
            }

            $keepList += $minorVersions
        }

        if ($SpecificVersionsToKeep) {
            $keepList += $eligibleVersions | Where-Object { $SpecificVersionsToKeep -contains $_.VersionLabel }
        }

        if ($SpecificVersionsToDelete) {
            $eligibleVersions = $eligibleVersions | Where-Object { $SpecificVersionsToDelete -contains $_.VersionLabel }
        }

        $deletedCount = 0

        # deletions
        $eligibleVersions | Where-Object { $keepList.VersionLabel -notcontains $_.VersionLabel } | Sort-Object { [version]$_.VersionLabel } | ForEach-Object {

            $versionLabel = $_.VersionLabel
            try {
                if ($HardDelete) {
                    Remove-PnPFileVersion -Url $FileRelativeUrl -Identity $_.VersionLabel -Force
                    $deletedCount++
                }
                else {
                    Remove-PnPFileVersion -Url $FileRelativeUrl -Identity $_.VersionLabel -Recycle -Force
                    $deletedCount++
                }
            }
            catch {
                LogEntry -FileRelativeUrl $FileRelativeUrl -Filename $file.FieldValues["FileLeafRef"] -Status "Failed" -ErrorDetails "Version $($versionLabel): $($_.Exception.Message)" -TotalVersions 0 -DeletedCount 0 -RemainingVersionsAvailable 0 -KeptMajorVersions 0 -KeptMinorVersions 0
            }
        }

        if ($deletedCount -gt 0) {
            $status = "Success"
        }
        else {
            $status = "Skipped"
        }

        # Get remaining versions after deletion
        $fileAfter = Get-PnPFile -Url $FileRelativeUrl -AsListItem
        $remainingVersions = Get-PnPProperty -ClientObject $fileAfter -Property Versions

        $remainingMajorCount = ($remainingVersions | Where-Object { $_.VersionLabel -match '^\d+\.0$' }).Count
        $remainingMinorCount = ($remainingVersions | Where-Object { $_.VersionLabel -match '^\d+\.\d+$' -and $_.VersionLabel -notmatch '\.0$' }).Count

        $logParams = @{ 
            FileRelativeUrl                 = $FileRelativeUrl
            Filename                        = $file.FieldValues["FileLeafRef"]
            Status                          = $status
            TotalVersions                   = $totalVersions
            DeletedCount                    = $deletedCount
            RemainingVersionsAvailable      = ($totalVersions - $deletedCount)
            KeptMajorVersions               = $remainingMajorCount
            KeptMinorVersions               = $remainingMinorCount
            ErrorDetails                    = "-"
        }
        if ($status -eq "Skipped") {
            $logParams.ErrorDetails = "Not enough versions available."
        }
        LogEntry @logParams
    }
    catch {
        LogEntry -FileRelativeUrl $FileRelativeUrl -Status "Failed" -ErrorDetails $_.Exception.Message
    }
}
Function Convert-ToServerRelativeUrl {
    param (
        [string]$InputUrl
    )
    try {
        if ($InputUrl.StartsWith("/")) {
            return [System.Uri]::UnescapeDataString($InputUrl)
        }
        if ($InputUrl.EndsWith("/")) {
            $InputUrl = $InputUrl.TrimEnd("/")
        }
        $uri = [System.Uri]$InputUrl
        $relativeUrl = $uri.AbsolutePath
        return [System.Uri]::UnescapeDataString($relativeUrl)
    }
    catch {
        LogEntry -FileRelativeUrl $InputUrl -Status "Failed" -ErrorDetails $_.Exception.Message
    }
}

function message {
    Write-Host `n~~ Script prepared by AdminDroid Community ~~`n -ForegroundColor Green
    Write-Host "~~ Check out " -NoNewline -ForegroundColor Green;
    Write-Host "admindroid.com" -ForegroundColor Yellow -NoNewline;
    Write-Host " to access 3,000+ reports and 450+ management actions across your Microsoft 365 environment. ~~" -ForegroundColor Green `n`n
}

Installation-Module

if ($SiteUrl -eq "") {
    $SiteUrl = Read-Host "Enter Sharepoint site URL"
    if ($SiteUrl.EndsWith("/")) {
        $SiteUrl = $SiteUrl.TrimEnd("/")
    }
}

if ($ClientId -eq "") {
    $ClientId = Read-Host "ClientId is required to connect PnP PowerShell. Enter ClientId"
}

if ($FilePath -eq "" -and $FolderPath -eq "" -and $LibraryName -eq "" -and -not $SiteLevel) {
    $FilePath = Read-Host "Enter file path to cleanup versions"
    if ($FilePath -eq "") { 
        write-Host "File path is required to delete its versions or mention library name/folder path using available parameters." -ForegroundColor Yellow
        message
        Exit
    }
}

if (-not $SpecificVersionsToDelete -and -not $SpecificVersionsToKeep -and -not $KeepMajorCount -and -not $KeepMinorCount -and -not $KeepTopVersionCount -and -not $DeleteDateFrom -and -not $DeleteDateTo -and -not $VersionsCreatedBy) {
    $KeepTopVersionCount = [int](Read-Host "`nEnter the number of recent versions to keep (older versions will be removed)")
}

Connect_SharePoint -Url $SiteUrl

$CurrentDate = Get-Date -Format "yyyy-MMM-dd-ddd_hh-mm-ss_tt"
$OutputCSV = "$(Get-Location)\SPO_Version_Cleanup_Log_$CurrentDate.csv"

if ($FilePath) {
    try {
        $RelativeFilePath = Convert-ToServerRelativeUrl -InputUrl $FilePath
        Write-Progress -Activity "Processing file" -Status $RelativeFilePath -PercentComplete 100
        Cleanup-FileVersions -FileRelativeUrl $RelativeFilePath -SpecificVersionsToDelete $SpecificVersionsToDelete -SpecificVersionsToKeep $SpecificVersionsToKeep -VersionsCreatedBy $VersionsCreatedBy -DeleteDateFrom $DeleteDateFrom -DeleteDateTo $DeleteDateTo -KeepMajorCount $KeepMajorCount -KeepMinorCount $KeepMinorCount -KeepTopVersionCount $KeepTopVersionCount
    }
    catch {
        LogEntry -FileRelativeUrl $FilePath -Status "Failed" -ErrorDetails $_.Exception.Message
    }
}
elseif ($FolderPath) {
    try {
        $targetFolder = Convert-ToServerRelativeUrl -InputUrl $FolderPath
        Write-Host "`nProcessing files from folder: $targetFolder" -ForegroundColor Cyan
        $folder = Get-PnPFolder -Url $targetFolder -ErrorAction Stop
        $folderItem = Get-PnPProperty -ClientObject $folder -Property ListItemAllFields

        $list = Get-PnPProperty -ClientObject $folderItem -Property ParentList

        Get-PnPListItem -List $list.Id -FolderServerRelativeUrl $targetFolder -PageSize 500 -Fields "FileRef", "FSObjType", "FileLeafRef" | Where-Object { $_["FSObjType"] -eq 0 } | ForEach-Object {
            $RelativeFilePath = $_["FileRef"]
            Write-Progress -Activity "Processing file" -Status $_["FileLeafRef"] -PercentComplete 100
            Cleanup-FileVersions -FileRelativeUrl $RelativeFilePath -SpecificVersionsToDelete $SpecificVersionsToDelete -SpecificVersionsToKeep $SpecificVersionsToKeep -VersionsCreatedBy $VersionsCreatedBy -DeleteDateFrom $DeleteDateFrom -DeleteDateTo $DeleteDateTo -KeepMajorCount $KeepMajorCount -KeepMinorCount $KeepMinorCount -KeepTopVersionCount $KeepTopVersionCount -Filename $_["FileLeafRef"]
        }
    }
    catch {
        LogEntry -FileRelativeUrl $FolderPath -Status "Failed" -ErrorDetails $_.Exception.Message
    }
}
else {
    try {
        if ([string]::IsNullOrEmpty($LibraryName)) {
            if ($SiteLevel) {
                $ExcludedLists = @("Form Templates", "Style Library", "Site Assets", "Site Pages", "Preservation Hold Library", "Pages", "Images", "Site Collection Documents", "Site Collection Images")
                $DocumentLibraries = Get-PnPList | Where-Object { $_.Hidden -eq $False -and $_.Title -notin $ExcludedLists -and $_.BaseType -eq "DocumentLibrary" }
            }
        }
        else {
            $DocumentLibraries = @(Get-PnPList -Identity $LibraryName -ErrorAction Stop)
        }

        foreach ($list in $DocumentLibraries) {
            Write-Progress -Activity "Processing Library" -Status $list.Title -PercentComplete 100

            Get-PnPListItem -List $list.Id -PageSize 500 -Fields "FileRef", "FSObjType", "FileLeafRef" | Where-Object { $_["FSObjType"] -eq 0 } | ForEach-Object { 
                $RelativeFilePath = $_["FileRef"] 
                Write-Progress -Activity "Processing file" -Status $_["FileLeafRef"] -PercentComplete 100
                Cleanup-FileVersions -FileRelativeUrl $RelativeFilePath -SpecificVersionsToDelete $SpecificVersionsToDelete -SpecificVersionsToKeep $SpecificVersionsToKeep -VersionsCreatedBy $VersionsCreatedBy -DeleteDateFrom $DeleteDateFrom -DeleteDateTo $DeleteDateTo -KeepMajorCount $KeepMajorCount -KeepMinorCount $KeepMinorCount -KeepTopVersionCount $KeepTopVersionCount -Filename $_["FileLeafRef"]
            }
        }
    }
    catch {
        LogEntry -FileRelativeUrl $LibraryName -Status "Failed" -ErrorDetails $_.Exception.Message
    }
}

if ((Test-Path -Path $OutputCSV) -eq "True") {   
    Write-Host `n"The log file is available at:" -NoNewline -ForegroundColor Yellow; Write-Host " $OutputCSV" `n 
    message
    $Prompt = New-Object -ComObject wscript.shell    
    $UserInput = $Prompt.popup("Do you want to open the log file?", 0, "Open log File", 4)   
    If ($UserInput -eq 6) { Invoke-Item $OutputCSV }  
}

Disconnect-PnPOnline -WarningAction SilentlyContinue
