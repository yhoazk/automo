# Dynamic Host Confguration Protocol

* [Windows src](https://technet.microsoft.com/en-us/library/cc780760(v=ws.10).aspx)
* [Frame](http://www.tarunz.org/~vassilii/TAU/protocols/dhcp/frame.htm)
* [Frame 2](http://www.networksorcery.com/enp/protocol/dhcp.htm)

- DHCP is a part of the application layer.
- As the name indicates assigns addresses dynamically to devices connected to the network.

One of the features og DHCP is that it provides IP addresses that _expire_.
When DHCP assigns an IP address, it actually leases that connection identifier
to the user's computer fir a specific amount of time. The default is 5 days.

### interactions between Client and Server:

#### DHCP Messages:

There are 8 types of messages that can be sent between DHCP clients and servers,


##### DHCPDiscover
Broadcast by a DHCP client when it first attempts to connect to the network.
This message requests IP address information from a DHCP server.


##### DHCPOffer
Broadcast by each DHCP server that receives the client `DHCPDiscover` message and
has an IP address configuration to offer to the client. The DHCPOffer message
contains an unleased IP address and additional TCP/IP configuration information,
such as the subnet mask and default gateway.

If more than 1 server responds to the clients request the client accepts the
best offer.

##### DHCPRequest
Broadcast by a DHCP client after it selects a DHCPOffer. This message contais the
IP address from the DHCPOffer that it selected. If the client is renewing or
rebinding to a previous lease, this packet migth be unicast to the server.

##### DHCPAck
Broadcast by a DHCP server to a DHCP client acknowledging the DHCPRequest message.
Upon receipt of the DHCPAck, the client can use the leased IP address. It's a
broadcast because the DHCP client does not officially have an IP address that it
can use at this point.

##### DHCPNack
Broadcast by a DHCP server to a DHCP client denying the client's DHCPRequest msg.
This migth occur if the requested address is incorrect because the client moved
to a new subnet or the lease has expired and cannot be renewed.

##### DHCPDecline
Broadcast by a DHCP client to a DHCP server, informing the server that the offered
IP address is declined because appears to be used by anoter client.

##### DHCPReleaes
Sent by a DHCP client to a DHCP server, canceling the remaining lease of the IP
address. This is a unicast to the server which provides the lease.

##### DHCPInform

Sent from a DHCP client to a DHCP server, asking for additional local confguration
parameters; at this point the client already has a configured IP address.

## DHCP Lease Process Overview
![](normal_dhcp.png)

1. The DHCP client requests an IP address by broadcasting a `DHCPDiscover` to the local subnet.
2. The client is offered an address when a DHCP server responds with a DHCPOffer message containing an IP addr. and config information.
  - The client retries in 0,4,8,16 and 32 sec. if still no answer the client proceeds in one of two ways:
    * The client can use Automatic Private addressing as an alternate confguration.
    * If no auto-configuration is available, the device fails in network initialization.
3. The client indicates acceptance of the offer by selecting the offered address and broadcasting a DHCPRequest in response.
4. The client is assigned the address and the DHCP server broadcast a DHCPAck finalizing.
