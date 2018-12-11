<#
    .DESCRIPTION
        A runbook that creates VMs
    .NOTES
        AUTHOR: Mac McEldon
        LASTEDIT: October, 2018
        Set-AzureRmVmCustomScriptExtension is exclusively for WINDOWS OS
        https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/quick-create-powershell
#>

#region PARAMETERS

# INPUT PARAMS
Param(
    [Parameter(Mandatory=$true)]
    [String]$vmName,
    [String]$vmSize = 'Standard_D1'
)

# REQUIRED PARAMS
$targetVnet = 'vnet-prod'
$rgTargetVnet = 'rg-cs-labsnet'
$rgTargetVm = 'rg-cs-labsprod'
$location = 'eastus2'
$pip
$nsg
#endregion

#region FUNCTIONS
function EstablishRuntimeContext(){
    try
    {
        # Get the connection "AzureRunAsConnection "
        $spConnection=Get-AutomationConnection -Name 'AzureRunAsConnection'         

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
}
function CreateVm(){
    # Get PIP & NSG
    $nsg = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $rgTargetVm -Name "nsg-SSHAndWeb"
    $pip = New-AzureRmPublicIpAddress -Name ("pip" + $vmName) -ResourceGroupName $rgTargetVm -Location $location `
    -AllocationMethod Static -IdleTimeoutInMinutes 4

    # Create Required NIC
    $snet = (Get-AzureRmVirtualNetwork -Name $targetVnet -ResourceGroupName $rgTargetVnet).Subnets[0]
    $nicName = 'nic' + $vmName;
    $nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgTargetVm -Location $location `
    -SubnetId $snet.Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

    # Define a credential object
    $securePassword = ConvertTo-SecureString ' ' -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ("mceldon", $securePassword)

    # Create a virtual machine configuration
    # https://docs.microsoft.com/en-us/powershell/module/azurerm.compute/set-azurermvmcustomscriptextension?view=azurermps-6.9.0
    $vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize |`
    Set-AzureRmVMOperatingSystem -Linux -ComputerName $vmName -Credential $cred -DisablePasswordAuthentication |`
    Set-AzureRmVMSourceImage -PublisherName "RedHat" -Offer "RHEL" -Skus "7.4" -Version "latest" |`
    Add-AzureRmVMNetworkInterface -Id $nic.Id

    # Configure SSH Keys
    $sshPublicKey = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8ukRm+9cbE8PfloFXenvj/jrqPThXYWZtG02Glm2e0fdRORDJdfjuX7wnyC5uuDuvo3rE03WXSC1oOE/HFvHM3Q4O3U4R8yj7I/vZem5DNwpHPVKqEobEPUnwTBVXQW0zL9nJWAODOXmEykH4JuulOqQ9BT0EiNNI/P62Hz8mdr6gWpN0IDUXbNY8FeH4qD9yXYaps1iXw0jYwzYidDYRn4kMHF5zyrH3BbnsfFMCLIjNrqoHM6c6wdatXKGeWumAOcKErRllp0J81EBpPSnv3PS2sByuyier8jerrUseTtf5w3nPuJTW9fVl8Eb72OcmBaRPfChZQDXIvLl98UKt macmc@DESKTOP-3D3SJ0U'
    Add-AzureRmVMSshPublicKey -VM $vmconfig -KeyData $sshPublicKey -Path "/home/mceldon/.ssh/authorized_keys"
    
    # Create VM
    New-AzureRmVM -ResourceGroupName $rgTargetVm -Location $location -VM $vmConfig
}
function SetNetworkSecurityGroups(){
    # Create an inbound network security group rule for port 22
    $nsgRuleSSH = New-AzureRmNetworkSecurityRuleConfig -Name "nsgRuleSSH"  -Protocol "Tcp" `
    -Direction "Inbound" -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
    -DestinationPortRange 22 -Access "Allow"

    # Create an inbound network security group rule for port 80
    $nsgRuleWeb = New-AzureRmNetworkSecurityRuleConfig -Name "nsgRuleWWW"  -Protocol "Tcp" `
    -Direction "Inbound" -Priority 1001 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
    -DestinationPortRange 80 -Access "Allow"

    # Create a network security group
    $nsg = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $rgTargetVm -Name "nsg-SSHAndWeb"
    if(!$nsg)
    {
        $nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $rgTargetVm -Location $location `
        -Name "nsg-SSHAndWeb" -SecurityRules $nsgRuleSSH,$nsgRuleWeb
    }    
}
function SetVmCustomExtension{
    #https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-linux
    $TheURI = "https://sacslab.blob.core.windows.net/buildscripts/scriptlinux.sh?st=2018-10-08T10%3A01%3A08Z&se=2018-10-09T10%3A01%3A08Z&sp=rl&sv=2018-03-28&sr=b&sig=o1rRQZynKSHmNbMbpdEfGtntXmyawsa6s4oGicwtN8Y%3D"
    $ScriptSettings = @{"fileUris" = @($TheURI); "commandToExecute" = "sh scriptlinux.sh";}
    Set-AzureRmVMExtension -ResourceGroupName $rgTargetVm -VMName $vmName -Name "customscript" `
     -Publisher "Microsoft.Azure.Extensions" -TypeHandlerVersion 2.0 -ExtensionType 'CustomScript' `
     -Location $location -Settings $ScriptSettings
}
#endregion

#region EXECUTION STEPS
Clear-Host
# Step 1.
"Establishing runtime context"
EstablishRuntimeContext
# Step 2.
"Setting up Network Requirements"
SetNetworkSecurityGroups
# Step 3.
"Creating VM"
CreateVm
# Step 4.
"Custom Extend VM"
SetVmCustomExtension

Login-AzAccount -Subscription 
Connect-AzureRmAccount -Subscription 
Login-AzureRmAccount -Subscription

#endregion