# Windows machine specifics

PowerShell as Administrator:

```ps1
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
```

* Restart to finish installation.
* Install Ubuntu from Windows Store

## For nested virtualization (on linux host)

> https://docs.fedoraproject.org/en-US/quick-docs/using-nested-virtualization-in-kvm/

Shut down all VMs. Remove kvm_intel: `modprobe -r kvm_intel`. Activate feature (only till the next reboot): `modprobe kvm_intel nested=1`. To enable permanently, add the following to /etc/modprobe.d/kvm.conf: `options kvm_intel nested=1`

To configure it, go to virt-manager > Show hardware details > CPU > and select "Copy host CPU configuration" check box.

## Docker for Windows

* Enable Hyper-V and Container
  * Open Control Panel -> System and Security -> Programs (left panel) -> Turn Windows features on or off -> Check the Hyper-V and Container box. Apply, restart if needed.
* Install docker for windows
