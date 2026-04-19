# Search SKU in Microsoft Graph

```powershell
Import-Module Microsoft.Graph.Authentication
Connect-MgGraph -Scopes "Organization.Read.All"
Get-MgContext

Get-MgSubscribedSku | Select `
    SkuPartNumber,
    SkuId,
    ConsumedUnits,
    @{
        Name = "TotalUnits"
        Expression = { $_.PrepaidUnits.Enabled }
    }
```
