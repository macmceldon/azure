<#
    .DESCRIPTION
        HDCS script to deploy storage accounts and utility resources
    .NOTES
        AUTHOR:
        LASTEDIT:
#>
Clear-Host
#region ## PARAMS ##
	Clear-Host
	$location = 'eastus2'
	$rgHdcs = 'rg-lab-hdcs'
    $storHdcs = 'storlabhdcs01'    
	$tags = @{'SCOPE' = 'HDCS'; 'CATI-ID' = 'CATI-XYZ'}
#endregion

#region ## FUNCTIONS ##
function CreateStorageAccounts(){
    
    $exists = Get-AzureRmStorageAccount -ResourceGroupName $rgHdcs `
    -Name $storHdcs -ErrorAction SilentlyContinue
    # Create Storage Account
    if(!$exists)
    {
        $storageAccount = New-AzureRmStorageAccount -ResourceGroupName $rgHdcs `
        -Name $storHdcs `
        -Location $location `
        -SkuName Standard_LRS `
        -Tag $tags `
        -Kind Storage -ErrorAction SilentlyContinue

        $ctx = $storageAccount.Context
	
        # Create Containers
        $containerName = 'hdcs-assets'
        New-AzureStorageContainer -Name $containerName -Context $ctx -Permission blob
    } 
    else
    {
        "Storage Account Already Exists - Please Check"
    }
    
    # Upload files to FileShare
    # upload a file
    #Set-AzureStorageBlobContent -File $pathToAsset -Container $containerName -Blob "configrhel.sh" -Context $ctx
}

function CleanUp(){
	$exists = Get-AzureRmStorageAccount -Name $storHdcs -ResourceGroupName $rgHdcs -ErrorAction SilentlyContinue
    if($exists){
        "Removing Storage Account"
        Remove-AzureRmStorageAccount -Name $storHdcs -ResourceGroupName $rgHdcs -Force -Verbose
    }
}
#endregion

#region ## EXECUTION ##
"SCRIPT START"
# Step 1. Create Storage Accounts
CreateStorageAccounts
#CleanUp
"SCRIPT COMPLETE"
#endregion