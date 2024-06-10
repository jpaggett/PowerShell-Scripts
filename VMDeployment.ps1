# Set variables
$resourceGroupName = "myResourceGroup"
$location = "EastUS"
$vmName = "myWindowsVM"
$vmSize = "Standard_DS1_v2"
$adminUsername = "azureuser"
$adminPassword = "P@ssw0rd1234!"
$imagePublisher = "MicrosoftWindowsServer"
$imageOffer = "WindowsServer"
$imageSku = "2019-Datacenter"

# Create Resource Group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create Virtual Network and Subnet
$vnetName = "myVnet"
$subnetName = "mySubnet"
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location -Name $vnetName -AddressPrefix "10.0.0.0/16"
$subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix "10.0.0.0/24" -VirtualNetwork $vnet
$vnet | Set-AzVirtualNetwork

# Retrieve the Subnet ID
$vnet = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Name $vnetName
$subnet = $vnet.Subnets | Where-Object { $_.Name -eq $subnetName }

# Create Public IP Address
$publicIp = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Location $location -Name "myPublicIp" -AllocationMethod Static

# Create Network Security Group (NSG) and Rule
$nsgRule = New-AzNetworkSecurityRuleConfig -Name "default-allow-rdp" -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389 -Access Allow
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Location $location -Name "myNsg" -SecurityRules $nsgRule

# Create Network Interface
$nic = New-AzNetworkInterface -ResourceGroupName $resourceGroupName -Location $location -Name "myNic" -SubnetId $subnet.Id -NetworkSecurityGroupId $nsg.Id -PublicIpAddressId $publicIp.Id

# Specify the VM Image
$image = Get-AzVMImageSku -Location $location -PublisherName $imagePublisher -Offer $imageOffer | Where-Object {$_.Skus -eq $imageSku}

# Create the Virtual Machine Configuration with Specific Settings
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize | `
            Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential (New-Object System.Management.Automation.PSCredential ($adminUsername, (ConvertTo-SecureString $adminPassword -AsPlainText -Force))) | `
            Set-AzVMSourceImage -PublisherName $imagePublisher -Offer $imageOffer -Skus $imageSku -Version "latest" | `
            Add-AzVMNetworkInterface -Id $nic.Id

# Deploy the Virtual Machine
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig
