# What is gratuitous in an ARP


The arp protocol is based on requests. When a device needs to find the owner
of an IP address there is an arp request then the owner sends a response. 

Then the gratuitousnes in a gratuitous arp message is that an arp is sent w/o
request.

#### Simple and clear but incomplete answer
_"Gratuitous arp is when a device will send an arp reply that is not a response
to a request. Depending on the stack, some devices will send gratuitous arp
when they boot up, which announces their presence to the rest of the net:wwork"_


#### Gratuitous ARP

Gratuitous ARP could mean both gratuitous ARP _request_ or gratuitous ARP
_resply_. Gratuitous in this case means request/reply that is not normally
needed according to the ARP spec. (RFC 286) but ound be used in some cases.
A gratuitous ARP request is an ARP request packet where the src and dst IP
are both set to the IP of the machine issuing the packet and the destination
MAC is de broadcast address `ff:ff:ff:ff:ff:ff` ordinarily, no reply packet
will occur. A gratuitous ARP reply is a reply to which no request has been made.


#### Use case for a gratuitous ARP9

* They can help to detet IP conflicts. When a machine receives an ARP request
containing a source IP that matches its own, then it knows there is an IP 
conflict.
* They assist in the updating of the other machines' ARP tables. Clustering
soultuons utlize ths when they move an IP from one NIC  to another, or from
one machine to another. Other machnes maintain an ARP table that contains
the MAC associated with an IP. When the cluster needs to move the IP to a 
different NIC, be it on the same machine or a different one, it reconfigures
the NICs appropriately then broadcasts a gratuitous ARP reply to inform
the neighboring machines about the change in MAC from the IP. Machines 
receiving the ARP packet the update their ARP tables with the new MAC
* They inform switches of the MAC address of the machine on a given switch
knows that it should transmit packets sent to that MAC address on that 
switch port.

http://wiki.wireshark.org/Gratuitous_ARP


Other explanation:

Gratuitous ARP is a sort of "advance notification", it updates the ARP cache
of other systems before they ask for it (no ARP request) or to update outdated
information.

When talking about gratuitous ARP, the packets are actually special ARP request
packets, not ARP reply packets as one would perhaps expect. Some reasons for
this are explained in RFC 5227.

The gratuitous ARP packet has the following characteristics:

Both source and destination IP in the packet are the IP of the host issuing the
gratuitous ARP the destination MAC address is the broadcast MAC address `(ff:ff:ff:ff:ff:ff)`
This means the packet will be flooded to all ports on a switch
No reply is expected
Gratuitous ARP is used for some reasons:

Update ARP tables after a MAC address for an IP changes (failover, new NIC, etc.)
Update MAC address tables on L2 devices (switches) that a MAC address is now on a different port
Send gratuitous ARP when interface goes up to notify other hosts about new MAC/IP bindings in advance so that they don't have to use ARP requests to find out
When a reply to a gratuitous ARP request is received you know that you have an IP address conflict in your network
As for the second part of your question, HSRP, VRRP etc. use gratuitous ARP to update the MAC address tables on L2 devices (switches). Also there is the option to use the burned-in MAC address for HSRP instead of the "virtual"one. In that case the gratuitous ARP would also update the ARP tables on L3 devices/hosts.
