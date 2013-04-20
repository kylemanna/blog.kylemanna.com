---
layout: post
title: "My WiFi access point revisited"
tagline: "RIP Linksys and Ubiquiti"
category: 
tags: []
---
{% include JB/setup %}


No more consumer routers!
-------------------------

A while ago I dumped my consumer NAT router in favor of using my desktop router.  I do most of my work at my apartment on my desktop, so why not make it my router and file server?  Great question, great choice.  No longer am I restricted by buggy firmware, half implemented DHCP or DNS servers etc.  I then demoted by Linksys WRT54G running DD-WRT to just AP roles which lasted for a few more years before the hardware finally died.  RIP WRT54G, you outlived your useful life and delivered above and beyond my expectations.

My Linux desktop / server with an additional Intel NIC and Linux NAT capabilities makes a pretty awesome combination.  Add dnsmasq for simple DHCP, DNS and sometimes TFTP capabilities.  No more consumer routers, last thing I need is more stuff to configure.

Enter the Ubiquiti PicoStation2
-------------------------------

I read alot of good things about Ubiquiti a while ago when I was planning to build a quad copter and do cool things with Linux + Pandaboard.  The Picostation2 was supposed to be the high powered radio to control the who thing.  Life happened.  The quad never got built, but I didn't give up until after I bought a few pieces such as the Picostation2.  After my Linksys WRT54G died, the Picostation2 was put into action.  I was impressed by the polish of the AirOS web interface.  The Linux SDK seemed cool (until I learned how /old/ the kernel actually was).  But, all my devices (Mac Book Retina Pro, Nexus 4, Lenovo Thinkpad, etc) all had issues with the AP just not working that well.  The connection would just die.  I attempted to reconfigure it and fix it thinking it was my fault, but my attempts were in vain.

A work project demanded WiFi access for some testing at home and the PicoStation2 was making this more difficult.  The PictionStation2 was then retired back to the drawer.

Linksys EA6400
--------------

I bought a Linksys EA6400 on sale thinking I could just replace my AP and be done.  Nope, never that simple.  Linksys created this "Smart Wi-Fi" feature that makes it a major pain to configure.  Just Google "Linksys Smart Wi-Fi" and see what people have to say about the "502 Bad Gateway" error the router constantly threw me whenever I tried to use it as a bridging access point.

Apparently Smart Wi-Fi phones home to Linksys's cloud to allow you to configure it from the web.  What if the Internet connection isn't configured?  Oh, use the included CD for Windows.  I don't even have an optical drive reader or easy access to Windows.  I did some tricks and got it to "kind of work" but not really.

I shipped it back several days later.  I'm done with Linksys and will likely never buy a Linksys product if this is the route they are going.  That's too bad, I loved my old WRT54G and was hoping the EA6400 would be similar.  I was wrong.

Linux + HostAPd + TL-WDN4800
----------------------------

Linux wireless is a lot more stable then it was several years ago, and host/software access points now work quite well.  This coupled with the idea that my desktop / server already runs my NAT, DNS, DHCP and this is a no brainer.  I looked in to buying a PCIe Wi-Fi card.

I settled on the TP-Link TL-WDN4800 card.  It features an Atheros AR9380 that can do 3 spatial streams, Short-GI, 2.4 GHz, 5 GHz, and HT40 (40 MHz channels).  When configured as a 5 GHz AP my rMBP connects to with a linksys of 450 Mbps.  I can't ask for any more.  Speed tests show over 100 Mb/s actual data rate.  Beyond that I didn't test much.  If I need speed faster then that I'll use gigabit Ethernet.  My Nexus 4 has only 1 spatial stream, and negotiates a bitrate of 72 Mbps, which is the fastest the device can do.  Did I mention the card was only $45 and the Ubuntu 12.10 + development Linux 3.9 kernel just works after a little hostapd config?  I paid 3x this for the EA6400 that barely worked (even though it was dual simultaneous band and had 802.11ac).

Back to Reality
---------------

While the 450 Mbps bitrate of 5 GHz + HT40 + Short-GI was nice, it didn't work with all my devices.  As a result I had to fall back to 2.4 GHz channels and HT20.  My rMBP now gets link speed of 217 Mb/s which is still pretty good.  Most of the time it will do in excess of 50 Mb/s of real world data throughput.  Plenty fast for web surfing.  My Nexus 4 is still happy at 72 Mb/s.

