# Virtual Networking in Linux

Linux provides diferent methods to enable virtual networks, these are used
in VM and containers and cloud environments. To get a list of the supported
types of interfaces in linux use the command `ip link help`

## Bridge

Behaves like a network switch forwarding packages between interfaces that are
connected to it. It supports STP, VLAN filter and multicast snooping. Use a
bridge when establishing channels between VMs, containers and the hosts.

Old alternative
```sh
brctl addbr br0
brctl addif br0 eth0
brctl addif br0 eth1
ifconfig br0 up
```

Newer tools
(confirm this)
```sh
ip link add link br0 type bridge
ip link set eth0 master br0
ip link set eth1 master br0
ip link set br0 up
```

linux bridges by default do not forward the frames from the PTP protocol which
use the multicast address `01-80-C2-00-00-0E` which is individual LAN scope but
will forward the general purpose address `01-1B-19-00-00-00`. However this will
is not PTP compliant and the timestamp is no longer valid or at least the
expected precision will not be reached.

## Bonded Interface

This driver provides a method for aggregating multiple network interfaces into
a single logically "bonded" interface. The behavior of the interface depends on
the mode. These modes provide hot standby or load balancing.


```sh
```
## Team device

Similar to the bonded interface, the purpose is to logically group several NICs
into one logic at L2 layer. The team interface is trying to solve the same
problem that the bonded interface using a different method, for example using
a lockless (RCU) Tx/Rx path and modular design.

There are several functional differences between the bondedn and team device,
team device supports d-bus and LACP load balancing which are absent in the
bonded interface. Use team device when the bonded interface does not provide
the needed feature, but a logical group is still needed.

```sh
```


## VLAN

A VLAN (Virtual LAN), separates broadcast domains by adding tags to network
packages. VLANs allow network administrators to group hosts under the same
swtich or between different interfaces.

When using VLANs make sure that the switch supports the tagging of the network
packages

```sh
```
## VXLAN

```sh
```
## MACVLAN

```sh
```
## IPVLAN

```sh
```
## MACVTAP / IPVTAP

```sh
```
## MACsec

```sh
```
## VETH

```sh
```
## VCAN

```sh
```
## VXCAN

```sh
```
## IPOIB

```sh
```
## NLMON

```sh
```
## Dummy interface

```sh
```
## IFB

```sh
```
## netdevsim


```sh
```


- - -
 - [Main src](https://developers.redhat.com/blog/2018/10/22/introduction-to-linux-interfaces-for-virtual-networking/)
 - [BondingVsTeam](https://github.com/jpirko/libteam/wiki/Bonding-vs.-Team-features)
 - [Hot stand by](https://www.cisco.com/c/en/us/support/docs/ip/hot-standby-router-protocol-hsrp/9234-hsrpguidetoc.html)
 - [TCPIP/OSI](http://www.omnisecu.com/tcpip/tcpip-model.php)