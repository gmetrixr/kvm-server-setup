#!/bin/bash

#For os-type: osinfo-query os | grep -i ubuntu
#on local system: QK=qemu:///system

virt-install --connect $QK \
--name "node-05-18" \
--metadata title="05-18 Windows",description="05-18 Windows" \
--ram=8096 --vcpus=2 \
--os-type=windows --os-variant=win10 \
--disk path=/mnt/storage1/sp/sp1/05-18.qcow2,bus=virtio,cache=none,size=100 \
--disk /mnt/storage1/sp/install-images/Win10_1903_V1_English_x64.iso,device=cdrom,bus=ide \
--graphics spice \
--network bridge=br0,model=virtio,mac=54:52:00:00:05:18 \
--cdrom /mnt/storage1/sp/install-images/virtio-win-0.1.171.iso

#During installation on the Hard Disk selection screen, select "Load Driver"
#And browse to the virtio-win cd > viostor > w10 > amd64. Also install NetKVM, qxldod subsequently
#After windows installation, install guest-agent (msi installer)

#To destroy VM:
# virsh -c $QS destroy node-05-18; virsh -c $QS undefine node-05-18; virsh -c $QS pool-refresh sp1; virsh -c $QS vol-delete --pool sp1 05-18.qcow2
