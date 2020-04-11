# Working with vms

## Add storage pool

```bash
mkdir -p /mnt/storage1/sp/sp1
virsh pool-define-as sp1 dir - - - - "/mnt/storage1/sp/sp1/"
virsh pool-build sp1
virsh pool-start sp1; virsh pool-autostart sp1;
virsh pool-list --all
virsh pool-info sp1
```

## Virsh basics

* `virsh nodeinfo`: Host system details
* `virsh list [--all]`: List VMs
* `virsh dominfo test`: Domain (VM) info
* `virsh start/autostart test`: Start/Autostart VM
* `virsh shutdown/reboot/destroy test`: Shutdown gracefully, reboot, force shutdown
* `virsh suspend/resume test`: Pause, Unpause
* `virsh save test test.save/virsh restore test.save`: Save to file and restore from file
* Remove VM:

  ```bash
  virsh destroy test
  virsh undefine test
  virsh pool-refresh default
  virsh vol-delete --pool default test.qcow2
  ```

* Connect to console: `virsh console test`
* Edit vm xml file: `virsh edit test`
* List of valid OS variants: `osinfo-query os`

## Manage volumes

* `virsh vol-create-as default test_vol2.qcow2 2G`: Create a 2GB volume test_vol2 in a pool named default
* Attach volume test_vol2 to vm test:

  ```bash
  virsh attach-disk --domain test \
  --source /var/lib/libvirt/images/test_vol2.qcow2  \
  --persistent --target vdb
  ```

* `sudo qemu-img resize /var/lib/libvirt/images/test.qcow2 +1G` resize disk image: shortcoming that you cannot resize an image which has snapshots

### Create snapshots

```bash
virsh snapshot-create-as --domain test \
--name "test_vm_snapshot1" \
--description "test vm snapshot 1-working"
```

* `virsh snapshot-list test`
* `virsh snapshot-info --domain test --snapshotname test_vm_snapshot``

### Clone a vm

* `virsh destroy test`: To clone a VM first shut it down
* Clone it:

```bash
virt-clone --connect qemu:///system \
--original test
--name test_clone
--file /var/lib/libvirt/images/test_clone.qcow2
```

* `virsh dominfo test_clone`

More hints here: https://computingforgeeks.com/virsh-commands-cheatsheet/

#### Cloning indepth example (to modify)

> https://www.cyberciti.biz/faq/how-to-clone-existing-kvm-virtual-machine-images-on-linux/

```bash
# virsh suspend ncbz01
# virt-clone --original ncbz01 --name ncbz02 --file /var/lib/libvirt/images/ncbz02-disk01.qcow2
# virsh resume ncbz01
# virt-sysprep -d ncbz02 --hostname ncbz02 --enable user-account,ssh-hostkeys,net-hostname,net-hwaddr,machine-id --keep-user-accounts vivek --keep-user-accounts root --run 'sed -i "s/192.168.122.16/192.168.122.17/" /etc/network/interfaces'
```
