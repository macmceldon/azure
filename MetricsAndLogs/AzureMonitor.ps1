Clear-Host
#region ## PARAMS ##
#https://docs.microsoft.com/en-us/azure/monitoring-and-diagnostics/monitoring-create-metric-alerts-with-templates
Clear-Host
$location = 'eastus2'
$rgHdcs = 'rg-lab-hdcs'
$storHdcs = 'storlabhdcs01'
#endregion
#https://docs.microsoft.com/en-us/powershell/module/azurerm.insights/get-azurermmetricdefinition?view=azurermps-6.13.0
$resource = Get-AzureRmResource -Name 'rhel-lab-01' -ResourceGroupName 'rg-lab-dev'
$metrics = Get-AzureRmMetricDefinition -ResourceId $resource.ResourceId
$metrics | Select-Object -Property Unit, PrimaryAggregationType, {$_.Name.Value} #| Export-Csv -Path C:\vs\azure\out.csv

Add-AzureRmMetricAlertRule -Name vmcpu_gt_1 -Location "East US" -ResourceGroup 'rg-lab-dev' -TargetResourceId $resource.Id `
    -MetricName "Percentage CPU" -Operator GreaterThan -Threshold 1 `
    -WindowSize 00:05:00 -TimeAggregationOperator Average -Actions `
    $actionEmail, $actionWebhook -Description "alert on CPU > 1%"

Get-AzureRmAlertRule -Name vmcpu_gt_1 -ResourceGroup myrg1 -DetailedOutput

$sub = Get-AzureRmSubscription

$sub.Id

Get-AzureRmActionGroup | Select-Object Name
Get-AzureRmAlertRule -ResourceGroupName 'rg-lab-hdcs' | Select-Object Name

$HDCSEmail = New-AzureRmActionGroupReceiver -Name NotifyHdcs -EmailReceiver -EmailAddress ‘mac.mceldon@outlook.com‘
Set-AzureRmActionGroup -Name ‘NotifyHdcs’ -ResourceGroupName ‘rg-lab-hdcs’ -ShortName ‘Hdcs’ -Receiver $HdcsEmail
$actionGrpId = Get-AzureRmActionGroup -Name 'NotifyHdcs' -ResourceGroupName 'rg-lab-hdcs'
$actionGrpId.Id

Clear-Host


