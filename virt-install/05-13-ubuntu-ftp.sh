#!/bin/bash

#For os-type: osinfo-query os | grep -i ubuntu
#on local system: QK=qemu:///system

virt-install --connect $QK \
--name "node-05-13" \
--metadata title="05-13 Ubuntu FTP Server",description="05-13 Ubuntu FTP Server" \
--ram=4096 --vcpus=2 \
--os-type=linux --os-variant=ubuntu18.04 \
--disk path=/mnt/storage1/sp/sp1/05-13.qcow2,bus=virtio,size=75 \
--graphics none \
--console pty,target_type=serial \
--network bridge=br0,model=virtio,mac=54:52:00:00:05:13 \
--location /mnt/storage1/sp/install-images/ubuntu-18.04.2-server-amd64.iso \
--extra-args 'console=ttyS0,115200n8 serial' \
--filesystem mode=mapped,source=/mnt/storage2/ftp,target=ftp

virsh -c $QK autostart node-05-13

#To destroy VM:
# virsh -c $QK destroy node-05-13; virsh -c $QK undefine node-05-13; virsh -c $QK pool-refresh sp1; virsh -c $QK vol-delete --pool sp1 05-13.qcow2

# virsh vol-create-as sp1 05-13.qcow2 100G
# virt-clone --connect qemu:///system \
# --original 05-13 \
# --name node-05-13 \
# --file /mnt/storage1/sp/sp1/05-13.qcow2 \
# --mac 54:52:00:00:05:13

#EXTRA NOTES:
# Make sure you install the openssh server!
# Login with ssh (ssh gmetri@node-05-13) and type the following the make virsh console work:
sudo systemctl start serial-getty@ttyS0.service; sudo systemctl enable serial-getty@ttyS0.service
# Also add the private keys from cloud-config.yml to ~gmetri/.ssh/authorized_keys
# Disallow password ssh: sed -i -e '/config_to_match =/ s/= .*/= new_value/' /path/to/file
sudo sed -i -e '/#PasswordAuthentication yes/ s/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config; sudo service sshd restart

## Allow passwordless sudo
```bash
sudo groupadd -f admin
sudo usermod -a -G sudo,admin $USER
echo "%admin ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/admin > /dev/null
```

## Allow passthrough mount
### On host system:
mkdir /mnt/storage2/ftp
sudo chown libvirt-qemu:kvm /mnt/storage2/ftp
### In VM
#### Make sure the 9p module loads during system boot
echo "9p
9pnet
9pnet_virtio" | sudo tee -a /etc/initramfs-tools/modules > /dev/null
sudo update-initramfs -u
#### Mount passthrough'ed folder
sudo mkdir /ftp
echo "ftp  /ftp  9p  trans=virtio,version=9p2000.L,rw,uid=1000,gid=1000  0  0" | sudo tee -a /etc/fstab > /dev/null
sudo mount -a

#### Installing VSFTPD
sudo apt install -y vsftpd
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.original

##### Changes in /etc/vsftpd.conf:

```
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
chroot_list_enable=NO
userlist_deny=NO
userlist_enable=YES
userlist_file=/etc/vsftpd.allowed_users
pam_service_name=ftp
```
echo "ftpuser" | sudo tee -a /etc/vsftpd.allowed_users > /dev/null

sudo useradd ftpuser -M -s /sbin/nologin -d /ftp
sudo passwd ftpuser #ftppa55

sudo chmod ftpuser /ftp
sudo chmod a-w /ftp

sudo mkdir /ftp/upload
sudo chown ftpuser /ftp/upload

sudo service vsftpd restart
