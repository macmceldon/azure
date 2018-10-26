<#
    Build VNET for LABS
#>
Clear-Host
Write-Output("SCRIPT START")
#region ## PARAMS ##
    #SUBSCRIPTION
    Clear-Host
    #$subscriptionId = "8e2b803f-ef35-4093-97e0-b190a9680de3"
    $location = "eastus2"
    #RESOURCE GROUPS
    $rgNet = "rg-lab-net"
    $rgQa = "rg-lab-qa"
    $rgDev = "rg-lab-dev"
    $rgProd = "rg-lab-prod"
#endregion

#region ## FUNCTIONS ##
function CreateResourceGroups() {
    New-AzureRmResourceGroup -Name $rgNet -Location $location 
    New-AzureRmResourceGroup -Name $rgQa -Location $location
    New-AzureRmResourceGroup -Name $rgDev -Location $location
    New-AzureRmResourceGroup -Name $rgProd -Location $location
}
function CreateVnets(){
    
    # QA #
    $vnetqa = New-AzureRmVirtualNetwork -ResourceGroupName $rgNet -Location $location `
    -Name 'vnet-lab-qa' -AddressPrefix 10.10.0.0/16
    Add-AzureRmVirtualNetworkSubnetConfig -Name 'snet-frontend' -AddressPrefix 10.10.1.0/24 -VirtualNetwork $vnetqa
    Add-AzureRmVirtualNetworkSubnetConfig -Name 'snet-backend' -AddressPrefix 10.10.2.0/24 -VirtualNetwork $vnetqa
    $vnetqa | Set-AzureRmVirtualNetwork

    # DEV #
    $vnetdev = New-AzureRmVirtualNetwork -ResourceGroupName $rgNet -Location $location `
    -Name 'vnet-lab-dev' -AddressPrefix 10.20.0.0/16
    Add-AzureRmVirtualNetworkSubnetConfig -Name 'snet-frontend' -AddressPrefix 10.20.1.0/24 -VirtualNetwork $vnetdev
    Add-AzureRmVirtualNetworkSubnetConfig -Name 'snet-backend' -AddressPrefix 10.20.2.0/24 -VirtualNetwork $vnetdev
    $vnetdev | Set-AzureRmVirtualNetwork

    # PROD #
    $vnetprod = New-AzureRmVirtualNetwork -ResourceGroupName $rgNet -Location $location `
    -Name 'vnet-lab-prod' -AddressPrefix 10.30.0.0/16
    Add-AzureRmVirtualNetworkSubnetConfig -Name 'snet-frontend' -AddressPrefix 10.30.1.0/24 -VirtualNetwork $vnetprod
    Add-AzureRmVirtualNetworkSubnetConfig -Name 'snet-backend' -AddressPrefix 10.30.2.0/24 -VirtualNetwork $vnetprod
    $vnetprod | Set-AzureRmVirtualNetwork

    Write-Output("CreateVnets Done")
}
function CleanUp(){
    #$lockId = (Get-AzureRmResourceLock -ResourceGroupName $rgNet -ResourceName LockNetworkResourceGroup -ResourceType Microsoft.Authorization/locks).LockId
    #Remove-AzureRmResourceLock -LockId $lockId
    Remove-AzureRmResourceGroup -Name $rgNet -Force -Verbose
    Remove-AzureRmResourceGroup -Name $rgQa -Force -Verbose
    Remove-AzureRmResourceGroup -Name $rgDev -Force -Verbose
    Remove-AzureRmResourceGroup -Name $rgProd -Force -Verbose
}
function LockResourceGroups{
    # https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-lock-resources
    New-AzureRmResourceLock -LockName LockNetworkResourceGroup -LockLevel CanNotDelete -ResourceGroupName $rgNet -Force
    New-AzureRmResourceLock -LockName LockNetworkResourceGroup -LockLevel CanNotDelete -ResourceGroupName $rgQa -Force
    New-AzureRmResourceLock -LockName LockNetworkResourceGroup -LockLevel CanNotDelete -ResourceGroupName $rgDev -Force
    New-AzureRmResourceLock -LockName LockNetworkResourceGroup -LockLevel CanNotDelete -ResourceGroupName $rgProd -Force
}
#endregion

#region ## EXECUTION ##
Write-Output("SCRIPT COMPLETE")
#endregion