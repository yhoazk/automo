#  Model OSI
[SRC1](http://www.erg.abdn.ac.uk/users/gorry/course/road-map.html)



Open Systems interconection smodel consists of 7 layers:

## 1: The physical Layer

Responsible for Rx/Tx of unstructured raw data between a device and a pysical
medium. This layer not only deals with where the information will travel, but
how we can increase the throughput ans efficiency, reduce noise and guarantee
consisntecy. In this layer we work with wire, fibres, radio signals etc.

## 2: The data link layer

This layer deals with managing how a connection from node A to node B works.
This layer also verifies that the data sent by the lower layer was sent
cottectly and establishes and terminates connections between nodes.

The most known component of this layer is the Medium acces control protocol
(MAC protocol). This protocol defines how computers get access to the data
and permission to transmit it. One of the components of this protocol is the
MAC address, which is a globally unique identifier (in theory) which is the 
main pirce for definig the communication between nodes in a network. It works
as a guarantee that the two nodes that are being linked are the intended ones.

### CAM overflow

The content addressable memory (CAM) inside the switches, which contains the
lookup relating ports and mac addresses can be attacked with multiple spoofed
MAC addresses after the MAC is full starts to flood all traffic to all ports of
the switch.

## 3: The network layer

Also known as the IP layer, is responsible for Tx information to different 
networks in variable lengths (packages) it maps the MAC to the IP addresses in
a way that it can route interconnections. The type of connections that the IP
layer hadles is logically different from the connections made in the layer 2.
Layer 2 takes local conections while layer 3 goes beyond local network.
    
## 4: The transport layer

This layer acts as a management control, ensures that the data traveling from
one place to another is consistent and with in the limits of size. In this
layer reside the TCP and UDP protocols. UDP is fast but unreliable, TCP is 
slower and more reliable and also dedicated to unicast communication.

## 5: The session layer

This layer controls the traffic in the node, checks that all the connections
that are initiated are terminated. Defines the duration of the connections this
layer performs the handshake to ensure that both nodes are ready to start
the communication. When a connection stops, this layer decide if should be
restarted or terminated.

## 6: The presentation layer

This layer transforms data packets into data formats that can be understood
by the next layer. Normally encryption and compression is done here as it 
can encapsulate that logic and make it visible to the 7th layer.

## 7: The application layer

This application allows applications to access the network, identifies
communication partners and determines resoruce availability. Provides
the final access to final data applications. This layer is where most of
the developers work. 
