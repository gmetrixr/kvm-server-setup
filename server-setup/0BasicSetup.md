## Installation

While installing OS, to solve UEFI installation error, create a 200 MB fat32 partition and while installation make its type "efi". Without this partition, UEFI boot fails.

```bash
ssh-keygen -t rsa -b 4096 #Instead of this use gmpull's private and public key
curl https://github.com/sahil87.keys >> ~/.ssh/authorized_keys
curl https://github.com/amitrajput1992.keys >> ~/.ssh/authorized_keys
apt install -y openssh-server
sudo service sshd start
apt install -y emacs git
git config --global user.username gmpull #<username> #Your Gitlab/Github Username https://github.com/<xxxxx>
git config --global user.name gmpull #"<Firstname Lastname>"
git config --global user.email admin+gmpull@gmetri.com #<your@email.id>

mkdir code; cd code;
git clone git@github.com:gmetrivr/vmc.git
```

### Allow passwordless sudo

```bash
sudo groupadd -f admin
sudo usermod -a -G sudo,admin $USER
echo "%admin ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/admin > /dev/null
```

### SSH Daemon Setup

> sed -i -e '/config_to_match =/ s/= .*/= new_value/' /path/to/file

* Add the private keys from cloud-config.yml to ~gmetri/.ssh/authorized_keys
* Disallow password ssh:

   ```bash
   sudo sed -i -e '/#PasswordAuthentication yes/ s/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config;
   sudo service sshd restart
   ```
