#!/bin/bash

#For os-type: osinfo-query os | grep -i ubuntu
#on local system: QK=qemu:///system

NO=14
virt-install --connect $QK \
--name "node-06-$NO" \
--metadata title="06-$NO WindowsServer",description="06-$NO WindowsServer" \
--ram=12144 --vcpus=2 \
--os-type=windows --os-variant=win2k16 \
--disk path=/mnt/storage1/sp/sp1/06-$NO.qcow2,bus=virtio,cache=none,size=100 \
--disk /mnt/storage1/sp/install-images/win-server-1903.iso,device=cdrom,bus=ide \
--graphics spice \
--network bridge=br0,model=virtio,mac=54:52:00:00:06:$NO \
--cdrom /mnt/storage1/sp/install-images/virtio-win-0.1.171.iso

#During installation on the Hard Disk selection screen, select "Load Driver"
#And browse to the virtio-win cd > viostor > 2k19 > amd64. 
# Install viostor, vioserial, NetKVM, qxldod, Baloon subsequently
#After windows installation, install guest-agent (msi installer)
#> Drivers description: https://access.redhat.com/articles/2470791#installing-the-kvm-windows-virtio-drivers-5

#To destroy VM:
# virsh -c $QK destroy node-06-$NO; virsh -c $QK undefine node-06-$NO; virsh -c $QK pool-refresh sp1; virsh -c $QK vol-delete --pool sp1 06-$NO.qcow2

#>https://docs.microsoft.com/en-in/virtualization/windowscontainers/quick-start/quick-start-windows-server

#Install docker
PowerShell
Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
Install-Package -Name docker -ProviderName DockerMsftProvider
Restart-Computer -Force

#If there is a download error in second step, download manually
mkdir C:\Users\Administrator\AppData\Local\Temp
mkdir C:\Users\Administrator\AppData\Local\Temp\DockerMsftProvider
Start-BitsTransfer -Source https://dockermsft.blob.core.windows.net/dockercontainer/docker-19-03-1.zip -Destination C:\Users\ADMINI~1\AppData\Local\Temp\DockerMsftProvider\Docker-19-03-1.zip
Get-FileHash -Path C:\Users\ADMINI~1\AppData\Local\Temp\DockerMsftProvider\Docker-19-03-1.zip -Algorithm SHA256
Install-Package -Name docker -ProviderName DockerMsftProvider -Verbose

#Test
docker run microsoft/dotnet-samples:dotnetapp-nanoserver-1809
