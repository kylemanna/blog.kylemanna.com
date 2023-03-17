---
title: "FriendlyElec NanoPi R5S as PTP Grandmaster Clock with GNSS/GPS Discipline"
excerpt: "Cheap, ubiquitous, and feature rich RK3568 SBC with PTP and PPS hardware support"
category: hardware
tags: [ptp, linux, gps, gnss, rk3568, ieee1588, pps, nt]
header:
  image: https://i.imgur.com/4YsasKd.jpg
  overlay_color: "#000"
  overlay_filter: "0.5"
  overlay_image: https://i.imgur.com/4YsasKd.jpg
---

## The Dream

I've wanted to build a low-cost open source Linux system that could function as a PTP grandmaster for a while now.  This should be pretty doable with IEEE 1588 readily available (if you know where to look) and low-cost GPS receivers with reasonable quality 1PPS outputs.

## The Search for the Perfect Linux PTP + GNSS Platform

Hard requirements:
* At least one IEEE 1588 supported Ethernet port with some semblance of PTP clock support in the Linux driver.
* GPIOs that can trigger IRQs on the SoC to accurately time stamp the PPS signal.
* Accessible SoC UART (no USB or RS-232).
* Functional enclosure.
* Easy to purchase.
* Access to SoC datasheets / reference manuals to fix drivers.

Nice to haves:
* Board Schematics.
* Accessible source code.
* GPIO also routed to a hardware timer capture port for more accuracy.
* On-board eMMC.  I hate dealing with MicroSD cards outside of development.

## Runners Up

