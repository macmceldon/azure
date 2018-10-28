<#
    Template for PowerShell
#>

#region ## PARAMS ##
param(
 [string]
 $resourceGroupName = "rg-lab-dev",
 [string]
 $location = "eastus2"
)
#endregion

Clear-Host
Write-Output("SCRIPT START")

#region ## FUNCTIONS ##
function CreateNsgAndRules(){
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
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -Name "nsg-subnetfirewall" `
    -SecurityRules $nsgRuleSSH,$nsgRuleWeb
}

#endregion

#region ## EXECUTION ##

Write-Output("SCRIPT COMPLETE")

#endregion