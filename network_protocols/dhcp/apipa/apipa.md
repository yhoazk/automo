  # Automatic Private Internet Protocol Addressing

Automatic private IP addressing is a windows protocol (win98+) to obtain a
dynamically assigned direction. It is used when there is no DHCP.
The internet assigned numbers autority (IANA) has reserved the range:
`169.254.0.0 - 169.254.255.255` for automatic private IP addressing. This
way is guaranteed not to conflict with routable addresses. The mask is set
to `255.255.0.0`. For _windows_ APIPA is enabled by default.<Down>



For linux is called _Zeroconf_, Zero configuration networking consists of
three elements:

- Network layer address assignment


- Translation between network names and network addresses

- Location or discovery of services by name and protocol

The project in linux for zeroconfig, which includesd APIPA (RFC 3927)
is part of the Avahi project
