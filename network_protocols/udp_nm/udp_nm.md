# UDP NM
- - -
#### Links
* [automotive wiki](https://automotive.wiki/index.php/UDP_Network_Management)
* [Autosar Doc](https://www.autosar.org/fileadmin/files/standards/classic/4-3/software-architecture/communication-stack/standard/AUTOSAR_SWS_UDPNetworkManagement.pdf)

##### The UDP Network Management is a basic software module of the communications service.

UdpNm is intended to be an optional feature and to work together with a TCP/IP
stack, independent of the PHY layer of the communication system used.

It's in charge of the coordination of the transition between normal operation
and bus-sleep mode of an ETH network.
* Periodic broadcast messages are sent by nodes which want to keep the NM-cluster
awake * No master node
* Other features:
  - Node detection(detect all presetn nodes in a network)
  - Ready sleep detection (detect if all the nodes on the network are ready to sleep)
  - Partial networking

* Autosar UdpNm is only applicable  for TCP/IP based systems
* The UdpNm shall support up to 250 nodes per NM-cluster.

No wake-up based on NM Messages possible:
* Additional bus connection or wake-up line necessary
* Transceiver support missing


#### Coordination algorithm

The UdpNm coordination algorithm is based on periodic NM packets, which are received
by **all** nodes in the cluster via **broadcast** Tx.
Reception of NM pkgs indicates that the sending node wants to keep the NM-cluster
awake.

If any node is ready to go to the bus-sleep mode, it stops sending NM pkgs, but
as long as NM packets from the other nodes are received, it postpones transition
to the bus-sleep mode.

If a dedicated timer elapses because no NM pkgs are received anymore, every node
initiates transition to bus-sleep mode.


## UdpNm AUTOSAR Module


The UdpNm node provides an adaptation between Network Management interface `NM`
and a TCP/IP stack (TCP/IP).

UdpNm is directly related with partial networking, there's a bit(0/1) in the NM message
which specifies in which state the network shall continue. The bit is named `PNI`

The `PNI` is a field which contains information of the partial network, the range
(in bytes) that contains the PN request information (PN info range) in the
received NM-PDU is defined by AUTOSAR confguration, see parameters:
- `UdpNmPnInfoOffset`
- `UdpNmPnInfoLength`

This range is called PN infor range.

> Example
> - `UdpNmPnInfoOffset` = 3
> - `UdpNmPnInfoLength` = 2
> Only byte 3 and 4 of the NM message contain PN request information.

Every bit of the PN info range represents one partial network. If the bit is set
the partial network is requested, if it's set to 0 there is no request for this
PN.

The ECU shall mask this information and detect which PN is relevant for the ECU
if any.


QUE ES un I-PDU?!?

### PDU structure
| NmPdu  | byte |
| :----- |  :------ |
| byte 0       | Source Node Identifier (default)       |
| byte 1       | Control Bit Vector (defautl)       |
| byte 2       | User Data 0       |
| byte 3       | User Data 1       |
| byte 3       | User Data 2       |
| byte 3       | User Data 3       |
| ...          | ...               |
| byte n       | User Data n-2       |


#### Control Bit Vector

| _  | Bit 7 |  Bit 6 |  Bit 5 |  Bit 4 |  Bit 3 |  Bit 2 |  Bit 1 |  Bit 0 |
| :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- |
| CBV       | Res       | PNI bit | Res | Active wakeup bit | NM coordination sleep ready | res | res | Repeat message request |

* Repeat message request:
  - if set a repeat message is requested
* NM coordination sleep bit
  - if set a start of sync shutdown is requested by the main coordinator
* Active Wakeup bit
  - 0: Node has not woken up the network (passive wakeup)
  - 1: Node has woken up the network (active wakeup)
* Partial network information bit (PNI bit)
  - If set, the message contains Partial network request information.

* Bits 1,2,5,7 are reserved for future usage.
