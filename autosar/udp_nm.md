# UDP NM
- - -
#### Links
[automotive wiki](https://automotive.wiki/index.php/UDP_Network_Management)

##### The UDP Network Management is a basic software module of the communications service.

UdpNm is intended to be an optional feature and to work together with a TCP/IP
stack, independent of the PHY layer of the communication system used.

It's in charge of the coordination of the transition between normal operation
and bus-sleep mode of an ETH network.
* Periodic broadcast messages are sent by nodes which want to keep the NM-cluster
awake
* No master node
* Other features:
  - Node detection(detect all presetn nodes in a network)
  - Ready sleep detection (detect if all the nodes on the network are ready to sleep)
  - Partial networking


No wake-up based on NM Messages possible:
* Additional bus connection or wake-up line necessary
* Transceiver support missing


##### coordination algorithm

The UdpNm coordination algorithm is based on periodic NM packets, which are received
ba all nodes in the cluster via broadcast Tx. Reception of NM pkgs indicates that
the sending node wants to keep the NM-cluster awake.

If any node is ready to go to the bus-sleep mode, it stops sending NM pkgs, but
as long as M packets from the other nodes are received, it postpones transition
to the bus-sleep mode.

If a dedicated timer elapses because no NM pkgs are received anymore, every node
initialtes transition to bus-sleep mode.
