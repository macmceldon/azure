<#
    Template for PowerShell
#>

#region ## PARAMS ##
Param(
    [Parameter(Mandatory=$true)]
    [string] $pathToRhelScript = "C:\VS\azure\VirtualMachines\LINUX\configrhel.sh"
)
#endregion

#

Clear-Host
Write-Output("SCRIPT START")

#region ## FUNCTIONS ##

function CleanUp(){

}

#endregion

#region ## EXECUTION ##

Write-Output("SCRIPT COMPLETE")

#endregion