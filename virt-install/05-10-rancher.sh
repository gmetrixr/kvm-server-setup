#!/bin/bash

#For os-type: osinfo-query os | grep -i ubuntu

virt-install --connect $QK \
--name "node-05-10" \
--metadata title="05-10 Rancher",description="05-10 Rancher" \
--ram=8096 --vcpus=2 \
--os-type=linux --os-variant=rhel7 \
--disk path=/mnt/storage1/sp/sp1/05-10.qcow2,bus=virtio,size=75 \
--graphics none \
--console pty,target_type=serial \
--network bridge=br0,model=virtio,mac=54:52:00:00:05:10 \
--cdrom /mnt/storage1/sp/install-images/rancheros-v1.4.3.iso

#Copy cloud-config.yml using vi and type:
# sudo ros install -f -c cloud-config.yml -d /dev/vda

# virsh -c $QK destroy node-05-10; virsh -c $QK undefine node-05-10; virsh -c $QK pool-refresh sp1; virsh -c $QK vol-delete --pool sp1 05-10.qcow2

## From local system: Setting up rancher with private repo
# Follow steps here: #https://rancher.com/docs/rancher/v2.x/en/installation/air-gap-single-node/prepare-private-registry/
# (Download rancher-save-image.sh, rancher-load-image.sh and rancher-image.txt)
cd kvm/rancher/
./rancher-save-images.sh --image-list ./rancher-images.txt
docker login repo.gmetri.io
./rancher-load-images.sh --image-list ./rancher-images.txt --images rancher-images.tar.gz --registry repo.gmetri.io
rm rancher-images.tar.gz

#Then SSH into the rancher node and run the following:
ssh rancher@node-05-10
docker login repo.gmetri.io
docker run -d --restart=unless-stopped \
  --name my-rancher \
  -p 80:80 -p 443:443 \
  -v /opt/rancher:/var/lib/rancher \
  repo.gmetri.io/rancher/rancher:v2.2.9

#Then go to https://rancher.lan and set admin password
#Go to settings tab and change system-default-registry to repo.gmetri.io
