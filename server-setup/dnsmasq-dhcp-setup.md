# DHCP Setup

## DNSMasq Setup

> https://sfxpt.wordpress.com/2011/02/06/providing-dhcp-and-dns-services-with-dnsmasq/
> https://computingforgeeks.com/install-and-configure-dnsmasq-on-ubuntu-18-04-lts/

It’s better to keep the DNSmasq configuration outside the distributed .conf file — it makes upgrades much less of a headache.

```bash
#Ubuntu 18.04 comes with systemd-resolve which you need to disable since it binds to port 53 which will conflict with Dnsmasq port.
#Apr 15 00:14:30 gmetri-kube dnsmasq[24700]: failed to create listening socket for port 53: Address already in use
apt install dnsmasq

#Also, remove the symlinked resolv.conf file
ls -lh /etc/resolv.conf
sudo rm /etc/resolv.conf
sudo touch /etc/resolv.conf
#To revert:
#sudo rm /etc/resolv.conf; sudo ln -s /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
#sudo systemctl stop dnsmasq; sudo systemctl disable dnsmasq; sudo systemctl enable systemd-resolved; sudo systemctl start systemd-resolved;

echo "conf-dir=/home/gmetri/code/vmc/etc/dnsmasq.d/,*.conf" | sudo tee -a /etc/dnsmasq.conf > /dev/null
sudo systemctl disable systemd-resolved; sudo systemctl stop systemd-resolved; sudo systemctl enable dnsmasq; sudo systemctl start dnsmasq;
```

## List DHCP Leases

* `cat /var/lib/misc/dnsmasq.leases`
* `arp -an`
