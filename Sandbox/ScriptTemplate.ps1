<#
    Template for PowerShell
#>

#region ## PARAMS ##
    $location = "eastus2"
#endregion

#region ## SETUP ##

	#The name of the Automation Credential Asset this runbook will use to authenticate to Azure.
    $CredentialAssetName = "DefaultAzureCredential";
	
	#Get the credential with the above name from the Automation Asset store
    $Cred = Get-AutomationPSCredential -Name $CredentialAssetName
    if(!$Cred) {
        Throw "Could not find an Automation Credential Asset named '${CredentialAssetName}'. Make sure you have created one in this Automation Account."
    }  

    #Connect to your Azure Account   	
	Add-AzureRmAccount -Credential $Cred

#endregion


Clear-Host
Write-Output("SCRIPT START")

#region ## FUNCTIONS ##

function CleanUp(){

}

#endregion

#region ## EXECUTION ##

Write-Output("SCRIPT COMPLETE")

#endregion