* [LBoxLS1028A](https://www.tq-group.com/en/products/tq-embedded/qoriq-layerscape/lboxls1028a/) - This seems like a superior PTP focused product due to the 4-port TSN (Time Sensitive Networking) 1 Gbps switch, but this is hard to buy.
* [ChangWang CW-6000 routers](https://www.changwang.com/product/406.html) - There are many versions of these routers an they all come with i226 Ethernet controllers now that should work great for PTP and the CPU has tons of power relative to the other runners up.  The problem here is that it's difficult to get the 1PPS signal into the processor. There is a `JCOM1` RS-232 port (ideally I want 3.3V TTL for GNSS module interfacing), but [some online discussions suggest the port doesn't work](https://forums.servethehome.com/index.php?threads/topton-jasper-lake-quad-i225v-mini-pc-report.36699/page-51#post-349259) (or the person doesn't know what they're doing).  I'd like to try this if I could convince myself that there's a low latency and low jitter path for the 1PPS signal.
* [OYDSSEY Blue J4125](https://www.seeedstudio.com/Odyssey-Blue-J4125-128GB-p-4921.html) - Harder to buy, at least in stock, expensive, unclear 1PPS integration, but seems plausible.  Uses i211 1 Gbps Ethernet controllers which work well for PTP.  Unclear how the GPIOs work with respect to the Intel processor.
* [STM32MP157D-DK1](https://www.st.com/en/evaluation-tools/stm32mp157d-dk1.html) - Out of stock, missing case, out of stock.
* [ODYSSEY – STM32MP157C](https://wiki.seeedstudio.com/ODYSSEY-STM32MP157C/) - Out of stock and missing enclosure. But has low cost CPU with PTP support.
* [Banana Pi BPI-W3](https://wiki.banana-pi.org/Banana_Pi_BPI-W3) - Interesting RK3588 platform, but would rather have the NanoPi R5S form factor and lower power CPU.
* Rockchip RK3228 and RK3228 platforms - Don't seem to support IEEE 1588 on the integrated Ethernet GMAC.  Seems the RK3566/RK3568 is unique.


## Winner: FriendlyElec NanoPi R5S

One of the most compelling features of the NanoPi R5S is that it's easy to buy from many vendors (I ordered from Amazon.com) and comes with an enclosure.  Once you receive it's ready to go as a router with no other messing around.

![NanoPI R5S internals](https://i.imgur.com/G35TLkD.jpg)

* [FriendlyElec Wiki Page](http://wiki.friendlyelec.com/wiki/index.php/NanoPi_R5S)
* [FriendlyElec Product Page](https://www.friendlyelec.com/index.php?route=product/product&product_id=287)


Let's walk through some of the features.

### Processor: Rockchip RK3568

![RK3568 block diagram](https://i.imgur.com/XCwHKFo.png)

The RK3568 is focused around 4x[ARM Cortex-A55](https://developer.arm.com/Processors/Cortex-A55) cores.


#### RK3568 1 Gbps Ethernet Controller

For Ethernet, the RK3568 processor has two integrated Ethernet MACs (`GMAC`) that support IEEE 1588-2002 (version 1) and IEEE 1588-2008 (version 2) and works with PTP over UDP (layer 3) and over Ethernet (layer 2).  The GMAC also supports Jumbo frames (up to 9018 bytes, 9022 for tagged VLAN packets).  In addition to this seems to support frames up to 16kB which I've never seen or used and definitely don't have hardware to use with it.

Initial testing shows that `linuxptp` and the 5.10 Linux kernel "just work" out of the box on FriendlyWrt and was able to synchronize with another device on my network.  Driver and hardware support can be verified by reviewing the kernel boot logs:

```
# dmesg | grep -e PTP -e 1588
[   26.384696] rk_gmac-dwmac fe2a0000.ethernet eth0: IEEE 1588-2008 Advanced Timestamp supported
[   26.384960] rk_gmac-dwmac fe2a0000.ethernet eth0: registered PTP clock
```

At minimum the "LAN" port will function using the integrated Ethernet controller.


### Ethernet Controller: 2x 2.5 Gbps Realtek RTL8125BG

These [Realtek RTL8125](https://www.realtek.com/en/products/communications-network-ics/item/rtl8125bg-s-cg) are pretty ubiquitous for low-cost Ethernet PCIe controllers and don't seem to have the issues some of the early Intel i225 controllers have (fixed with rev 3 and newly release i226).  I've been using one of these (rev 05) integrated in to my workstation motherboard for well over years without issue on Arch Linux with the mainline kernel driver.

I was surprised to learn that these Etherent controllers also support IEEE 1588-2002, IEEE 1588-2008, and IEEE 802.1AS.  Howver, the mainline kernel driver doesn't support it.  It does appear that that the [Realtek vendor out-of-tree driver](https://www.realtek.com/en/component/zoo/category/network-interface-controllers-10-100-1000m-gigabit-ethernet-pci-express-software) (version 9.009.02 at time of writing) does seem to support PTP. I haven't verified this just yet.


### Expansion Header: GPIO + UART access

There's a 12-pin FPC connector that exposes 3x integrated UARTs, GPIOS, and PWM capture pins.  With minimal device tree updates this easily supports UART5 via `/dev/ttyS5` and `GPIO3_C5` / `gpio-117` works with the 1PPS input in IRQ mode.

### Enclosure

The enclosure feels high quality and serves well as a heatsink.  It's readily accessible and often easier to buy the NanoPi R5S with the case then without.

Furthermore, there's unused cut-out for a SMA WiFi antenna adapter on the back. I hope to use this for a GNSS antenna once I figure out how to tuck the GNSS module into the case.


## First Look

Ships with FriendlyWrt 21.02. Out of the box `linuxptp` works largely out of the box.

I built FriendlyWrt 22.03 so I could incorporate the `UART5` and 1PPS input device tree changes without much hassle using the directions and an MicroSDXC card.

After some initial wiring with a 12-pin FPC breakout out board, I was able to get `gpsd` to read a UBLOX NEO-M8N gps module.  I then fed that to `chrony` which verified the time was pretty close to right.  Finally, I configured `chrony` to read the 1PPS signal (`/dev/pps1` in my case) to precisely tune the clock after setting the time.


Hardware timestamping info:

```
root@FriendlyWrt:~# ethtool -T eth0
Time stamping parameters for eth0:
Capabilities:
        hardware-transmit     (SOF_TIMESTAMPING_TX_HARDWARE)
        software-transmit     (SOF_TIMESTAMPING_TX_SOFTWARE)
        hardware-receive      (SOF_TIMESTAMPING_RX_HARDWARE)
        software-receive      (SOF_TIMESTAMPING_RX_SOFTWARE)
        software-system-clock (SOF_TIMESTAMPING_SOFTWARE)
        hardware-raw-clock    (SOF_TIMESTAMPING_RAW_HARDWARE)
PTP Hardware Clock: 0
Hardware Transmit Timestamp Modes:
        off                   (HWTSTAMP_TX_OFF)
        on                    (HWTSTAMP_TX_ON)
Hardware Receive Filter Modes:
        none                  (HWTSTAMP_FILTER_NONE)
        all                   (HWTSTAMP_FILTER_ALL)
        ptpv1-l4-event        (HWTSTAMP_FILTER_PTP_V1_L4_EVENT)
        ptpv1-l4-sync         (HWTSTAMP_FILTER_PTP_V1_L4_SYNC)
        ptpv1-l4-delay-req    (HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ)
        ptpv2-l4-event        (HWTSTAMP_FILTER_PTP_V2_L4_EVENT)
        ptpv2-l4-sync         (HWTSTAMP_FILTER_PTP_V2_L4_SYNC)
        ptpv2-l4-delay-req    (HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ)
        ptpv2-event           (HWTSTAMP_FILTER_PTP_V2_EVENT)
        ptpv2-sync            (HWTSTAMP_FILTER_PTP_V2_SYNC)
        ptpv2-delay-req       (HWTSTAMP_FILTER_PTP_V2_DELAY_REQ)

root@FriendlyWrt:~# ethtool -T eth1
Time stamping parameters for eth1:
Capabilities:
        software-transmit     (SOF_TIMESTAMPING_TX_SOFTWARE)
        software-receive      (SOF_TIMESTAMPING_RX_SOFTWARE)
        software-system-clock (SOF_TIMESTAMPING_SOFTWARE)
PTP Hardware Clock: none
Hardware Transmit Timestamp Modes: none
Hardware Receive Filter Modes: none

root@FriendlyWrt:~# ethtool -T eth2
Time stamping parameters for eth2:
Capabilities:
        software-transmit     (SOF_TIMESTAMPING_TX_SOFTWARE)
        software-receive      (SOF_TIMESTAMPING_RX_SOFTWARE)
        software-system-clock (SOF_TIMESTAMPING_SOFTWARE)
PTP Hardware Clock: none
Hardware Transmit Timestamp Modes: none
Hardware Receive Filter Modes: none
```


Chrony timing stats comparing time to public NTP servers:

```
root@FriendlyWrt:~# chronyc tracking 
Reference ID    : 50505300 (PPS)
Stratum         : 1
Ref time (UTC)  : Thu Sep 29 04:52:20 2022
System time     : 0.000000314 seconds slow of NTP time
Last offset     : -0.000000304 seconds
RMS offset      : 0.000000536 seconds
Frequency       : 29.929 ppm fast
Residual freq   : -0.000 ppm
Skew            : 0.025 ppm
Root delay      : 0.000000001 seconds
Root dispersion : 0.000016748 seconds
Update interval : 16.0 seconds
Leap status     : Normal
```

```
root@FriendlyWrt:~# chronyc -n sources -v

  .-- Source mode  '^' = server, '=' = peer, '#' = local clock.
 / .- Source state '*' = current best, '+' = combined, '-' = not combined,
| /             'x' = may be in error, '~' = too variable, '?' = unusable.
||                                                 .- xxxx [ yyyy ] +/- zzzz
||      Reachability register (octal) -.           |  xxxx = adjusted offset,
||      Log2(Polling interval) --.      |          |  yyyy = measured offset,
||                                \     |          |  zzzz = estimated error.
||                                 |    |           \
MS Name/IP address         Stratum Poll Reach LastRx Last sample               
===============================================================================
#- GPS                           0   4   377    23  -8931us[-8931us] +/-   51ms
#* PPS                           0   4   377    22    +91ns[ +110ns] +/-  840ns
^- 2600:c05:3010:50:47::1        2  10   377   172   +609us[ +609us] +/-   59ms
^- 72.30.35.88                   2  10   377   444  +2263us[+2263us] +/-   24ms
^- 2604:2dc0:101:200::b9d        2  10   377   481  +1199us[+1199us] +/-   71ms
^- 44.4.53.4                     2  11   377   26m  +5413us[+5449us] +/-   59ms
```

```
root@FriendlyWrt:~# chronyc -n sourcestats -v
                             .- Number of sample points in measurement set.
                            /    .- Number of residual runs with same sign.
                           |    /    .- Length of measurement set (time).
                           |   |    /      .- Est. clock freq error (ppm).
                           |   |   |      /           .- Est. error in freq.
                           |   |   |     |           /         .- Est. offset.
                           |   |   |     |          |          |   On the -.
                           |   |   |     |          |          |   samples. \
                           |   |   |     |          |          |             |
Name/IP Address            NP  NR  Span  Frequency  Freq Skew  Offset  Std Dev
==============================================================================
GPS                         6   3    81    -55.987    208.159    -14ms  1630us
PPS                         7   4    95     -0.015      0.082   -143ns   999ns
2600:c05:3010:50:47::1      6   5   86m     +0.083      0.404   +429us   222us
72.30.35.88                 7   5  103m     -0.007      0.133  +1987us   108us
2604:2dc0:101:200::b9d     14   9  224m     -0.188      0.057   +897us   223us
44.4.53.4                  10   7  309m     -0.265      0.274  +5891us  1061us
```

Some PPS testing testing using `ppswatch`

```
root@FriendlyWrt:~# ppswatch -a /dev/pps1
trying PPS source "/dev/pps1"
found PPS source "/dev/pps1"
timestamp: 1664427237, sequence: 163286, offset:  -5414
timestamp: 1664427238, sequence: 163287, offset:   2930
timestamp: 1664427239, sequence: 163288, offset:  -2725
timestamp: 1664427240, sequence: 163289, offset:   3870
timestamp: 1664427241, sequence: 163290, offset:  -3535
timestamp: 1664427242, sequence: 163291, offset:   1602
timestamp: 1664427243, sequence: 163292, offset:  -2012
timestamp: 1664427244, sequence: 163293, offset:   2252
timestamp: 1664427245, sequence: 163294, offset:   3604
timestamp: 1664427246, sequence: 163295, offset:  -3794
timestamp: 1664427247, sequence: 163296, offset:  -3901
timestamp: 1664427248, sequence: 163297, offset:  -4883
timestamp: 1664427249, sequence: 163298, offset:   3177
timestamp: 1664427250, sequence: 163299, offset:  -3638
timestamp: 1664427251, sequence: 163300, offset:  -2287
timestamp: 1664427252, sequence: 163301, offset:   2565
timestamp: 1664427253, sequence: 163302, offset:   2750
timestamp: 1664427254, sequence: 163303, offset:   3227
timestamp: 1664427255, sequence: 163304, offset:   2828
timestamp: 1664427256, sequence: 163305, offset:   3597
timestamp: 1664427257, sequence: 163306, offset:  -5259
timestamp: 1664427258, sequence: 163307, offset:   1634
timestamp: 1664427259, sequence: 163308, offset:  -4014
timestamp: 1664427260, sequence: 163309, offset:   2881
timestamp: 1664427261, sequence: 163310, offset:  -4222
timestamp: 1664427262, sequence: 163311, offset:   3842
^C

Total number of PPS signals: 26
Maximum divergence: 5414
Mean value: -189.423
Standard deviation: 3460.59
```

## Next Steps


### GNSS Improvements

I need to use a proper GNSS antenna that can be well placed outside.  Currently I'm using a quadcopter GNSS module with integrated ceramic antenna and placed it in the window.  With a different GNSS module with a SMA connector I'll be able to place the antenna outside for better signal.  Currently the signal drops out as the GNSS satellites come and go. I've ordered a cheap (possibly fake) UBLOX NEO-M8N from somewhere in China with a SMA and U.FL connector.  In a perfect world I'll be able to tuck this + the FPC wiring in the enclosure and run a U.FL to SMA cable to the plugged WiFi SMA cutout in the enclosure.

### Enable PTP support on the RTL8125

Need to dig in to the out-of-tree kernel driver and see why it doesn't show up as PTP hardware clock.

### Add in PTP grandmaster support on all ports

The `linuxptp` daemon in OpenWrt works well enough on a single port, but I'd make to make it work on all ports.  The struggle here is that typically I'd bridge the interfaces and be done, but PTP doesn't really work with bridges.  Need to think about what's a sensible network setup where I can keep this as a "simple" timing device and not turn in to a complicated router.

### Record time statistics

Recording the chrony statistics in something like InfluxDB would be idea, but not sure if that'd work well on an embedded device.  Then display a dashboard in Grafana to track performance metrics:

1. SNR for each satellite seen
2. Corrected oscillator error in ppm over time
3. 1PPS jitter/offset

### Better PPS Timestamping

It's unclear to me why there's so much delay and jitter in the PPS timestamping.  Likely this is just the latency of the kernel servicing the IRQ up to the resolution of the main system clock (which I need to look-up, 24 MHz?).

First steps are to turn off dynamic ticks and use the performance `cpufreq` governor.

Beyond that, then using the PWM capture unit (`PWM15`) would be much better.  Seems that the fastest I can drive the PWM peripheral is 24 MHz which means only about 41.67ns of resolution, but this seems better then the ±3000ns observed with the PPS test above with no notuning.

I verified the `PWM15` output works, but the capture and compare unit reports "not implemented" during cursory exploration.


### Package up FriendlyWrt to just work

Assemble a FriendlyWrt image that just works out of the box for this application that incorporates all the changes above.

### GNSS PCB integration

Create a simple PCB to integrate a UBLOX NEO-M8N (or better) that easily interface with the FPC expansion connector.  Ideally this would be easily tucked within the enclosure and expose a SMA connector at the WiFi antenna cut-out near the USB-C connector.
