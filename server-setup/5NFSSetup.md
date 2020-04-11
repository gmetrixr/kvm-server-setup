# Setting up NFS on Ubuntu

This purpose of this guide to quickly setup an NFS server on Ubuntu 18.04

## Server Installation

### Install nfs server

`sudo apt install nfs-kernel-server`

### Create shared folder

```bash
SHARED_FOLDER=/mnt/storage2/sharedfolder
sudo mkdir -p $SHARED_FOLDER
sudo chown nobody:nogroup $SHARED_FOLDER
sudo chmod 777 $SHARED_FOLDER
```

### Assign server access

Replace 10.0.0.0/16 with you subnet

```bash
echo "$SHARED_FOLDER  10.0.0.0/16(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /etc/exports > /dev/null
```

### Export the shared directory

```bash
sudo exportfs -a
sudo systemctl restart nfs-kernel-server
```

## On Clients

### Install NFS Common

`sudo apt-get install nfs-common`

### Create mount point and mount shared directory

```bash
SHARED_NFS=kube.lan:/mnt/storage2/sharedfolder
MOUNT_POINT=/home/$USER/test
sudo mount $SHARED_NFS $MOUNT_POINT
```
