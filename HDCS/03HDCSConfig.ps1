<#
    HDCS Operational Lab Environment
	Create Action Alert Group
	Create Action Alert 
#>
Clear-Host
Write-Output("SCRIPT START")
#region ## PARAMS ##
	Clear-Host
	$deployAlertParamFilePath = 'MetricsAndLogs\AlertAllVms.params.json'
	$deployAlertTemplateFilePath = 'MetricsAndLogs\AlertAllVms.json'
	$deployLogAnalyticsTemplatePath = 'MetricsAndLogs\LogAnalyticsWSpace.json'
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
	New-AzureRmResourceGroupDeployment -ResourceGroupName $rgHdcs `
	-TemplateFile $deployAlertTemplateFilePath -TemplateParameterFile $deployAlertParamFilePath `
	-targetSubscription $subId -actionGroupId $actionGroup.Id
}

function DeployLogAnalyticsWorkspace(){
	New-AzureRmResourceGroupDeployment -Name 'workloadLogAnalytics' -ResourceGroupName $rgHdcs `
	-TemplateFile $deployLogAnalyticsTemplatePath -workspaceName 'workloadLogAnalytics'
}

function CleanUp(){
	#$alert = 
}
#endregion

#region ## EXECUTION ##
# Step 1. Create Action Group
#CreateActionGroup
# Step 2. Create Alert Rule
CreateAlertRuleForSubscription
# Step 3. OPTIONAL - Deploy Log Analytics Workspace
#DeployLogAnalyticsWorkspace
#CleanUp
Write-Output("SCRIPT COMPLETE")
#endregion