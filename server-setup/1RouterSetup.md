# Router Setup

* Local lan on a different subnet 10.0.0.0/16 -> switch0 routes traffic here from two different internet connections at eth0 and eth1

## Setup

For setup, used setup wizard. (after connection laptop to eth0 with fixed ip 192.168.1.2 / 24)

Choose option "LOAD BALANCING"

1. First interent port: (ACT, eth0)
   * PPPoE - 10201602abcd, randompassword
1. Second internet (new): (Spectra, eth1)

  ```text
  Static IP: 180.151.1.2
  Subnet: 255.255.255.252
  Gateway: 180.151.43.73
  Primary DNS: 180.151.151.151
  Secondary DNS: 180.151.151.152
  ```

1. LAN Ports (eth2, eth3, eth4, eth5)
   * Port: Switch0
   * Address: 10.0.0.1/255.255.0.0
   * Disable DHCP Server

### Port forwarding

```text
2006, 10.0.0.5,  22,  kube
80,   10.0.5.11, 80,  nginx-proxy
443,  10.0.5.11, 443, nginx-proxy
```

##### Set Firewall Policies

1. Set firewall rules, to allow incoming traffic
1. Go to Firewall/NAT tab > Firewall Policies
1. Edit WAN_IN ruleset. Add New rule:

```text
Description: allow_in
Action: Accept
Protocl: Both TCP & UDP
```

##### Set DNAT

1. Go to NAT subtab, Add Destination NAT Rule

```text
Description: ssh_2006_act
Translations: Address/Port: 10.0.0.5/2006
Protocal: Both TCP & UDP
Dest Address/Port: 106.51.1.2/2006
Then create a copy ssh_2006_spectra for destination address/port: 180.151.1.2/2006
```

1. Do the same for

```text
Description, Translation Address/port
ssh_2006, 10.0.0.5/2006
http_80, 10.0.5.11/80
http_443, 10.0.5.11/443
```
