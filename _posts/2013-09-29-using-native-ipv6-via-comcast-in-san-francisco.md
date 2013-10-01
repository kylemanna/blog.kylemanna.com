---
layout: post
title: "Using Native IPv6 via Comcast in San Francisco"
tagline: "go native"
category: ipv6
tags: [ubuntu, linux, ipv6, comcast, san francisco]
---
{% include JB/setup %}

What is IPv6?
=============

IPv6 is the next generation Internet protocol with a *significantly* larger address space (among other things) when compared with IPv4.  [Google](http://lmgtfy.com/?q=ipv6) is your friend and [Wikipedia](http://en.wikipedia.org/wiki/IPv6) has an article as well if you don't already know what IPv6 is.

Poking around the Internet is sure to yield some dramatic blog articles on just how much bigger the address space actually is.  Go fish.

My Goals
========

I want to talk about using IPv6 natively (that is no dependence on tunnels over IPv4 networks) with Comcast Internet in San Francisco, CA.

* How to get an IPv6 address using Linux (Ubuntu 13.04) as a host machine.
* How to request a prefix delegation (PD) and what that is.
* How to break-up the PD and allocate a subnet to internal networks (WLAN and LAN) to and from the Internet without NAT.
* How to use iptables to secure the newly routed and exposed networks.

IPv6 Basics
===========

There are some details of IPv6 that are radically different from IPv4 and took me a while to understand.

Subnets
-------

The subnets on IPv6 are all at least /64 networks.  Everything.  Even link-local interfaces where only 2 address are in use.  At first this seems like a colossal waste of the address space, but the address space is in fact insanely large.  It's also generally bad practice to attempt to subnet anything larger then a /64 prefix.  This is because of the way Stateless Address Autoconfiguration (SLAAC) works and assumes /64 subnets.  I tried to use smaller subnets until I learned what was really going on.  Don't make subnets smaller then /64, it's a lost cause unless you have a *really* good reason.

Stateless Address Autoconfiguration
-----------------------------------

Stateless Address Autoconfiguration works by discovering neighbors and routers and picking an address automatically based on the prefix of the network and a few other things such as the interface's MAC address (there are privacy extensions to avoid this).  This means that a DHCPv6 server isn't strictly required for automatic IP address configuration.  Router advertisements are necessary for getting the default gateway and DNS information.  I'll explain how to set all of this up in a bit.

If auto configuration doesn't suit your needs, DHCPv6 is available for more advanced setups.  You should probably have a good reason for needing a DHCPv6 server (like handing out prefix delegations and pretending to be an ISP).

Prefix Delegations
------------------

With the significant increase in address space there is no need to use NAT as was previously the case with IPv4, especially for home users.  To do this, ISPs need to hand out a subnet prefix to each of their clients so their clients can then split up the prefix and create their own subnets for their internal networks.  Oh yeah, and handle all the routing table management that comes with it.

Do request a prefix, it's merely an option your DHCPv6 client passes to your ISP's DHCPv6 servers.  If the ISP's DHCPv6 server is configured correctly, then you will get a prefix.  The recommended prefix size is /48 (That's huge, 2^80 addresses!!). Unfortunately, most consumer ISPs don't do that.  In my case, Comcast hands out a /60 prefix which is good enough for me and will let me create 16 ( 2^4 ) /64 subnets, currently I use one for WLAN and one for LAN.  Details on the setup later.

Network Address Translation (NAT)
---------------------------------

There is no NAT as there was with IPv4.  The address your computer uses inside your network is the same any other host on the Internet can use.  This of course has security implications because most people have been using NAT as a sorry excuse for a proper "firewall".  The solution for this is to setup a firewall with stateful filtering at the IPv6 gateway to prevent poorly internal machines from getting attacked.

As a side-effect, port forwarding is no longer necessary to bypass NAT.

The Internet is becoming a better place without NAT and port forwarding.

My Network
==========

Before I get started with how to setup your network, it's important to understand how my network works.  My router and firewall machine runs Linux and is attached to three networks:

