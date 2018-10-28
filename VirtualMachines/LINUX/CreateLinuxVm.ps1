<#
    Creates LINUX Vm
#>

#region ## PARAMS ##
param(
 [string]
 $resourceGroupName = "rg-lab-dev",

 [string]
 $templateFilePath = "template.noscript.json",

 [string]
 $parametersFilePath = "parameters.json"
)
#endregion

Clear-Host
Write-Output("SCRIPT START")

#region ## FUNCTIONS ##
function CreateVm(){
    
    Write-Host "Starting deployment...";
    
    if(Test-Path $parametersFilePath) {
        Test-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -TemplateParameterFile $parametersFilePath;
    } else {
        Test-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath;
    }
}
#endregion

#region ## EXECUTION ##
CreateVm
Write-Output("SCRIPT COMPLETE")
#endregion