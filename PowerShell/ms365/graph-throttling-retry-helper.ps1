function Invoke-GraphWithRetry {
    param(
        [Parameter(Mandatory)] [string] $Uri,
        [Parameter(Mandatory)] [hashtable] $Headers,
        [int] $MaxRetries = 10
    )

    $attempt = 0
    while ($true) {
        try {
            return Invoke-RestMethod -Method Get -Uri $Uri -Headers $Headers
        }
        catch {
            $resp = $_.Exception.Response
            if (-not $resp) { throw }

            $status = [int]$resp.StatusCode
            if ($status -ne 429 -and $status -ne 503) { throw }

            $retryAfter = $resp.Headers["Retry-After"]
            if (-not $retryAfter) { $retryAfter = 5 }

            $sleep = [int]$retryAfter + (Get-Random -Minimum 0 -Maximum 3)
            $attempt++
            if ($attempt -gt $MaxRetries) {
                throw "Graph throttling: exceeded MaxRetries=$MaxRetries for $Uri"
            }

            Start-Sleep -Seconds $sleep
        }
    }
}
