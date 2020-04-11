#!/bin/bash

#For os-type: osinfo-query os | grep -i ubuntu
#on local system: QK=qemu:///system

NO=15

virt-install --connect $QK \
--name "node-05-$NO" \
--metadata title="05-$NO Ubuntu Simple Server",description="05-$NO Ubuntu Simple Server" \
--ram=8192 --vcpus=4 \
--os-type=linux --os-variant=ubuntu18.04 \
--disk path=/mnt/storage1/sp/sp1/05-$NO.qcow2,bus=virtio,size=75 \
--disk  /mnt/storage1/sp/install-images/linuxmint-19.1-cinnamon-64bit.iso,device=cdrom,bus=ide \
--graphics spice \
--console pty,target_type=serial \
--network bridge=br0,model=virtio,mac=54:52:00:00:05:$NO

virsh -c $QK autostart node-05-$NO

#To destroy VM:
# virsh -c $QK destroy node-05-$NO; virsh -c $QK undefine node-05-$NO; virsh -c $QK pool-refresh sp1; virsh -c $QK vol-delete --pool sp1 05-$NO.qcow2

# virsh vol-create-as sp1 05-$NO.qcow2 100G
# virt-clone --connect qemu:///system \
# --original 05-$NO \
# --name node-05-$NO \
# --file /mnt/storage1/sp/sp1/05-$NO.qcow2 \
# --mac 54:52:00:00:05:$NO
