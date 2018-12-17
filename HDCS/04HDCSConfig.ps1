<#
    .DESCRIPTION
        HDCS script to deploy Deploy & Configure Policies
        AUTHOR:
		LASTEDIT:
	.NOTES
        AUTHOR:
		LASTEDIT:
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
	
	#1 Restrict Vm Selection
	$policy = New-AzureRmPolicyDefinition -Name '01RestrictVmSelectPolicy' `
	-Description 'Restrict VM Selections' -Policy 'HDCS\Policies\01RestrictVmSelect.json'
	New-AzureRmPolicyAssignment -Name '01RestrictVmSelectPolicy' -Scope $subId -PolicyDefinition $policy

	# Restrict deployment locations
	$allowedLocations = '{ "listOfAllowedLocations": { "value": [ "eastus2", "westus", "eastus" ] } }'
	$policy = Get-AzureRmPolicyDefinition -Id '/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c'
	New-AzureRmPolicyAssignment -Name '02RestrictDeploymentLocation' -PolicyParameter $allowedLocations `
	-PolicyDefinition $policy -Scope $subId 

	# Enforce Storage Account Encryption
	$policy = Get-AzureRmPolicyDefinition -Id '/providers/Microsoft.Authorization/policyDefinitions/7c5a74bf-ae94-4a74-8fcf-644d1e0e6e6f'
	New-AzureRmPolicyAssignment -Name '03EnforceStorageAccountEncryption' `
	-PolicyDefinition $policy -Scope $subId
	
	# Enforce Managed Disk Usage
	$policy = New-AzureRmPolicyDefinition -Name '04EnforceUseOfManagedDisks' `
	-Description 'Restrict VM Selections' -Policy 'HDCS\Policies\02EnforceUseOfManagedDisks.json'
	New-AzureRmPolicyAssignment -Name '04EnforceUseOfManagedDisks' -Scope $subId -PolicyDefinition $policy
	$policy = $null
	
	# Enforce Tag Usage
	$policy = New-AzureRmPolicyDefinition -Name '05EnforceTagUsage' `
	-Description 'Restrict VM Selections' -Policy 'HDCS\Policies\05EnforceTagUsage.json'
	New-AzureRmPolicyAssignment -Name '05EnforceTagUsage' -Scope $subId -PolicyDefinition $policy
}

function GetListOfPolicyDefinitions{
	$policyDefinitions = Get-AzureRmPolicyDefinition
	$policyDefinitions | Select-Object -Property {$_.Properties.displayName}, ResourceId, `
	{$_.Properties.description} #| Export-Csv -Path C:\vs\azure\policies.csv
}

function CleanUp(){
	"REMOVING POLICY ASSIGNMENTS"
	Remove-AzureRmPolicyAssignment -Name '01RestrictVmSelectPolicy' -Scope $subId
	Remove-AzureRmPolicyAssignment -Name '02RestrictDeploymentLocation' -Scope $subId
}
function GetRoleDefinitions(){
	Get-AzureRmRoleDefinition | Export-Csv -Path C:\vs\azure\roledefs.csv
}
#endregion
#region ## EXECUTION ##
"SCRIPT START"
# Step 1. Create Action Group
#DeployPolicies
#CleanUp
DefineAndAssignHdcsPolicies
"SCRIPT COMPLETE"
#endregion