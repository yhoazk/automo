# Precision Time Protocol

The Precision time protocol is used to keep the computer and other devices'
clocks synchronized and accurate. The PTP is capable of submicrosecond accuracy
which improves the accuracy given by Network Time Protocol (NTP).
PTP is divided between kernal and user land.

## Introduction to PTP

The clocks managed by PTP follow a master-slave hierarchy. The slaves are synch
to their masters clock. The hierarchy is updated by the _best master clock_
algorithm running on every clock. The clock with only one port can be master or
slave and is called _boundary clock (BC)_. The top-level master is called
grand master clk which can be synchronized with a GPS. This way disparate
networks can be synchronized.

The HW support is the main advantage of PTP. It's supported by the next NICs
and switches (at least)

### Hardware Timestamping - MAC
|  Driver  | Hardware                 | Version |
|  :----:  | :----------------------: | :-----: |
|amd-xgbe  | AMD 10GbE Ethernet Soc   |  3.17   |
|bfin_mac  | Analog Blackfin          |  3.8    |
|bnx2x     | Broadcom NetXtremeII 10G |  3.18   |
|cpts      | Texas Instruments am335x |  3.8    |
|e1000e    | Intel 82574, 82583       |  3.9    |
|fm10k     | Intel FM10000            |  3.18   |
|fec       | Freescale i.mx6          |  3.8    |
|gianfar   | Freescale eTSEC PowerPC  |  3.0    |
|i40e      | Intel XL710 Family       |  3.14   |
|igb       | Intel 82576, 82580       |  3.5    |
|ixgbe     | Intel 82599              |  3.5    |
|mlx4      | Mellanox 40G PCI         |  3.14   |
|ptp_ixp46x| Intel IXP465             |  3.0    |
|ptp_phc   | Lapis EG20T PCH          |  3.5    |
|sfc       | Solarflare SFC9000       |  3.7    |
|stmmac    | STM Synopsys IP Core     |  3.10   |
|tg3       | Broadcom Tigon3 PCI      |  3.8    |
|tilegx    | Tilera GBE/XGBE          |  3.12   |

The package `linuxptp` includes `ptp4l` and `phc2sys`. `ptp4l` implements the
PTP boundary clock and ordinary clock. When HW time stamping is enabled, `ptp4l`
synchronizes the PTP HW clock to the master clock. With SW time stamping, syncs
with the master clock. `phc2sys` is needed only with HW time stamping to sync
the system clock to the PTP HW clk ot the NIC.

### Find if the iface supports PTP

```bash
udev info /sys/class/net/eth0
```

Go to the real dir:

```bash
cd `realpath /sys/class/net/eth0`

```

[src](https://doc.opensuse.org/documentation/leap/tuning/html/book.sle.tuning/cha.tuning.ptp.html)
[hw support](http://linuxptp.sourceforge.net/)
