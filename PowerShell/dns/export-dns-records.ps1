$DNSReport =
foreach ($record in Get-DnsServerZone) {
    $DNSInfo = Get-DnsServerResourceRecord $record.ZoneName

    foreach ($info in $DNSInfo) {
        [pscustomobject]@{
            ZoneName   = $record.ZoneName
            HostName   = $info.HostName
            TimeStamp  = $info.TimeStamp
            RecordType = $info.RecordType
            RecordData = if ($info.RecordData.IPv4Address) {
                $info.RecordData.IPv4Address.IPAddressToString
            }
            else {
                try { $info.RecordData.NameServer.ToUpper() } catch {}
            }
        }
    }
}

$DNSReport | Export-Csv "C:\Temp\DNSRecords.csv" -NoTypeInformation
