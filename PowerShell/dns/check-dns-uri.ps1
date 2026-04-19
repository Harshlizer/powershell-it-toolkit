$hostName = "example.com"

while ($true) {
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    try {
        $dns = Resolve-DnsName -Name $hostName -ErrorAction Stop
        $ipList = ($dns | Where-Object { $_.Type -eq "A" }).IPAddress -join ", "
        Write-Host "$time | DNS OK | $hostName -> $ipList" -ForegroundColor Green
    }
    catch {
        Write-Host "$time | DNS ERROR | $hostName does not resolve." -ForegroundColor Red
    }

    Start-Sleep -Seconds 30
}
