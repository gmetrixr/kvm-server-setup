# GMETRI-Kube VM Setup

## Installation

> https://www.hiroom2.com/2018/08/06/linuxmint-19-kvm-en/

```bash
sudo apt install -y -o 'apt::install-recommends=true' qemu-kvm libvirt0 libvirt-bin virt-manager libguestfs-tools
sudo gpasswd libvirt -a $USER
sudo reboot
sudo apt install libosinfo-bin bridge-utils #virt-viewer gir1.2-spiceclientgtk-3.0
```

### libvirtd Partition

Move /var/lib/libvirtd to a partition with enough space

```bash
sudo service libvirtd stop
cd /var/lib; sudo mv libvirt libvirt-old;
sudo mkdir /mnt/storage1/libvirt /mnt/storage1/libvirt/boot /var/lib/libvirt
echo "/mnt/storage1/libvirt  /var/lib/libvirt  none  defaults,bind  0 0" | sudo tee -a /etc/fstab > /dev/null
mount -a
sudo service libvirtd start
```

### Stop default network to prevent dnsmasq starting, adding custom network

Prevent usage of the default network which starts its own dnsmasq:

```bash
virsh net-list
virsh net-destroy default
virsh net-autostart --network default --disable
```

Also comment out `bind-interfaces` from `/etc/dnsmasq.d/libvirt-daemon`

### Add custom network

```bash
virsh net-define /home/gmetri/code/vmc/etc/libvirt-bridge-br0.xml
virsh net-start br0
virsh net-autostart br0
virsh net-list --all
```

### From the client machine

`apt install virt-manager virt-viewer gir1.2-spiceclientgtk-3.0`

#### For nested virtualization

> https://docs.fedoraproject.org/en-US/quick-docs/using-nested-virtualization-in-kvm/

Shut down all VMs. Remove kvm_intel: `modprobe -r kvm_intel`. Activate feature (only till the next reboot): `modprobe kvm_intel nested=1`. To enable permanently, add the following to /etc/modprobe.d/kvm.conf: `options kvm_intel nested=1`

To configure it, go to virt-manager > Show hardware details > CPU > and select "Copy host CPU configuration" check box.
