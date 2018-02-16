# [Mapping IP multicast to MAC layer Multicast](https://technet.microsoft.com/en-us/library/cc957928.aspx)

Other refs: https://en.wikipedia.org/wiki/IP_multicast#Layer_2_delivery


To support IP multicasting, the internet authorities have reserved the multicast
address range of `01:00:5E:00:00:00` to `01:00:5E:7F:FF:FF` for ethernet and
fiber distributed data interfaces (FDDI) media access control addresses.

As shown, the high order 25 bits of the 48 bit MAC address are fixed and the low
order 23 bit are variable.

![](./mcast_mac.gif)


To map an IP multicast address to a MAC-layer multicast address, the low order
23 bits of the IP multicast address are mapped directly to the low order 23 bits
in the MAC-layer multicast address. Because the first 4 bits of an IP multicast
address are fixed according to the class D convention, there are 5 bits in the
IP multicast address that do not map to the MAC-layer multicast address.
Therefore, it is possible for a host to receive a MAC-layer multicast packets
for groups to which it does NOT belongs. However, these packets are dropped by
IP once the destination IP address is determined.

For example mcast address ``224.192.16.1` becomes `01:00:5E:40:10:01` to use the
23 low order bits, the first octet is not used, and only the last 7 bits of the
second octet is used. The third and fourth octets are converted directly to hex.
The second octet, 192 in binary 0b11000000. If you drop the high order bit, it
becomes 0b01000000 or 64 in decimal or 0x40 in hex. For the next octet, 16
decimal is 0x10. For the las octet, 1 is 1 in all the representations, then 0x01
. Therefore the MAC address corresponding to `224.192.16.1` becomes
`01:00:5E:40:10:01`
