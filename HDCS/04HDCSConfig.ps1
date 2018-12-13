<#
    HDCS Operational Lab Environment
	Deploy Policies
 	#https://docs.microsoft.com/en-us/azure/governance/policy/assign-policy-powershell
#>
Clear-Host
#region ## PARAMS ##
	Clear-Host
	$location = 'eastus2'
	#$PolicyParamFilePath = 'MetricsAndLogs\AlertAllVms.params.json'
	$PolicyTemplateFilePath = 'HDCS\Policies\01RestrictVmSku.json'
	$rgHdcs = 'rg-lab-hdcs'
#endregion

#region ## FUNCTIONS ##
function DeployPolicies{
	
	$policyName = 'Allowed virtual machine SKUs'
	$subId = '/subscriptions/' + (Get-AzureRmSubscription).Id
	$policyDefinition = Get-AzureRmPolicyDefinition -Id '/providers/Microsoft.Authorization/policyDefinitions/cccc23c7-8427-4f53-ad12-b6a63eb452b3'
	
	#$definition = Get-AzureRmPolicyDefinition | Where-Object { $_.Name -eq 'Allowed virtual machine SKUs' }
	New-AzureRmPolicyAssignment -Name 'restrict-vm-sku' -DisplayName $policyName -Scope $subId `
	-PolicyDefinition $policyDefinition -listOfAllowedSKUs 'Standard_D1','Standard_D2'
}

function CleanUp(){
	#$alert = 
}
#endregion

#region ## EXECUTION ##
"SCRIPT START"
# Step 1. Create Action Group
DeployPolicies
#CleanUp
"SCRIPT COMPLETE"
#endregion