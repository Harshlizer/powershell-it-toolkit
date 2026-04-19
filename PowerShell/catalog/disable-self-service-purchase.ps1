Install-Module -Name MSCommerce -Scope CurrentUser
Import-Module -Name MSCommerce
Connect-MSCommerce

Get-MSCommerceProductPolicies -PolicyId AllowSelfServicePurchase |
    Where-Object { $_.PolicyValue -eq "Enabled" } |
    ForEach-Object {
        Update-MSCommerceProductPolicy -PolicyId AllowSelfServicePurchase -ProductId $_.ProductID -Enabled $false
    }
