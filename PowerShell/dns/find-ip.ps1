$IpAddress = "192.168.1.100"
$DNSServer = "."

$Zones = Get-DnsServerZone -ComputerName $DNSServer

$Results = foreach ($Zone in $Zones) {
    Get-DnsServerResourceRecord -ZoneName $Zone.ZoneName -ComputerName $DNSServer |
        Where-Object { $_.RecordData.IPv4Address.IPAddressToString -eq $IpAddress } |
        Select-Object @{ Name = "Zone"; Expression = { $Zone.ZoneName } },
                      HostName,
                      RecordType,
                      @{ Name = "IPAddress"; Expression = { $_.RecordData.IPv4Address.IPAddressToString } }
}

$Results | Format-Table -AutoSize
