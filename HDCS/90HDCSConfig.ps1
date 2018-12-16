<#
    HDCS Operational Lab Environment
	VM Creation
#>
Clear-Host
#region ## PARAMS ##
	Clear-Host
	$deployVmParamFilePath = 'HDCS\Resources\rhel.params.json'
	$deployVmTemplateFilePath = 'HDCS\Resources\rhel.template.json'
	$vnetTarget = 'vnet-lab-dev'
    $rgNet = 'rg-lab-net'
	$rgTarget = 'rg-lab-dev'
	$vmName = 'rhel-10'
#endregion

#region ## FUNCTIONS ##
function CreateVm(){
	Get-AzureRmVirtualNetwork -Name $vnetTarget -ResourceGroupName $rgNet
	$securePassword = ConvertTo-SecureString 'P@ssword!' -AsPlainText -Force

	$ipSuffix = GetRandom;
	$ipSuffix = 'vm-ip-' + $ipSuffix

	$backupItemName = 'vm;iaasvmcontainerv2;' + $rgTarget + ';' + $vmName

 	New-AzureRmResourceGroupDeployment -ResourceGroupName $rgTarget `
	-TemplateFile $deployVmTemplateFilePath -TemplateParameterFile $deployVmParamFilePath `
	-adminPassword $securePassword -virtualMachineName $vmName `
	-networkInterfaceName $ipSuffix -backupItemName $backupItemName
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