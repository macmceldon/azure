<#
    Build Operational Lab Environment
#>
Clear-Host
Write-Output("SCRIPT START")
#region ## PARAMS ##
    Clear-Host
    $location = "eastus2"
    $rgOps = "rg-lab-ops"
    $rgNet = "rg-lab-net"
    $rgQa = "rg-lab-qa"
    $rgDev = "rg-lab-dev"
    $rgProd = "rg-lab-prod"
    $saOps = "salabops01"
    $sfsOps = "sfs-lab-ops"
    $vnetDevName = "vnet-lab-dev"
#endregion

#region ## FUNCTIONS ##
function CreateResourceGroups() {
    New-AzureRmResourceGroup -Name $rgNet -Location $location 
    New-AzureRmResourceGroup -Name $rgQa -Location $location
    New-AzureRmResourceGroup -Name $rgDev -Location $location
    New-AzureRmResourceGroup -Name $rgProd -Location $location
    New-AzureRmResourceGroup -Name $rgOps -Location $location
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
    -Name $vnetDevName -AddressPrefix 10.20.0.0/16
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
function ConfigureVnetFirewalls($vnet,$rg){

        # Create an inbound network security group rule for port 22
        $nsgRuleSSH = New-AzureRmNetworkSecurityRuleConfig `
        -Name "nsgrule-AllowSsh"  `
        -Protocol "Tcp" `
        -Direction "Inbound" `
        -Priority 1000 `
        -SourceAddressPrefix * `
        -SourcePortRange * `
        -DestinationAddressPrefix * `
        -DestinationPortRange 22 `
        -Access "Allow"
    
        # Create an inbound network security group rule for port 80
        $nsgRuleWeb = New-AzureRmNetworkSecurityRuleConfig `
        -Name "nsgRule-AllowHttp"  `
        -Protocol "Tcp" `
        -Direction "Inbound" `
        -Priority 1001 `
        -SourceAddressPrefix * `
        -SourcePortRange * `
        -DestinationAddressPrefix * `
        -DestinationPortRange 80 `
        -Access "Allow"
        
        # Create a network security group
        $nsg = New-AzureRmNetworkSecurityGroup `
        -ResourceGroupName $rg `
        -Location $location `
        -Name "nsg-subnetfirewall" `
        -SecurityRules $nsgRuleSSH,$nsgRuleWeb

        <#
        $nsg = Get-AzureRmNetworkSecurityGroup `
        -ResourceGroupName $rg `
        -Name "nsg-subnetfirewall"
        #>

        # Associate NSG
        $thisVnet = Get-AzureRmVirtualNetwork -Name $vnet -ResourceGroupName $rg
        $snet = Get-AzureRmVirtualNetworkSubnetConfig -Name 'snet-frontend' -VirtualNetwork $thisVnet
        Set-AzureRmVirtualNetworkSubnetConfig -Name 'snet-frontend' -VirtualNetwork $thisVnet -NetworkSecurityGroup $nsg -AddressPrefix $snet.AddressPrefix
        $thisVnet | Set-AzureRmVirtualNetwork

        Write-Host($snet)
}
function CleanUp(){
    #$lockId = (Get-AzureRmResourceLock -ResourceGroupName $rgNet -ResourceName LockNetworkResourceGroup -ResourceType Microsoft.Authorization/locks).LockId
    #Remove-AzureRmResourceLock -LockId $lockId
    Remove-AzureRmResourceGroup -Name $rgNet -Force -Verbose
    Remove-AzureRmResourceGroup -Name $rgQa -Force -Verbose
    Remove-AzureRmResourceGroup -Name $rgDev -Force -Verbose
    Remove-AzureRmResourceGroup -Name $rgProd -Force -Verbose
    Remove-AzureRmResourceGroup -Name $rgOps -Force -Verbose
}
function LockResourceGroups{
    # https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-lock-resources
    New-AzureRmResourceLock -LockName LockNetworkResourceGroup -LockLevel CanNotDelete -ResourceGroupName $rgNet -Force
    New-AzureRmResourceLock -LockName LockNetworkResourceGroup -LockLevel CanNotDelete -ResourceGroupName $rgQa -Force
    New-AzureRmResourceLock -LockName LockNetworkResourceGroup -LockLevel CanNotDelete -ResourceGroupName $rgDev -Force
    New-AzureRmResourceLock -LockName LockNetworkResourceGroup -LockLevel CanNotDelete -ResourceGroupName $rgProd -Force
}
function CreateOpsFileResources(){
    
    # Create Storage Account
    $storageAccount = Get-AzureRmStorageAccount -Name $saOps -ResourceGroupName $rgOps `
    -ErrorAction SilentlyContinue

    if(!$storageAccount){
        $storageAccount = New-AzureRmStorageAccount -ResourceGroupName $rgOps `
        -Name $saOps `
        -Location $location `
        -SkuName Standard_LRS `
        -Kind Storage
    }

    # Create File Share
    # https://salabops01.file.core.windows.net/
    New-AzureStorageShare `
    -Name $sfsOps `
    -Context $storageAccount.Context

    New-AzureStorageDirectory `
    -Context $storageAccount.Context `
    -ShareName $sfsOps `
    -Path "VmCustomScripts"

    New-AzureStorageDirectory `
    -Context $storageAccount.Context `
    -ShareName $sfsOps `
    -Path "ResourceTemplates"

    # Upload files to FileShare
    # WIN Template
    # Linux Template
    # Lnux Sciprt
    # Win Script
}
#endregion

#region ## EXECUTION ##
ConfigureVnetFirewalls -vnet 'vnet-lab-dev' -rg 'rg-lab-net'
Write-Output("SCRIPT COMPLETE")
#endregion