I also chose to create a separate subnet for my Wi-Fi clients.  This reduced broadcast traffic from my wired devices and helps keep the Wi-Fi channel a little quieter and improves performance slightly.  I also believe that people are ignorant and simply bridge devices because they don't understand routing and firewall rules.... but that's just me. :)

Configuration
-------------

For people interested in my configuration files see below.  Don't forget to enable the hostapd service <code>update-rc.d hostapd enable</code>.

#### hostapd.conf ####

	interface=wlan0
	driver=nl80211
	ssid=<your ssid>
	macaddr_acl=0
	auth_algs=1
	ignore_broadcast_ssid=0
	wpa=2
	wpa_passphrase=<your passphrass>
	wpa_key_mgmt=WPA-PSK
	wpa_pairwise=TKIP
	rsn_pairwise=CCMP

	#country_code=US
	#ieee80211d=1

	ieee80211n=1
	wmm_enabled=1
	ht_capab=[HT40-][HT40+][SHORT-GI-20][SHORT-GI-40][TX-STBC][RX-STBC1][DSSS_CCK-40][LDPC]

    # 5 GHz
	#hw_mode=a
	#channel=149
	#channel=157

    # 2.4 GHz
	hw_mode=g
	# 70.7 Mbit/s
	#channel=1 

	# 62.6 Mbit/s + jitter
	#channel=2

	# 57.4 Mbits/s
	channel=7


#### /etc/network/interfaces ####

	...

	auto wlan0
	iface wlan0 inet static
			address 192.168.11.10
			netmask 255.255.255.0


