$loc = 'southeastasia'

#Create a VM
$rgname = 'resourcegroup01'
$vmsize = 'Standard_A2'
$vmname = 'VM01'

# Setup Storage
$stoname = 'staccvm01'
$stotype = 'Standard_LRS'

#Setup Network
#$staticIP="10.0.0.5"
$SubnetName ='Subnet01'
$VnetName = 'vnet-azure-sea'

#Setup Disk
$osDiskName = $vmname+'_osDisk'
$osDiskCaching = 'ReadWrite'
$osDiskVhdUri = "https://$stoname.blob.core.windows.net/vhds/"+$vmname+"_os.vhd"

#Setup User and Password
$user = "vmadmin"
$password = 'password'

#Get Azure Image
$AzureImages = Get-AzureRmVMImage -Location $loc -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2016-Datacenter" -Version "2016.127.20171116" | Sort-Object Version -Descending
$AzureImage = $AzureImages[0] | Get-AzureRmVMImage

#Get Storage Account
$stoaccount = Get-AzureRmStorageAccount -ResourceGroupName $rgname -Name $stoname

#Get VNet
$vnet = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $rgname

# Create VM Object
$vm = New-AzureRmVMConfig -VMName $vmname -VMSize $vmsize

$subnetId = $vnet.Subnets[0].Id
$pip = New-AzureRmPublicIpAddress -ResourceGroupName $rgname -Name ('pip-' + $vmname)  `
                               -Location $loc -AllocationMethod Dynamic -DomainNameLabel $vmname.ToLower()
$nic = New-AzureRmNetworkInterface -Force -Name ('nic-' + $vmname) -ResourceGroupName $rgname `
              -Location $loc -SubnetId $subnetId -PublicIpAddressId $pip.Id -PrivateIpAddress $staticIP
$nic = Get-AzureRmNetworkInterface -Name ('nic-' + $vmname) -ResourceGroupName $rgname

# Add NIC to VM
$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

# Setup OS & Image
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($user, $securePassword) 
$vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $vmname -Credential $cred
$vm = Set-AzureRmVMSourceImage -VM $vm -PublisherName $AzureImage.PublisherName -Offer $AzureImage.Offer `
                                  -Skus $AzureImage.Skus -Version $AzureImage.Version
$vm = Set-AzureRmVMOSDisk -VM $vm -VhdUri $osDiskVhdUri -name $osDiskName -CreateOption fromImage -Caching $osDiskCaching

# Create Virtual Machine
New-AzureRMVM -ResourceGroupName $rgname -Location $loc -VM $vm