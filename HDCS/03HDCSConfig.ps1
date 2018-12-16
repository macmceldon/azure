<#
    .DESCRIPTION
        HDCS script to deploy Deploy & Configure Metrics Logging & Alerting resources
    .NOTES
        AUTHOR:
        LASTEDIT:
#>
Clear-Host
#region ## PARAMS ##
	Clear-Host
	$location = 'eastus2'
	$deployAlertParamFilePath = 'HDCS\Resources\alerts.params.json'
	$deployAlertTemplateFilePath = 'HDCS\Resources\alerts.template.json'
	$deployLogAnalyticsTemplatePath = 'HDCS\Resources\logAnalytics.template.json'
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

	# Daily Backup 1700 UTC 42 Day Retention
	"Deploying Recovery Services Vault to " + $rgHdcs
	$rsVault = Get-AzureRmRecoveryServicesVault -Name 'hdcsRSVault' -ResourceGroupName 'rg-lab-hdcs' -ErrorAction SilentlyContinue
	if(!$rsVault){
		$rsVault = New-AzureRmRecoveryServicesVault -Name 'hdcsRSVault' `
		-ResourceGroupName $rgHdcs -Location $location
		# NOTE - Adjust to GeoRedundant to give DR capability (at cost)
		Set-AzureRmRecoveryServicesBackupProperties -Vault $rsVault -BackupStorageRedundancy LocallyRedundant
	}
	Set-AzureRmRecoveryServicesVaultContext -Vault $rsVault
	
	#Adjust default policy to 42 days
	$RetPol = Get-AzureRmRecoveryServicesBackupRetentionPolicyObject -WorkloadType "AzureVM"
	$RetPol.IsWeeklyScheduleEnabled = $false
	$RetPol.IsMonthlyScheduleEnabled = $false
	$RetPol.IsYearlyScheduleEnabled = $false
	$RetPol.DailySchedule.DurationCountInDays = 42
	$Pol = Get-AzureRmRecoveryServicesBackupProtectionPolicy -Name "DefaultPolicy"
	Set-AzureRmRecoveryServicesBackupProtectionPolicy -Policy $Pol -RetentionPolicy $RetPol
}

function CleanUp(){
	#$alert = 
}
#endregion

#region ## EXECUTION ##
"SCRIPT START"
# Step 1. Create Action Group
#CreateActionGroup
# Step 2. Create Alert Rule
# CreateAlertRuleForSubscription
# Step 3. Deploy Log Analytics Workspace
#DeployLogAnalyticsWorkspace
# Step 4. Deploy Recovery Services Vault
DeployRecoveryServicesVault
#CleanUp
"SCRIPT COMPLETE"
#endregion