#### iw phy0 info ####

	$ iw phy0 info
	Wiphy phy0
		Band 1:
			Capabilities: 0x11ef
				RX LDPC
				HT20/HT40
				SM Power Save disabled
				RX HT20 SGI
				RX HT40 SGI
				TX STBC
				RX STBC 1-stream
				Max AMSDU length: 3839 bytes
				DSSS/CCK HT40
			Maximum RX AMPDU length 65535 bytes (exponent: 0x003)
			Minimum RX AMPDU time spacing: 8 usec (0x06)
			HT TX/RX MCS rate indexes supported: 0-23
			Frequencies:
				* 2412 MHz [1] (20.0 dBm)
				* 2417 MHz [2] (20.0 dBm)
				* 2422 MHz [3] (20.0 dBm)
				* 2427 MHz [4] (20.0 dBm)
				* 2432 MHz [5] (20.0 dBm)
				* 2437 MHz [6] (20.0 dBm)
				* 2442 MHz [7] (20.0 dBm)
				* 2447 MHz [8] (20.0 dBm)
				* 2452 MHz [9] (20.0 dBm)
				* 2457 MHz [10] (20.0 dBm)
				* 2462 MHz [11] (20.0 dBm)
				* 2467 MHz [12] (20.0 dBm)
				* 2472 MHz [13] (20.0 dBm)
				* 2484 MHz [14] (disabled)
			Bitrates (non-HT):
				* 1.0 Mbps
				* 2.0 Mbps (short preamble supported)
				* 5.5 Mbps (short preamble supported)
				* 11.0 Mbps (short preamble supported)
				* 6.0 Mbps
				* 9.0 Mbps
				* 12.0 Mbps
				* 18.0 Mbps
				* 24.0 Mbps
				* 36.0 Mbps
				* 48.0 Mbps
				* 54.0 Mbps
		Band 2:
			Capabilities: 0x11ef
				RX LDPC
				HT20/HT40
				SM Power Save disabled
				RX HT20 SGI
				RX HT40 SGI
				TX STBC
				RX STBC 1-stream
				Max AMSDU length: 3839 bytes
				DSSS/CCK HT40
			Maximum RX AMPDU length 65535 bytes (exponent: 0x003)
			Minimum RX AMPDU time spacing: 8 usec (0x06)
			HT TX/RX MCS rate indexes supported: 0-23
			Frequencies:
				* 5180 MHz [36] (23.0 dBm)
				* 5200 MHz [40] (23.0 dBm)
				* 5220 MHz [44] (23.0 dBm)
				* 5240 MHz [48] (23.0 dBm)
				* 5260 MHz [52] (23.0 dBm) (passive scanning, no IBSS, radar detection)
				* 5280 MHz [56] (23.0 dBm) (passive scanning, no IBSS, radar detection)
				* 5300 MHz [60] (23.0 dBm) (passive scanning, no IBSS, radar detection)
				* 5320 MHz [64] (23.0 dBm) (passive scanning, no IBSS, radar detection)
				* 5500 MHz [100] (disabled)
				* 5520 MHz [104] (disabled)
				* 5540 MHz [108] (disabled)
				* 5560 MHz [112] (disabled)
				* 5580 MHz [116] (disabled)
				* 5600 MHz [120] (disabled)
				* 5620 MHz [124] (disabled)
				* 5640 MHz [128] (disabled)
				* 5660 MHz [132] (disabled)
				* 5680 MHz [136] (disabled)
				* 5700 MHz [140] (disabled)
				* 5745 MHz [149] (30.0 dBm)
				* 5765 MHz [153] (30.0 dBm)
				* 5785 MHz [157] (30.0 dBm)
				* 5805 MHz [161] (30.0 dBm)
				* 5825 MHz [165] (30.0 dBm)
			Bitrates (non-HT):
				* 6.0 Mbps
				* 9.0 Mbps
				* 12.0 Mbps
				* 18.0 Mbps
				* 24.0 Mbps
				* 36.0 Mbps
				* 48.0 Mbps
				* 54.0 Mbps
		max # scan SSIDs: 4
		max scan IEs length: 2257 bytes
		Coverage class: 0 (up to 0m)
		Supported Ciphers:
			* WEP40 (00-0f-ac:1)
			* WEP104 (00-0f-ac:5)
			* TKIP (00-0f-ac:2)
			* CCMP (00-0f-ac:4)
			* CMAC (00-0f-ac:6)
		Available Antennas: TX 0x7 RX 0x7
		Configured Antennas: TX 0x7 RX 0x7
		Supported interface modes:
			 * IBSS
			 * managed
			 * AP
			 * AP/VLAN
			 * WDS
			 * monitor
			 * mesh point
			 * P2P-client
			 * P2P-GO
		software interface modes (can always be added):
			 * AP/VLAN
			 * monitor
		valid interface combinations:
			 * #{ managed, WDS, P2P-client } <= 2048, #{ AP, mesh point, P2P-GO } <= 8,
			   total <= 2048, #channels <= 1, STA/AP BI must match
		Supported commands:
			 * new_interface
			 * set_interface
			 * new_key
			 * new_beacon
			 * new_station
			 * new_mpath
			 * set_mesh_params
			 * set_bss
			 * authenticate
			 * associate
			 * deauthenticate
			 * disassociate
			 * join_ibss
			 * join_mesh
			 * remain_on_channel
			 * set_tx_bitrate_mask
			 * action
			 * frame_wait_cancel
			 * set_wiphy_netns
			 * set_channel
			 * set_wds_peer
			 * Unknown command (82)
			 * Unknown command (81)
			 * Unknown command (84)
			 * Unknown command (87)
			 * Unknown command (85)
			 * Unknown command (89)
			 * Unknown command (92)
			 * testmode
			 * connect
			 * disconnect
		Supported TX frame types:
			 * IBSS: 0x00 0x10 0x20 0x30 0x40 0x50 0x60 0x70 0x80 0x90 0xa0 0xb0 0xc0 0xd0 0xe0 0xf0
			 * managed: 0x00 0x10 0x20 0x30 0x40 0x50 0x60 0x70 0x80 0x90 0xa0 0xb0 0xc0 0xd0 0xe0 0xf0
			 * AP: 0x00 0x10 0x20 0x30 0x40 0x50 0x60 0x70 0x80 0x90 0xa0 0xb0 0xc0 0xd0 0xe0 0xf0
			 * AP/VLAN: 0x00 0x10 0x20 0x30 0x40 0x50 0x60 0x70 0x80 0x90 0xa0 0xb0 0xc0 0xd0 0xe0 0xf0
			 * mesh point: 0x00 0x10 0x20 0x30 0x40 0x50 0x60 0x70 0x80 0x90 0xa0 0xb0 0xc0 0xd0 0xe0 0xf0
			 * P2P-client: 0x00 0x10 0x20 0x30 0x40 0x50 0x60 0x70 0x80 0x90 0xa0 0xb0 0xc0 0xd0 0xe0 0xf0
			 * P2P-GO: 0x00 0x10 0x20 0x30 0x40 0x50 0x60 0x70 0x80 0x90 0xa0 0xb0 0xc0 0xd0 0xe0 0xf0
			 * Unknown mode (10): 0x00 0x10 0x20 0x30 0x40 0x50 0x60 0x70 0x80 0x90 0xa0 0xb0 0xc0 0xd0 0xe0 0xf0
		Supported RX frame types:
			 * IBSS: 0x40 0xb0 0xc0 0xd0
			 * managed: 0x40 0xd0
			 * AP: 0x00 0x20 0x40 0xa0 0xb0 0xc0 0xd0
			 * AP/VLAN: 0x00 0x20 0x40 0xa0 0xb0 0xc0 0xd0
			 * mesh point: 0xb0 0xc0 0xd0
			 * P2P-client: 0x40 0xd0
			 * P2P-GO: 0x00 0x20 0x40 0xa0 0xb0 0xc0 0xd0
			 * Unknown mode (10): 0x40 0xd0
		Device supports RSN-IBSS.
		WoWLAN support:
			 * wake up on disconnect
			 * wake up on magic packet
			 * wake up on pattern match, up to 6 patterns of 1-256 bytes
		HT Capability overrides:
			 * MCS: ff ff ff ff ff ff ff ff ff ff
			 * maximum A-MSDU length
			 * supported channel width
			 * short GI for 40 MHz
			 * max A-MPDU length exponent
			 * min MPDU start spacing
		Device supports TX status socket option.
		Device supports HT-IBSS.

