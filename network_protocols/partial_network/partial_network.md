# Partial Network

Partial networking is the concept of turning off network segments to save 
power, the power comes when the devices in the segment of the network turn-off
their CPUs. In order to be able to wake-up the device again the network, or 
FR or CAN device remains operational, but also in a low power state.

The device can be enabled by sending a udp-nm message which contains the
information about which network segment should be enabled.

See `[udp-nm](../udp_nm)`
