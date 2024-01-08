#Create VM

New-AzResourceGroup -Name 'myResourceGroup' -Location 'EastUS'

#VM Details
New-AzVm `
    -ResourceGroupName 'myResourceGroup' `
    -Name 'myVM' `
    -Location 'EastUS' `
    -Image 'MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:latest' `
    -VirtualNetworkName 'myVnet' `
    -SubnetName 'mySubnet' `
    -SecurityGroupName 'myNetworkSecurityGroup' `
    -PublicIpAddressName 'myPublicIpAddress' `
    -OpenPorts 80,3389

Invoke-AzVMRunCommand -ResourceGroupName 'myResourceGroup' -VMName 'myVM' -CommandId 'RunPowerShellScript' -ScriptString 'Install-WindowsFeature -Name Web-Server -IncludeManagementTools'

#Variables
$resourceGroupName = 'myResourceGroup'
$vaultName = 'myRecoveryVault'
$vmName = 'myVM'
$policyName = 'DefaultPolicy'
# Create a Recovery Services Vault

 New-AzRecoveryServicesVault -ResourceGroupName $resourceGroupName -Name $vaultName -Location 'East US'
 Enable-AzRecoveryServicesBackupProtection -ResourceGroupName $resourceGroupName -Name $vmName -Policy (Get-AzRecoveryServicesBackupProtectionPolicy -Name $policyName -VaultId (Get-AzRecoveryServicesVault -ResourceGroupName $resourceGroupName -Name $vaultName).Id) -VaultId (Get-AzRecoveryServicesVault -ResourceGroupName $resourceGroupName -Name $vaultName).Id