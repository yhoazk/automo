# Network architecture and principles

According to some sources the internet started with ARPAnet in the US, where several
universities connected themselves. there were other networks at that time, like 
Satnet, a satellite network and Packet radio network additionally to WLAN.


IN 1982 the domain resolution protocol was introduced to replace the file hosts.txt
which contained a list of all hosts and their IPs with a distributed name lookup
system. After that in 1989 the TCP congestion control protocol was released after
seriers of congestion collapses.

Problems and growing pains:

1. running out of adresses
2. congestion control: Insufficient synamic range
    Do not work well with high speed intercontinetla paths, or they do not work well
    in thin networks
3. routing -> no security, easyly misconfigured, poor convergence, non-deterministic
   BGP
4. security -> bad key management, secure deployment
5. Denial of service -> pkgs are sent even if destination does not want/need those pkgs.

All require changes to basic infrastructure.


### Architectureal design principles

From the paper "Design philosopy of the darpa internet protocols"

Those principles were designed fro a certain type of network, which in some cases
are not suitable anymore, then causing problems in the current network.

**conceptual lessons**: Those principles were desinged for a certain type of network
**technical lessosn**: 
    - Importance of packet switichng
    - Concept of "fate sharing" or soft state

The initial goal of these desing was:
>> Multiplexed utilization of existing interconnected networks

By mutiplexed, it means to sharing the resource by statistical mutliplexing (statistical?)
and by interconnected it introduced the concept of "narrow waist".


#### Packet switchig:

The packet swtiching information is already containted in the packet itself, much like
a letter where the destination address is written in the envelop.

circuit switching vs packet switchin:

Packet switching:
    - Has variable delay and it can drop packages
    - It shares the network resoruces

Circuit switching:
    - Uses a busy signal, like in the phone networks
    - It was dedicated resources between Tx and Rx


#### Interconnection: Narrow waist

The initial goal was to interconnect many existing networks.
Hide underlying technology from applications.

The goal was achieved used the "narrow waist", in this case narrow waist means that every device which
is connected to the nework implementes a common layer, in this case is the IP layer. The IP layer provides
certaing guarantees to the above layers, in this case tcp/udp and at the same time these layers provide
guarantees to the layer above them, such as reliable transport and congestion control.
While the IP layer provides the guarantee of E2E connectivity.

#### Goal survivability

This goal means that the network has to survive the failure of a device. One way to achieve this is through
replication, which means that there is a second device ready to take over if the first device fails.

Another way is to achieve this goal is by usign the concept of fate sharing. Fate sharing says that it's
acceptable to loose state information for some entity if the entity itself is lost, for example if the router
crashes, the routing table is lost, if the network is designed to survive this loss of information.
The meaning of "fate sharing" comes from the loss of both the state information and the device itself, both
share the same fate. 

The advantage is that is easier to withstand complex failures and also simplyfies the engineering.

#### Goal: Heterogeneity

Heterogenety is achieved through TCP/IP as a monotolic transport, also by implementing the "best effort"
service model where the network can loose packages or deliver them out of order and odoes not provide any
quality guarantee nor information about failires or performance. This simplyfies the design but difficults 
the diagnostic.

#### Goals Distributed management

This means that the management of the network should not be handled by a single entity. For example the
naming is handled by ARIN in america and by RIPE in europe. DNS allows each organization to handle their
own names and BGP allows independent operating networks to arragne their own routing.

However the internet does not have a sigle responsible, and then when a problem arises is difficult to
define what or who is causing a problem and therefore who should solve it.


From the paper there are several points that are missing:
- Security
- Availability
- Mobility
- Scaling

What was included was the need for
- Interconnection
- Heterogenity
- Sharing

### E2E argument in system design

From the paper from Saltzer, Reed, Clark (1981)

>>  The function in question can completely and correctly be 
    implemented only with the knowledge and help of the 
    application standing at the end points of the communication system.
    Therefore, providing that questioned function as a feature if the
    communication system itself is not possible. (Sometimes an incomplete
    version of the function provided by the communication system may be
    useful as a performance enhancement)

This is sometimes summarized as "Dumb network and intelligent endpoints"


#### Example of one of the arguments

In this example we examine a file transfer with the E2E argument. 
Computer A wants to send a file to computer B.

Computer A needs:
1. Read the file from disk
2. Communicatino system sends the file
3. Comminication system transmit the packts 

Computer B needs:

4. Give the file to a file transform program
5. Assemble the file form individual pkgs
6. Write to disk

In this case there are errors in W/R to disk it is also possible that during
transmission pkgs are corrupted or lost. It is possible to add error checks to every
step and redundancy and time-out and retry. But none of the solutions will be complete
that's why is needed from the application level to have the resposibility of checking 
the errors.

However the correctnes checks could be of value as an performance enhancement, but not
as a complemte solution. For this is sometimes difficult to define which is the enpoint.

#### E2E argument violation

E2E is only argument, not a law. Then there are several implementations which violate it

* Network address translation (NAT)
* VPN tunnels
* TCP splitting
    * This happends when the last hop is loosy, like in the case of mobile networks. TCP splitting
      is used here to avoid tcp to reaact as if it where a congestion.
* spam
* P2P: 
* caches

##### violation NAT

RFC 1918 for private IP ranges

Network address translation is the process of translating one IP from one domain to another.
For example if a local network with private range `192.168.0.0/16` is communicating with a
different network in the range `68.211.0.0/16` a device needs to translate from the source
packages in the local netowrk to the public network and replace the src IP.

Then it uses a map of ports and addresses and ports

For example the address 192.168.1.51 wants to send a package, an entriy is introduced in
the table to map the src port and IP to a outgoing port:

```
192.168.1.51:100 -> 68.211.6.120:50879
```

This is rewritten in the src for outgoing and in dst for ingress pkgs.
NAT is a violation of the E2E principle because by default the two devices on the network
cannot communicate unless an intermediate device translates the private address port pair to
a public address/port pair.



TCP: Transmission control protocol,
Internet Protocol: 