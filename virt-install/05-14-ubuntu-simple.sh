#!/bin/bash

#For os-type: osinfo-query os | grep -i ubuntu
#on local system: QK=qemu:///system

virt-install --connect $QK \
--name "node-05-14" \
--metadata title="05-14 Ubuntu Simple Server",description="05-14 Ubuntu Simple Server" \
--ram=4096 --vcpus=2 \
--os-type=linux --os-variant=ubuntu18.04 \
--disk path=/mnt/storage1/sp/sp1/05-14.qcow2,bus=virtio,size=75 \
--graphics none \
--console pty,target_type=serial \
--network bridge=br0,model=virtio,mac=54:52:00:00:05:14 \
--location /mnt/storage1/sp/install-images/ubuntu-18.04.2-server-amd64.iso \
--extra-args 'console=ttyS0,115200n8 serial'

virsh -c $QK autostart node-05-14

#To destroy VM:
# virsh -c $QK destroy node-05-14; virsh -c $QK undefine node-05-14; virsh -c $QK pool-refresh sp1; virsh -c $QK vol-delete --pool sp1 05-14.qcow2

# virsh vol-create-as sp1 05-14.qcow2 100G
# virt-clone --connect qemu:///system \
# --original 05-14 \
# --name node-05-14 \
# --file /mnt/storage1/sp/sp1/05-14.qcow2 \
# --mac 54:52:00:00:05:14
