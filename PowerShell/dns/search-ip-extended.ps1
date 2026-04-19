$SearchIP = "<IP_ADDRESS>"

$AllZones = Get-DnsServerZone

$Results = foreach ($Zone in $AllZones) {
    Write-Progress -Activity "Scanning zones" -Status "Checking: $($Zone.ZoneName)"

    Get-DnsServerResourceRecord -ZoneName $Zone.ZoneName | Where-Object {
        ($_.RecordType -eq "A" -and $_.RecordData.IPv4Address -eq $SearchIP) -or
        ($_.RecordData.ToString() -like "*$SearchIP*")
    } | Select-Object HostName, RecordType,
        @{ Name = "Zone"; Expression = { $Zone.ZoneName } },
        @{ Name = "Details"; Expression = { $_.RecordData.ToString() } }
}

if ($Results) {
    $Results | Out-GridView -Title "DNS records found for $SearchIP"
}
else {
    Write-Host "No records were found, even with extended search." -ForegroundColor Red
}
