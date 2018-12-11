<#
    .DESCRIPTION
        Utility script to assist with runbook provisioning
    .NOTES
        AUTHOR: Mac McEldon
        LASTEDIT: October, 2018
#>
# https://sharepointyankee.com/2018/02/26/importing-powershell-modules-into-azure-automation/
Clear-Host

#region PARAMS
    $resourceGroupName = "rg-cs-labsprod"
    #$storageAccountName = "sacslab"
    $automationAccountName = "aa-cs-mac"
    $runbookPath = 'C:\VS\MacsSandbox\Runbook\rb-CreateLinuxVm.ps1'
#endregion

function DeployRunbook(){

    "Deploying Runbook"
    $trimAt = $runbookPath.LastIndexOf('\');
    $name = $runbookPath.Substring($trimAt + 1);
    $name = $name.TrimEnd('.ps1');

    $existingTemplate = Get-AzureRmAutomationRunbook -Name $name `
    -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName `
    -ErrorAction SilentlyContinue

    # Delete existing if exists
    if($existingTemplate){
        "Existing template found..."
        Remove-AzureRmAutomationRunbook -Name $name `
        -ResourceGroupName $resourceGroupName `
        -AutomationAccountName $automationAccountName -Force
    }

    "Uploading Template: " + $name
    $importParams = @{
        Path = $runbookPath
        ResourceGroupName = $resourceGroupName
        AutomationAccountName = $automationAccountName
        Type = 'PowerShell'
    }
    Import-AzureRmAutomationRunbook @importParams

    # Publish the runbook
    Publish-AzureRmAutomationRunbook -ResourceGroupName $resourceGroupName `
    -AutomationAccountName $automationAccountName -Name $name
    "FINISHED Deploying Runbook"
}

"DEBUG COMPLETE"
#DeployRunbook