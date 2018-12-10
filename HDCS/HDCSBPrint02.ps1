<#
    HDCS Operational Lab Environment
	Deploy HDCS Baseline Resources
#>
Clear-Host
Write-Output("SCRIPT START")
#region ## PARAMS ##
	Clear-Host
	$location = 'eastus2'
	$rgHdcs = 'rg-lab-hdcs'
	$storHdcs = 'storlabhdcs01'
#endregion

#region ## FUNCTIONS ##
function CreateStorageAccounts(){
    
    # Create Storage Account
    $storageAccount = Get-AzureRmStorageAccount -Name $storHdcs -ResourceGroupName $rgHdcs

    if(!$storageAccount){
        $storageAccount = New-AzureRmStorageAccount -ResourceGroupName $rgHdcs `
        -Name $storHdcs `
        -Location $location `
        -SkuName Standard_LRS `
        -Kind Storage
    }

	$ctx = $storageAccount.Context
	
    # Create Containers
    $containerName = 'hdcs-assets'
    New-AzureStorageContainer -Name $containerName -Context $ctx -Permission blob

    # Upload files to FileShare
    # upload a file
    #Set-AzureStorageBlobContent -File $pathToAsset -Container $containerName -Blob "configrhel.sh" -Context $ctx
}

function CleanUp(){
	$storageAccount = Get-AzureRmStorageAccount -Name $storHdcs -ResourceGroupName $rgHdcs -ErrorAction SilentlyContinue

    if($storageAccount){
        Remove-AzureRmStorageAccount -Name $storHdcs -ResourceGroupName $rgHdcs -Force -Verbose
    }
}
#endregion

#region ## EXECUTION ##
# Step 1. Create Storage Accounts
CreateStorageAccounts
#CleanUp
Write-Output("SCRIPT COMPLETE")
#endregion