1. The Internet on eth0
2. LAN on br0
3. WLAN on wlan0

Request An IPv6 Address
=======================

Change a few things so that IPv6 works by modifying sysctl options, I use ufw's <code>/etc/ufw/sysctl.conf</code>, add the following:

	net/ipv6/conf/all/forwarding=1
	net/ipv6/conf/eth0/accept_ra=2

and reload the firewall and verify the settings took effect:

	sudo ufw reload
	sysctl net.ipv6.conf.all.forwarding
	sysctl net.ipv6.conf.eth0.accept_ra

To get an IPv6 address you'll need an DHCPv6 client.  I use WIDE-DHCPv6-Client (20080615-11.1), install it on Ubuntu with:

    sudo apt-get install wide-dhcpv6-client

We'll need to configure it, so edit <code>/etc/wide-dhcp6c.conf</code>, mine is as follows:

	interface eth0 {
		send ia-na 1;
		send ia-pd 1;
		send rapid-commit;
		request domain-name-servers;
		request domain-name;

		script "/etc/wide-dhcpv6/dhcp6c-script";
	};

	id-assoc pd 1 {
		prefix ::/60 infinity;

		prefix-interface br0 {
			sla-len 4;
			sla-id 0;
			ifid 10;
		};

		prefix-interface wlan0 {
			sla-len 4;
			sla-id 1;
			ifid 10;
		};
	};

	id-assoc na 1 {
	};

Let's go over what this means.  The "interface eth0" section tells the client to send the request out eth0 to my ISP (Comcast).  This is the interface plugged in to my cable modem and is on a cable network that's "IPv6 ready".  The remaining options request a non-temporary address (ia-na) and a prefix delegation (ia-pd) and the rapid-commit is just to speed things up.  Additionally, we care about getting the DNS servers at the same time.

The "id-assoc pd 1" section describes what to do with my prefix delegation after the ISP assigns one to my machine.  This section isn't critical for using IPv6 from the gateway, but it is critical to assigning global IPv6 addresses to my internal networks.  The "prefix ::/60" line means that I assume I'm getting a /60 prefix.  The "prefix-interface" section break-up the /60 subnet in to /64 subnets ad given by "sla-len 4" since 60 + 4 = 64.  The "sla-id 0" is the first subnet of my /64 prefix and "sla-id 1" is the second /64 subnet.  Since I have a total of 4 bits for sla-id's (/64 - /60 = 4), I have 14 unused /64 subnets for future use.  Finally the "ifid 10" (note this value is in **decimal**, the IPv6 address will likely be represented in hex, 10 = 0xa) field tells the dhcp6c client to assign that as the host component of my IPv6 address to the interface.  This means that an IPv6 address for each interface on my internal networks are in the form:

    +---------------------------+--------------+--------------------+ 
    |0   (prefix from pd)     59|60 (sla-id) 63|64     (ifid)    127|
    +---------------------------+--------------+--------------------+ 

If all went well with dhcp6c.conf configuration file and the ip6tables firewall isn't restrictive try the following commands to request an IP and view the results:

    sudo service wide-dhcpv6-client restart
	ip -6 addr ls
	ip -6 route ls

For each interface there should be an IP address with "scope local" and "scope global".  The local addresses are special and only used for communication to and from other devices on the same broadcast network.  These addresses aren't routable across the Internet, the scope addresses can be used for communications, but the interface to which you're referring must always be specified when using a link local address.  The global address are the global IPv6 addresses and function as you'd expect.

If the DHCPv6 client fails, then check the logs (<code>/var/log/syslog</code>), the configuration files, firewall and get tcpdump running to help you figure out what went wrong.  If all the configuration files check out, perhaps your ISP isn't ready for you yet.  Sorry.

If you're on Comcast, you can checkout the status of your cable network @ [http://test-ipv6.comcast.net/](http://test-ipv6.comcast.net/).

At this point you should be able to ping Google's IPv6 page from the gateway:

    ping6 ipv6.google.com

