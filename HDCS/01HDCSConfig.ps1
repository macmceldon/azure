<#
    .DESCRIPTION
        HDCS script to mock up an environment handed over after provisioning
    .NOTES
        AUTHOR:
        LASTEDIT:
#>
Clear-Host
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
	#$rgDev,$rgUat,$rgProd,$rgHdcs,$rgNet
	$rgCollection = $rgDev,$rgUat,$rgProd,$rgHdcs
	foreach($rg in $rgCollection)
	{
		$exists = Get-AzureRmResourceGroup -Name $rg -ErrorAction SilentlyContinue
		if($exists)
		{
			"Removing: " + $rg
			Remove-AzureRmResourceGroup -Name $rg -Force -Verbose
		}			
	}
}
#endregion

#region ## EXECUTION ##
"SCRIPT START"
# Step 1. Create Resource Groups
#CreateResourceGroups
# Step 2. Create Vnets in Network Resource Group
#CreateVnets
CleanUp
"SCRIPT COMPLETE"
#endregion