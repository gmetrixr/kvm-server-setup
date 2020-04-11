#!/bin/bash

#RANCHER OS DOES NOT MOUNT MAPPED FILESYSTEM ON REBOOT!! SO USING UBUNTU.

#For os-type: osinfo-query os | grep -i ubuntu
#on local system: QK=qemu:///system

virt-install --connect $QK \
--name "node-05-11" \
--metadata title="05-11 Ubuntu HAPROXY",description="05-11 Ubuntu HAPROXY" \
--ram=4096 --vcpus=2 \
--os-type=linux --os-variant=ubuntu18.04 \
--disk path=/mnt/storage1/sp/sp1/05-11.qcow2,bus=virtio,size=75 \
--graphics none \
--console pty,target_type=serial \
--network bridge=br0,model=virtio,mac=54:52:00:00:05:11 \
--location /mnt/storage1/sp/install-images/ubuntu-18.04.2-server-amd64.iso \
--extra-args 'console=ttyS0,115200n8 serial' \
--filesystem mode=mapped,source=/home/gmetri/code/vmc/kvm/etc/haproxy,target=haproxy

virsh -c $QK autostart node-05-11

#To destroy VM:
# virsh -c $QK destroy node-05-11; virsh -c $QK undefine node-05-11; virsh -c $QK pool-refresh sp1; virsh -c $QK vol-delete --pool sp1 05-11.qcow2

#EXTRA NOTES:
# Make sure you install the openssh server!
# Login with ssh (ssh gmetri@node-05-11) and type the following the make virsh console work:
sudo systemctl start serial-getty@ttyS0.service; sudo systemctl enable serial-getty@ttyS0.service
# Also add the private keys from cloud-config.yml to ~gmetri/.ssh/authorized_keys
# Disallow password ssh: sed -i -e '/config_to_match =/ s/= .*/= new_value/' /path/to/file
sudo sed -i -e '/#PasswordAuthentication yes/ s/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config; sudo service sshd restart

## Allow passwordless sudo
sudo groupadd -f admin
sudo usermod -a -G sudo,admin $USER
echo "%admin ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/admin > /dev/null

## Allow passthrough mount
#### Make sure the 9p module loads during system boot
echo "9p
9pnet
9pnet_virtio" | sudo tee -a /etc/initramfs-tools/modules > /dev/null
sudo update-initramfs -u
#### Mount passthrough'ed folder
sudo mkdir /haproxy
echo "haproxy  /haproxy  9p  trans=virtio,version=9p2000.L,rw,uid=1000,gid=1000  0  0" | sudo tee -a /etc/fstab > /dev/null
sudo mount -a

### Install Docker
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
sudo apt install -y docker-ce
sudo systemctl status docker
sudo usermod -aG docker ${USER}
#Log out of the server, and log back in or:
su - ${USER}
#Confirm docker group addition by: `id -nG`
docker run hello-world

apt install dnsutils #install dig

#Test configuration: 
docker run -it --rm --name haproxy-syntax-check \
  -v /haproxy:/usr/local/etc/haproxy:ro \
  haproxy:1.9 haproxy -c -f /usr/local/etc/haproxy/haproxy.cfg

docker run -d \
  --restart=unless-stopped \
  --name my-haproxy \
  --network host \
  -v /haproxy:/usr/local/etc/haproxy:ro \
  haproxy:1.9

#Access haproxy stats on http://haproxy.lan:9999/stats, user/pass: admin/haadmin

# Reload config:
#In kube.lan: (ssh gmetri@kube.lan)
cd ~/code/vmc; git pull;
ssh gmetri@node-05-11
docker kill -s HUP my-haproxy

