# NM network management


NM exposes an interface viw ara::com


There are 2 interfaces in Nm:
- Network management
    - Field: network state - getter + notifier
- Methods:
    - Network request
    - Netowrk release
    
There is only 1 instance of NM does not provide inay service towards APPs.
Requests come from state manager-
- NMChannel:
    contains all the services related to a physical network. There fore it must exists one instance per eth or vlan

Applications only ask that a node to stay active and retrieve their request. But they cannot force a shutdown.

The NM packets are received via multicast.
The reception of the NMpkt indicates that some application requires the node to stay active.


