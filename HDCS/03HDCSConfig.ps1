<#
    HDCS Operational Lab Environment
	Create Action Alert Group
	Create Action Alert 
#>
Clear-Host
#region ## PARAMS ##
	Clear-Host
	$location = 'eastus2'
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
	-targetSubscription $subId -actionGroupId $actionGroup.Id `
	-metricName 'Percentage CPU'
}
function DeployLogAnalyticsWorkspace(){
	"Deploying Log Analytics Workspace to " + $rgHdcs
	New-AzureRmResourceGroupDeployment -Name 'hdcsLogAnalytics' -ResourceGroupName $rgHdcs `
	-TemplateFile $deployLogAnalyticsTemplatePath -workspaceName 'hdcsAnalytics'
}
function DeployRecoveryServicesVault(){
	"Deploying Recovery Services Vault to " + $rgHdcs
	$rsVault = New-AzureRmRecoveryServicesVault -Name 'hdcsRSVault' `
	-ResourceGroupName $rgHdcs -Location $location
	Set-AzureRmRecoveryServicesBackupProperties -Vault $rsVault -BackupStorageRedundancy LocallyRedundant
}

function CleanUp(){
	#$alert = 
}
#endregion

#region ## EXECUTION ##
"SCRIPT START"
# Step 1. Create Action Group
CreateActionGroup
# Step 2. Create Alert Rule
# CreateAlertRuleForSubscription
# Step 3. Deploy Log Analytics Workspace
DeployLogAnalyticsWorkspace
# Step 4. Deploy Recovery Services Vault
DeployRecoveryServicesVault
#CleanUp
"SCRIPT COMPLETE"
#endregion