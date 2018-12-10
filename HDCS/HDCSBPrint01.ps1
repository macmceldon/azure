<#
    HDCS Operational Lab Environment
	Deploy Resource Groups & Virtual Networks
#>
Clear-Host
Write-Output("SCRIPT START")
#region ## PARAMS ##
	Clear-Host
	$location = 'eastus2'
	$rgHdcs = "rg-lab-hdcs"
    $rgNet = "rg-lab-net"
    $rgUat = "rg-lab-uat"
    $rgDev = "rg-lab-dev"
    $rgProd = "rg-lab-prod"

	$vnetUat = 'vnet-lab-uat'
	$vnetDev = 'vnet-lab-dev'
	$vnetProd = 'vnet-lab-prod'
#endregion

#region ## FUNCTIONS ##
function CreateResourceGroups() {

	$rgCollection = $rgHdcs,$rgNet,$rgDev,$rgUat,$rgProd
	foreach($rg in $rgCollection)
	{
		$exists = Get-AzureRmResourceGroup -Name $rg -ErrorAction SilentlyContinue
		
		if($exists)
		{
			"This Resource Group already exists: '" + $rg + "' Check and try again."
		}
		else
		{
			"Creating RG: " + $rg 
			New-AzureRmResourceGroup -Name $rg -Location $location 
		}
	}
}

function CreateVnets(){

	# UAT #
	$newVnet = New-AzureRmVirtualNetwork -ResourceGroupName $rgNet -Location $location `
	-Name $vnetUat -AddressPrefix 10.10.0.0/16 -ErrorVariable $e -ErrorAction Stop	
	if($newVnet)
	{
		"Creating UAT"
		Add-AzureRmVirtualNetworkSubnetConfig -Name 'snet-frontend' -AddressPrefix 10.10.1.0/24 -VirtualNetwork $newVnet
		Add-AzureRmVirtualNetworkSubnetConfig -Name 'snet-backend' -AddressPrefix 10.10.2.0/24 -VirtualNetwork $newVnet
		$newVnet | Set-AzureRmVirtualNetwork
	}
	
	## DEV #
	$newVnet = New-AzureRmVirtualNetwork -ResourceGroupName $rgNet -Location $location `
	-Name $vnetDev -AddressPrefix 10.20.0.0/16
	if($newVnet)
	{		
		"Creating DEV"
		Add-AzureRmVirtualNetworkSubnetConfig -Name 'snet-frontend' -AddressPrefix 10.20.1.0/24 -VirtualNetwork $newVnet
		Add-AzureRmVirtualNetworkSubnetConfig -Name 'snet-backend' -AddressPrefix 10.20.2.0/24 -VirtualNetwork $newVnet
		$newVnet | Set-AzureRmVirtualNetwork
	}

	## PROD #
	$newVnet = New-AzureRmVirtualNetwork -ResourceGroupName $rgNet -Location $location `
	-Name $vnetProd -AddressPrefix 10.30.0.0/16
	if($newVnet)
	{		
		"Creating PROD"
		Add-AzureRmVirtualNetworkSubnetConfig -Name 'snet-frontend' -AddressPrefix 10.30.1.0/24 -VirtualNetwork $newVnet
		Add-AzureRmVirtualNetworkSubnetConfig -Name 'snet-backend' -AddressPrefix 10.30.2.0/24 -VirtualNetwork $newVnet
		$newVnet | Set-AzureRmVirtualNetwork
	}

    Write-Output("CreateVnets Done")
}

function CleanUp(){
	$rgCollection = $rgHdcs,$rgNet,$rgDev,$rgUat,$rgProd
	foreach($rg in $rgCollection)
	{
		Remove-AzureRmResourceGroup -Name $rg -Force -Verbose	
	}
}
#endregion

#region ## EXECUTION ##
# Step 1. Create Resource Groups
CreateResourceGroups
# Step 2. Create Vnets in Network Resource Group
CreateVnets
#CleanUp
Write-Output("SCRIPT COMPLETE")
#endregion