#### Kernel Info ####

	$ uname -a
	Linux core 3.9.0-999-generic #201303290406 SMP Fri Mar 29 08:07:25 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux

	$ modinfo ath9k
	filename:       /lib/modules/3.9.0-999-generic/kernel/drivers/net/wireless/ath/ath9k/ath9k.ko
	license:        Dual BSD/GPL
	description:    Support for Atheros 802.11n wireless LAN cards.
	author:         Atheros Communications
	srcversion:     FCAC5F4D12AA0733811B1B7
	alias:          platform:qca955x_wmac
	alias:          platform:ar934x_wmac
	alias:          platform:ar933x_wmac
	alias:          platform:ath9k
	alias:          pci:v0000168Cd00000036sv*sd*bc*sc*i*
	alias:          pci:v0000168Cd00000037sv*sd*bc*sc*i*
	alias:          pci:v0000168Cd00000034sv*sd*bc*sc*i*
	alias:          pci:v0000168Cd00000033sv*sd*bc*sc*i*
	alias:          pci:v0000168Cd00000032sv*sd*bc*sc*i*
	alias:          pci:v0000168Cd00000030sv*sd*bc*sc*i*
	alias:          pci:v0000168Cd0000002Esv*sd*bc*sc*i*
	alias:          pci:v0000168Cd0000002Dsv*sd*bc*sc*i*
	alias:          pci:v0000168Cd0000002Csv*sd*bc*sc*i*
	alias:          pci:v0000168Cd0000002Bsv*sd*bc*sc*i*
	alias:          pci:v0000168Cd0000002Asv*sd*bc*sc*i*
	alias:          pci:v0000168Cd00000029sv*sd*bc*sc*i*
	alias:          pci:v0000168Cd00000027sv*sd*bc*sc*i*
	alias:          pci:v0000168Cd00000024sv*sd*bc*sc*i*
	alias:          pci:v0000168Cd00000023sv*sd*bc*sc*i*
	depends:        ath9k_hw,ath9k_common,mac80211,ath,cfg80211
	intree:         Y
	vermagic:       3.9.0-999-generic SMP mod_unload modversions 
	parm:           debug:Debugging mask (uint)
	parm:           nohwcrypt:Disable hardware encryption (int)
	parm:           blink:Enable LED blink on activity (int)
	parm:           btcoex_enable:Enable wifi-BT coexistence (int)
	parm:           enable_diversity:Enable Antenna diversity for AR9565 (int)


#### Other commands that may be useful for testing setups ####

*  Dump info about channels: <code>iw dev wlan0 survey dump</code>
*  Dump info about connected stations: <code>iw dev wlan0 station dump</code>
