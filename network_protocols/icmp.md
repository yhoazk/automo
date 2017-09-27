# [ICMP Internet control Message Protocol](https://tools.ietf.org/html/rfc792)

This is used as a support mechanism by network devices, includign routers, to send error messages and
operational information.

For example to indicate:
- Requested service not available.
- Host could not be reached.

It's not used to exchange date between systems, nor it's employed by end-user network applications.

**ICMP errors are directed to the source IP address of the originating packet**

## IPv4

The ICMP is a supporting protocol in the internet protocol, used to send error messages
and operational information.


## Summary:

Summary of Message Types

    0  Echo Reply

    3  Destination Unreachable

    4  Source Quench

    5  Redirect

    8  Echo

    11  Time Exceeded

    12  Parameter Problem

    13  Timestamp

    14  Timestamp Reply

    15  Information Request

    16  Information Reply


### Datagram structure:

    0                   1                   2                   3
    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    |     Type      |     Code      |          Checksum             |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    |                             unused                            |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    |      Internet Header + 64 bits of Original Data Datagram      |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+



   IP Fields:

   Destination Address

      The source network and address from the original datagram's data.

   ICMP Fields:

   Type

      3

   Code

      0 = net unreachable;

      1 = host unreachable;

      2 = protocol unreachable;

      3 = port unreachable;

      4 = fragmentation needed and DF set;

      5 = source route failed.

   Checksum

      The checksum is the 16-bit ones's complement of the one's
      complement sum of the ICMP message starting with the ICMP Type.
      For computing the checksum , the checksum field should be zero.
      This checksum may be replaced in the future.

   Internet Header + 64 bits of Data Datagram

      The internet header plus the first 64 bits of the original

### Control messages

#### Echo or Echo reply

      The address of the source in an echo message will be the
      destination of the echo reply message.  To form an echo reply
      message, the source and destination addresses are simply reversed,
      the type code changed to 0, and the checksum recomputed.

#### Source Quench (Deprecated)
 - Type: 4
 - Code: 0
Request that teh sender decrease the rate of messages sent to a router host.

#### Redirect
 - Type: 5
 - Code:
 	- 0: redirect for network
	- 1: Redirect for host
	- 2: Redirect for type of service and network
	- 3: redirect for type of service and host.
#### Time exceeded
 - Type: 11
The TTL (time to live) field reached zero or a host failed to reassemble a fragmented datagram within the expected time.

#### Timestamp and Timestamp reply
Message used for sync

#### Address mask request
Sent ba a host to a router in order t obtain the appropiate subnet mask.

#### Address mask reply
Carries the appropiate subnet mask for a address mask request.

#### Destination unreacheable

informs that the destination is unreacheable. Could be generated as a result of a TCP or UDP.
It's not generated if the originator was a multicast datagram
