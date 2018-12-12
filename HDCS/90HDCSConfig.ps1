<#
    HDCS Operational Lab Environment
	VM Creation
#>
Clear-Host
#region ## PARAMS ##
	Clear-Host
	$deployVmParamFilePath = 'HDCS\ARM\rhel.params.json'
	$deployVmTemplateFilePath = 'HDCS\ARM\rhel.template.json'
	$vnetDev = 'vnet-lab-dev'
    $rgNet = 'rg-lab-net'
    $rgDev = 'rg-lab-dev'
#endregion

#region ## FUNCTIONS ##
function CreateVm(){
	Get-AzureRmVirtualNetwork -Name $vnetDev -ResourceGroupName $rgNet
	$securePassword = ConvertTo-SecureString 'P@ssword!' -AsPlainText -Force

 	New-AzureRmResourceGroupDeployment -ResourceGroupName $rgDev -Name 'deploy' `
	-TemplateFile $deployVmTemplateFilePath -TemplateParameterFile $deployVmParamFilePath `
	-adminPassword $securePassword -virtualMachineName 'rhel-lab-noip'
}
function CleanUp(){
	#$alert = 
}
#endregion

#region ## EXECUTION ##
"SCRIPT START"
# Step 1. Create VM
CreateVm
#CleanUp
"SCRIPT COMPLETE"
#endregion