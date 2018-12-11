<#
    HDCS Operational Lab Environment
	Deploy Logging & Monitoring 
#>
Clear-Host
Write-Output("SCRIPT START")
#region ## PARAMS ##
	Clear-Host
	$parametersFilePath = 'MetricsAndLogs\AlertAllVms.params.json'
	$templateFilePath = 'MetricsAndLogs\AlertAllVms.json'
	$rgHdcs = 'rg-lab-hdcs'
#endregion

#region ## FUNCTIONS ##
function CreateActionGroup(){
	# Create Email Group Receiver
	$HDCSEmail = New-AzureRmActionGroupReceiver -Name NotifyHdcs -EmailReceiver -EmailAddress 'hdcssupport@credit-suisse.com'
	Set-AzureRmActionGroup -Name 'AlertHdcs' -ResourceGroupName $rgHdcs -ShortName 'AlertHdcs' -Receiver $HdcsEmail
}

function CreateAlertRuleForSubscription(){
	$actionGroup = Get-AzureRmActionGroup -ResourceGroupName $rgHdcs -Name 'AlertHdcs'
	$subId = '/subscriptions/' + (Get-AzureRmSubscription).Id
	New-AzureRmResourceGroupDeployment -ResourceGroupName $rgHdcs -TemplateFile $templateFilePath -TemplateParameterFile $parametersFilePath `
	-targetSubscription $subId -actionGroupId $actionGroup.Id
}

function CleanUp(){
	#$alert = 
}
#endregion

#region ## EXECUTION ##
# Step 1. Create Action Group
CreateActionGroup
# Step 2. Create Alert Rule
CreateAlertRuleForSubscription
#CleanUp
Write-Output("SCRIPT COMPLETE")
#endregion