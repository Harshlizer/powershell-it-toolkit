# `ms365.cred`

## Create Encrypted Credentials

```powershell
$cred = Get-Credential
$cred | Export-Clixml -Path "C:\bi_report\ms365.cred"
```

The exported file can be decrypted only by the same user on the same machine.

## Import Credentials Later

```powershell
$cred = Import-Clixml -Path "C:\bi_report\ms365.cred"
Connect-MgGraph -Credential $cred -Scopes "User.Read.All","Reports.Read.All"
```
