#!/bin/bash

#For os-type: osinfo-query os | grep -i ubuntu
#on local system: QK=qemu:///system

NO=11
virt-install --connect $QK \
--name "node-07-$NO" \
--metadata title="07-$NO Ubuntu Build1",description="07-$NO Ubuntu Build1" \
--ram=16384 --vcpus=2 \
--os-type=linux --os-variant=ubuntu18.04 \
--disk path=/mnt/storage1/sp/sp1/07-$NO.qcow2,bus=virtio,size=25 \
--disk path=/mnt/storage1/sp/sp1/07-$NO-storage.qcow2,bus=virtio,size=300 \
--graphics none \
--console pty,target_type=serial \
--network bridge=br0,model=virtio,mac=54:52:00:00:07:$NO \
--location /mnt/storage1/sp/install-images/ubuntu-18.04.2-server-amd64.iso \
--extra-args 'console=ttyS0,115200n8 serial'

virsh -c $QK autostart node-07-$NO

#To destroy VM:
# virsh -c $QK destroy node-07-$NO; virsh -c $QK undefine node-07-$NO; virsh -c $QK pool-refresh sp1; virsh -c $QK vol-delete --pool sp1 07-$NO.qcow2

#EXTRA NOTES:
# Make sure you install the openssh server!
# Login with ssh (ssh gmetri@node-07-11) and type the following the make virsh console work:
sudo systemctl start serial-getty@ttyS0.service; sudo systemctl enable serial-getty@ttyS0.service
# Also add the private keys from cloud-config.yml to ~gmetri/.ssh/authorized_keys
# Disallow password ssh: sed -i -e '/config_to_match =/ s/= .*/= new_value/' /path/to/file
sudo sed -i -e '/#PasswordAuthentication yes/ s/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config; sudo service sshd restart

## Allow passwordless sudo
sudo groupadd -f admin
sudo usermod -a -G sudo,admin $USER
echo "%admin ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/admin > /dev/null

#After this follow newworker setup README from dec repo
