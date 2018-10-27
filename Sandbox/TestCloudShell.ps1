<#
 .SYNOPSIS
    Deploys a template to Azure

 .DESCRIPTION
    Deploys an Azure Resource Manager template
#>
#region ## PARAMS ##
param(
 [switch]$clean
)
#endregion

#region ## FUNCTIONS ##

#endregion

#region ## EXECUTION ##

if($clean){
    Write-Output("Removing a test resource group 'rg-delete-me'")
    Remove-AzureRmResourceGroup -Name rg-delete-me -Force -Verbose
}else{
    Write-Output("Adding a test resource group 'rg-delete-me'" )
    New-AzureRmResourceGroup -Name rg-delete-me -Location eastus2
}

#endregion