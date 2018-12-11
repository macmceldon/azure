<#
    .DESCRIPTION
        A baseline template runbook that uses the AzureRunAsConnection
        Service Prinipal as execution context. 
    .NOTES
        AUTHOR: Mac McEldon
        LASTEDIT: October, 2018
        HAVE YOU INSTALLED MODULES IN AZURE ?
#>

Param(
    [Parameter(Mandatory=$false)]
    [String]$myParam
)
Get-AzureRmAutomationConnection -
#region ### CONNECT CONTEXT ###
    try
    {
        # Get the connection "AzureRunAsConnection "
        $spConnection=Get-AutomationConnection -Name 'AzureRunAsConnection'         

        "Establishing Connection Context"
        Add-AzureRmAccount `
            -ServicePrincipal `
            -TenantId $spConnection.TenantId `
            -ApplicationId $spConnection.ApplicationId `
            -CertificateThumbprint $spConnection.CertificateThumbprint 
    }
    catch {
        if (!$spConnection)
        {
            $ErrorMessage = "Connection not found"
            throw $ErrorMessage
        } else{
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }
#endregion

    Write-Output ("FINISHED: " + $myParam)