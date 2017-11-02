# CAN (Controler Area Network)



## [ISO 15765-2](https://es.wikipedia.org/wiki/ISO_15765-2)

* The max length for a ISO-TP is 4095 bytes of payload.
* In the OSI model, ISO-TP covers the Network layer(3) and the transport layer(4)

Also called ISO-TP layer (Layer 3 and 4 of OSI) is the standard for sending data
packets over a can bus.
This protocol allows the transport of messages that exceed 8 byte, which is the
max payload of a single CAN frame.

ISO-TP segments longer messages into multiple frames, adding metadata which describe
the meaning of each consecutive individual frames, then enabling the reassembly
of the complete message by the recipient.

The metadata uses a byte of the 8 usable bytes in the CAN frame, leaving thus
only 7 bytes for the data. The metadata is called **Protocol Control Information**
PCI. This PCI can have 1,2,3 bytes of length.
