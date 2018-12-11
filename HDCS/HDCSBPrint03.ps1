<#
    HDCS Operational Lab Environment
	Deploy Logging & Monitoring 
#>
Clear-Host
Write-Output("SCRIPT START")
#region ## PARAMS ##
	Clear-Host
	$rgHdcs = 'rg-lab-hdcs'
#endregion

#region ## FUNCTIONS ##
function CreateActionGroup(){
	# Create Email Group Receiver
	$HDCSEmail = New-AzureRmActionGroupReceiver -Name NotifyHdcs -EmailReceiver -EmailAddress ‘hdcssupport@credit-suisse.com‘
	Set-AzureRmActionGroup -Name ‘AlertHdcs’ -ResourceGroupName $rgHdcs -ShortName ‘Hdcs’ -Receiver $HdcsEmail
}

function CleanUp(){
	#$alert = 
}
#endregion

#region ## EXECUTION ##
# Step 1. Create Action Group
CreateActionGroup
#CleanUp
Write-Output("SCRIPT COMPLETE")
#endregion