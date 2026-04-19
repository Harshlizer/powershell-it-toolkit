$URL = "https://<TENANT_NAME>.sharepoint.com/sites/<SITE_NAME>/Shared%20Documents"
$IESession = Start-Process -FilePath iexplore -ArgumentList $URL -PassThru -WindowStyle Hidden
Start-Sleep 20
$IESession.Kill()
$Network = New-Object -ComObject WScript.Network
$Network.MapNetworkDrive('Z:', $URL)
