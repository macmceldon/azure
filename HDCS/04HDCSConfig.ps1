<#
    HDCS Operational Lab Environment
	Deploy Policies
	 #https://docs.microsoft.com/en-us/azure/governance/policy/assign-policy-powershell
	 #https://docs.microsoft.com/en-us/powershell/module/azurerm.resources/new-azurermpolicydefinition?view=azurermps-6.13.0
#>
Clear-Host
#region ## PARAMS ##
	Clear-Host
	$location = 'eastus2'
	$rgHdcs = 'rg-lab-hdcs'
	$subId = '/subscriptions/' + (Get-AzureRmSubscription).Id
#endregion

#region ## FUNCTIONS ##
function AssignPolicyFromExisting{
	$policyName = 'Allowed virtual machine SKUs'
	$policyDefinition = Get-AzureRmPolicyDefinition -Id '/providers/Microsoft.Authorization/policyDefinitions/cccc23c7-8427-4f53-ad12-b6a63eb452b3'
	New-AzureRmPolicyAssignment -Name 'restrict-vm-sku' -DisplayName $policyName -Scope $subId `
	-PolicyDefinition $policyDefinition -listOfAllowedSKUs 'Standard_D1','Standard_D2'
}
function DefineAndAssignHdcsPolicies{
	$policy = New-AzureRmPolicyDefinition -Name '01RestrictVmSelectPolicy' `
	-Description 'Restrict VM Selections' -Policy 'HDCS\Policies\01RestrictVmSelect.json'
	New-AzureRmPolicyAssignment -Name '01RestrictVmSelectPolicy' -Scope $subId -PolicyDefinition $policy
}

function GetListOfPolicyDefinitions{
	$policyDefinitions = Get-AzureRmPolicyDefinition
	$policyDefinitions | Select-Object -Property {$_.Properties.displayName}, ResourceId, `
	{$_.Properties.description} #| Export-Csv -Path C:\vs\azure\policies.csv
}

function CleanUp(){
	"REMOVING POLICY ASSIGNMENTS"
	Remove-AzureRmPolicyDefinition -Name '02RestrictVmSelectPolicy' -Force
}
#endregion

#region ## EXECUTION ##
"SCRIPT START"
# Step 1. Create Action Group
#DeployPolicies
#CleanUp
DefineHdcsPolicies
"SCRIPT COMPLETE"
#endregion