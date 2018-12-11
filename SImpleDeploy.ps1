<#
    Creates LINUX Vm
#>

#region ## PARAMS ##
param(
 [string]
 $resourceGroupName = "rg-lab-dev",

 [string]
 $templateFilePath = "template.noip.json",

 [string]
 $parametersFilePath = "parameters.json"
)
#endregion

Clear-Host
Write-Output("SCRIPT START")
# https://salabops01.blob.core.windows.net/vmscripts/configrhel.sh
#region ## FUNCTIONS ##
function CreateVm(){
    
    Write-Host "Starting deployment...";
    
    if(Test-Path $parametersFilePath) {
        New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -TemplateParameterFile $parametersFilePath;
    } else {
        Test-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath;
    }
}
#endregion

#region ## EXECUTION ##
CreateVm
Write-Output("SCRIPT COMPLETE")
#endregion