If the gateway is running a javascript enabled browser then, checkout [test-ipv6](http://test-ipv6.com/), if not, curl or wget [ipv6.google.com](http://ipv6.google.com).  Congratulations, things are working.

Setup the Internal Networks on the IPv6
=======================================

There are two steps to getting your internal networks online:

1. Setup dnsmasq (or radvd) to advertise the subnet, gateway, and DNS servers.
2. Configure ip6tables to play along.

Configure dnsmasq
-----------------

I already use dnsmasq for my existing IPv4 networks as it's simple and lightweight as DHCP, DNS, and TFTP server.  The latest version (I'm using 2.65-1ubuntu1) adds support for handing prefix delegations elegantly with the IPv6 "constructor" option.  Many other tutorials on the Internet are using radvd, but I prefer dnsmasq as I can kill 3 birds (IPv4/IPv6 DNS, DHCPv4, DHCPv6) with one stone.

If you're not running Ubuntu 13.10, you'll need to [hunt down v2.65](https://launchpad.net/ubuntu/raring/amd64/dnsmasq-base/2.65-1ubuntu1) or later and install it:

    wget http://launchpadlibrarian.net/131350318/dnsmasq-base_2.65-1ubuntu1_amd64.deb
    sudo dpkg -i dnsmasq-base_2.65-1ubuntu1_amd64.deb

Create a file under /etc/dnsmasq.d/ipv6:

	dhcp-range=::a,constructor:br0,ra-names,1d
	dhcp-range=::a,constructor:wlan0,ra-names,1d
	enable-ra

Restart dnsmasq so the changes take affect:

	sudo service dnsmasq restart

One *very* important yet very subtle thing I'd like to point out is the "::a" value in the dhcp-range.  Dnsmasq will use the constructor magic to look at the specified interface and it expects the start of the range to be equal to the address assigned to the interface.  The "a" in the host component of the IPv6 address is from the "ifid 10" specified above.  If you get this wrong, dnsmasq won't work right and you'll be baffled.  Ask me how I know.

When configured this way, it's worth noting that the prefix is not hardcoded in any files, and should your ISP change the PD on you, everything should propagate out.  Also note that dnsmasq is not actually acting as DHCPv6 server in this setup, it's just sending router advertisements (RA) for hosts to do SLAAC.  If it was, or if you intended for it to be, dnsmasq would be listening on port udp/547.  If you want to do this, make sure that you open the firewall to allow this.

If this didn't work, check out <code>/var/log/syslog</code> for entries from dnsmasq about what's wrong.

Attempt to Configure Iptables
-----------------------------

Iptables must allow traffic to be forwarded for IPv6 to work.  By default Ubuntu (and ufw) don't allow this.

Add the following to /etc/ufw/before6.rules:

	# allow traffic to be forwarded
	-A ufw6-before-forward -i wlan0 -j ACCEPT
	-A ufw6-before-forward -i br0 -j ACCEPT
	-A ufw6-before-forward -m state --state RELATED,ESTABLISHED -j ACCEPT

And restart the firewall:

	sudo ufw reload

These rules will allow all traffic outgoing traffic originating from from my WLAN or LAN to pass freely, and the last rules allows the responses to pass as well.  All other traffic is blocked, including pings from the outside world.  Tweak this to your heart's content.

It's assumed that default forward policy is to DROP.  If this isn't the case, then your IPv6 subnets maybe be unprotected.

Test It Out
-----------

Plug in a client that supports IPv6.  It should get an IPv6 address or two and IPv6 DNS server.  On my Macbook Pro this just worked -- much to my amazement.

If everything went really well then the host should be able to load [http://test-ipv6.com](http://test-ipv6.com) and <code>ping6 google.com</code>.

Next Steps
==========

* Test your IPv6 firewall: [http://ipv6.chappell-family.com/ipv6tcptest/](http://ipv6.chappell-family.com/ipv6tcptest/)
* Run an IPv6 speedtest: [http://ipv6.speedtest.comcast.net/](http://ipv6.speedtest.comcast.net/)
* Maybe a follow-up post about the IPv6 Privacy Extensions?
* Comments?
