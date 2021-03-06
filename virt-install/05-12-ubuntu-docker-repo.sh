#!/bin/bash

#For os-type: osinfo-query os | grep -i ubuntu
#on local system: QK=qemu:///system

virt-install --connect $QK \
--name "node-05-12" \
--metadata title="05-12 Ubuntu Docker Repo",description="05-12 Ubuntu Docker Repo" \
--ram=4096 --vcpus=2 \
--os-type=linux --os-variant=ubuntu18.04 \
--disk path=/mnt/storage1/sp/sp1/05-12.qcow2,bus=virtio,size=75 \
--graphics none \
--console pty,target_type=serial \
--network bridge=br0,model=virtio,mac=54:52:00:00:05:12 \
--location /mnt/storage1/sp/install-images/ubuntu-18.04.2-server-amd64.iso \
--extra-args 'console=ttyS0,115200n8 serial' \
--filesystem mode=mapped,source=/mnt/storage2/dockerrepo,target=dockerrepo
--filesystem mode=mapped,source=/home/gmetri/code/vmc/kvm/etc/dockerrepo,target=dockerrepo-etc

virsh -c $QK autostart node-05-12

#To destroy VM:
# virsh -c $QK destroy node-05-12; virsh -c $QK undefine node-05-12; virsh -c $QK pool-refresh sp1; virsh -c $QK vol-delete --pool sp1 05-12.qcow2

#EXTRA NOTES:
# Make sure you install the openssh server!
# Login with ssh (ssh gmetri@node-05-12) and type the following the make virsh console work:
sudo systemctl start serial-getty@ttyS0.service; sudo systemctl enable serial-getty@ttyS0.service
# Also add the private keys from cloud-config.yml to ~gmetri/.ssh/authorized_keys
# Disallow password ssh: sed -i -e '/config_to_match =/ s/= .*/= new_value/' /path/to/file
sudo sed -i -e '/#PasswordAuthentication yes/ s/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config; sudo service sshd restart

## Allow passwordless sudo
sudo groupadd -f admin
sudo usermod -a -G sudo,admin $USER
echo "%admin ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/admin > /dev/null

## Allow passthrough mount
### On host system:
mkdir /mnt/storage2/dockerrepo
sudo chown libvirt-qemu:kvm /mnt/storage2/dockerrepo
### In VM
#### Make sure the 9p module loads during system boot
echo "9p
9pnet
9pnet_virtio" | sudo tee -a /etc/initramfs-tools/modules > /dev/null
sudo update-initramfs -u
#### Mount passthrough'ed folder
sudo mkdir /dockerrepo
echo "dockerrepo  /dockerrepo  9p  trans=virtio,version=9p2000.L,rw,uid=1000,gid=1000  0  0" | sudo tee -a /etc/fstab > /dev/null
sudo mkdir /dockerrepo-etc
echo "dockerrepo-etc  /dockerrepo-etc  9p  trans=virtio,version=9p2000.L,rw,uid=1000,gid=1000  0  0" | sudo tee -a /etc/fstab > /dev/null
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

#### Docker-Compose
sudo curl -L https://github.com/docker/compose/releases/download/1.24.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

### Install Nginx
sudo apt update
sudo apt install -y nginx
systemctl status nginx

#Make sure haproxy forwards repo.gmetri.io to repo.lan, and repo.lan and repo.gmetri.io exist in DNS pointing to node-05-12

#### Increase upload size to nginx
emacs /etc/nginx/nginx.conf
```
...
http {
        client_max_body_size 2000M;
        ...
}
...
```

### Let's encrypt

sudo add-apt-repository ppa:certbot/certbot
sudo apt install -y python-certbot-nginx

#### Sites section in nginx
sudo cp /dockerrepo-etc/nginx/repo.gmetri.io /etc/nginx/sites-available/repo.gmetri.io
sudo cp /dockerrepo-etc/nginx/hub.repo.gmetri.io /etc/nginx/sites-available/hub.repo.gmetri.io
sudo ln -s /etc/nginx/sites-available/repo.gmetri.io /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/hub.repo.gmetri.io /etc/nginx/sites-enabled/
sudo nginx -t #Test for any syntax errors
sudo systemctl restart nginx
#Now repo.gmetri.io should show nginx's default page, also haproxy's stat page should list repo.lan (might need to restart haproxy, dunno why)

sudo certbot run --nginx -d repo.gmetri.io -d www.repo.gmetri.io --agree-tos --email admin@gmetri.com #--test-cert
sudo certbot run --nginx -d hub.repo.gmetri.io -d www.hub.repo.gmetri.io --agree-tos --email admin@gmetri.com #--test-cert
sudo certbot renew --dry-run

#Having docker-compose up and going to https://repo.gmetri.io should show {}

### To create htpasswd used inside registry docker:
sudo apt install -y apache2-utils
htpasswd -Bc registry.password password
password

### Install Docker-Registry docker-compose
ln -s /dockerrepo-etc/dockercompose ~/
cd dockercompose
docker-compose up -d

#To garbage collect:
registry garbage-collect config.yml
