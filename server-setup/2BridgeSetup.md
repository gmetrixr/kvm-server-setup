# GMETRI-Kube

## Network setup with netplan

```bash
sudo ln -s /home/gmetri/code/vmc/etc/netplan/netplan_bridge_kube.yaml /etc/netplan/99_netplan_bridge.yaml
echo "@reboot root /home/gmetri/code/vmc/etc/cron.sh" | sudo tee -a /etc/cron.d/vmc_cron > /dev/null # To set netplan on restart
sudo chmod 700 /etc/cron.d/vmc_cron # Cron needs the correct permissions
sudo netplan try --timeout=15 #press enter if the config works
#To revert: sudo ifconfig br0 down; sudo brctl delbr br0;
```

### Getting network status

```bash
sudo networkctl status -a
ifconfig
ip r #Default routes
arp #To find cached mac addresses
```

### Forward all requests across bridges

> https://jamielinux.com/docs/libvirt-networking-handbook/bridged-network.html

#### Load kernel module br_netfilter

```bash
cat /proc/modules | less #To check currently loaded modules
sudo modprobe br_netfilter #Loads br_netfilter kernel module, modprobe -r br_netfilter to remove
# To see kernel module events realtime use `udevadm monitor`
sudo cp /home/gmetri/code/vmc/etc/module-load-netfilter.conf /etc/modules-load.d/br-netfilter.conf
# To check: systemctl status systemd-modules-load
# In case the above doesn't work
# echo "br_netfilter" | tee -a /etc/modules > /dev/null #persist on restart
```

#### Sysctl rules to prevent bridge filtering

> https://www.freedesktop.org/software/systemd/man/sysctl.d.html

```bash
sysctl -a | grep bridge #To check current sysctl values
sudo sysctl -p /home/gmetri/code/vmc/etc/sysctl-bridge-forward.conf #Loads the sysctl bridge rules
sudo ln -s /home/gmetri/code/vmc/etc/sysctl-bridge-forward.conf /etc/sysctl.d/80-bridge-forward.conf #persist on restart
# The above doesn't get applied (bug). Need to reload all kernel params on restart in cron.sh: /etc/init.d/procps restart

# (Optional) The above params can also be loaded using udev rules, but these rules don't applied on time duirng system restart
# Can be solved by reloading the kernel module in cron "modprobe -r br_netfilter; modprobe br_netfilter"
#sudo ln -s /home/gmetri/code/vmc/etc/udev-bridge.rules /etc/udev/rules.d/99-bridge.rules
# To test this rule: udevadm test --action=add /sys/module/br_netfilter
```

##### Working config, output of ifconfig

```text
br0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.0.5  netmask 255.255.0.0  broadcast 10.0.255.255
        inet6 fe80::e0fc:5aff:fe70:5dd2  prefixlen 64  scopeid 0x20<link>
        ether e2:fc:5a:70:5d:d2  txqueuelen 1000  (Ethernet)
        RX packets 4597  bytes 3700847 (3.7 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 3119  bytes 353332 (353.3 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

enp4s0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        ether 0c:9d:92:63:2d:68  txqueuelen 1000  (Ethernet)
        RX packets 174784  bytes 42213582 (42.2 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 126430  bytes 11050640 (11.0 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 4513  bytes 424882 (424.8 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 4513  bytes 424882 (424.8 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

##### NOT Working config

```text
br0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet6 fe80::e0fc:5aff:fe70:5dd2  prefixlen 64  scopeid 0x20<link>
        ether e2:fc:5a:70:5d:d2  txqueuelen 1000  (Ethernet)
        RX packets 11081  bytes 1007853 (1.0 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 52  bytes 9269 (9.2 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

enp4s0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.0.5  netmask 255.255.0.0  broadcast 10.0.255.255
        ether 0c:9d:92:63:2d:68  txqueuelen 1000  (Ethernet)
        RX packets 11085  bytes 1163247 (1.1 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 375  bytes 37832 (37.8 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 488  bytes 36123 (36.1 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 488  bytes 36123 (36.1 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

##### Original config

```text
enp4s0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.0.196  netmask 255.255.255.0  broadcast 10.0.0.255
        inet6 fe80::5d13:c710:b131:dae4  prefixlen 64  scopeid 0x20<link>
        ether 0c:9d:92:63:2d:68  txqueuelen 1000  (Ethernet)
        RX packets 351057  bytes 472192320 (472.1 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 179084  bytes 14477505 (14.4 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 526  bytes 46439 (46.4 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 526  bytes 46439 (46.4 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```
