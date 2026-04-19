$results = @()
$subscriptions = Get-AzSubscription

foreach ($sub in $subscriptions) {
    Write-Host "Processing subscription: $($sub.Name)" -ForegroundColor Cyan
    Set-AzContext -SubscriptionId $sub.Id | Out-Null

    $factories = Get-AzResource -ResourceType "Microsoft.DataFactory/factories"

    foreach ($factory in $factories) {
        try {
            $rgName = $factory.ResourceGroupName
            $dfName = $factory.Name

            $irs = Get-AzDataFactoryV2IntegrationRuntime `
                -ResourceGroupName $rgName `
                -DataFactoryName $dfName

            foreach ($ir in $irs) {
                if ($ir.Type -eq "SelfHosted") {
                    $results += [pscustomobject]@{
                        SubscriptionName   = $sub.Name
                        SubscriptionId     = $sub.Id
                        ResourceGroupName  = $rgName
                        DataFactoryName    = $dfName
                        IntegrationRuntime = $ir.Name
                        IntegrationType    = $ir.Type
                    }
                }
            }
        }
        catch {
            Write-Warning "Failed: Subscription='$($sub.Name)', Factory='$($factory.Name)'. $_"
        }
    }
}

$csvPath = "C:\Temp\ADF_SelfHosted_Runtimes.csv"
$results |
    Sort-Object SubscriptionName, DataFactoryName, IntegrationRuntime |
    Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

Write-Host "Saved to: $csvPath" -ForegroundColor Green
