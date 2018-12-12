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

	$ipSuffix = GetRandom;
	$ipSuffix = 'vm-ip-' + $ipSuffix

 	New-AzureRmResourceGroupDeployment -ResourceGroupName $rgDev `
	-TemplateFile $deployVmTemplateFilePath -TemplateParameterFile $deployVmParamFilePath `
	-adminPassword $securePassword -virtualMachineName 'rhel-lab-noip' `
	-networkInterfaceName $ipSuffix
}

function GetRandom(){
	$guid = ([guid]::NewGuid()).tostring()
	return $guid.Substring(0,8)
}
function CleanUp(){
	#$alert = 
}
#endregion

#region ## EXECUTION ##
"SCRIPT START"
# Step 1. Create VM
#GetRandom
CreateVm
#CleanUp
"SCRIPT COMPLETE"
#endregion