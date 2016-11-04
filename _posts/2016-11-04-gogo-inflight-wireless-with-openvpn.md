---
title: "Gogo Inflight Internet Access with OpenVPN"
excerpt: "With a little bit of magic, Docker and one open port you can use Gogo Inflight Internet."
category: sharing
tags: [security, cloud, sharing, networking, digital ocean]
header:
  image: https://i.imgur.com/KyWlOdW.jpg
  overlay_color: "#000"
  overlay_filter: "0.5"
  overlay_image: https://i.imgur.com/KyWlOdW.jpg
---

tl;dr [I'm Too Lazy to Read, give me the one liner](#im-too-lazy-to-read) at the end.

## Gogo Inflight Internet Show Me How You Work

On a recent flight I was intrigued at how Gogo Inflight WiFi did access control.  At initial glance it appears that everything is firewalled except a few ports.  I determined this by connecting to their WiFi access point on a flight and port scanning a server I had setup.  All ports except `80/tcp` and `3128/tcp` appear blocked.

## Initial Investigation

First lets port forward port `3128/tcp` to `22/tcp` on my server and see if I can connected.  Worked.

Next step, fire up a [kylemanna/openvpn](https://github.com/kylemanna/docker-openvpn) server to proxy my data on port `3128/tcp` too.  That works.  Ok, but everyone knows that [tcp in tcp tunnels are bad](http://sites.inka.de/bigred/devel/tcp-tcp.html), and by observing ping times on my flight blow up after a single lost packet, it behaves as expected.  No fun, no good.

## Check If the Firewall Relays UDP Traffic

Next step was to setup a better performing solution using TCP in UDP tunneling as tunnels are supposed to work.  To do that I fired up the same [kylemanna/openvpn](https://github.com/kylemanna/docker-openvpn) image on my server with a slightly different config and boom.  Everything worked. My laptop, my cell phone.  The Internet at your fingertips through an apparent firewall hole.

But how would others do this?  Read on my friend.

## How to Setup OpenVPN on Port 3128/UDP

Before you get on a flight, setup a remote server like a [$5/mo Digital Ocean droplet](http://do.co/2fDHYVv) (Use my [promo code](http://do.co/2fDHYVv) to get a $10 credit!) in a region where you'll be traveling for best performance (i.e. San Francisco vs New York City). 

Step 1 – Start A Server With Docker

I recommend selecting the Docker One-Click App from [Digital Ocean](http://do.co/2fDHYVv).

![Docker One-Click App on Digital Ocean](http://i.imgur.com/A7tiqCg.png)

Step 2 – Setup the OpenVPN Server Using Docker

Change `SERVER_IP` variable to match your server's public IP address.

    OVPN_DATA="ovpn-data"
    SERVER_IP="127.0.0.1"
    docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u udp://$SERVER_IP:3128
    docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki
    docker run -v $OVPN_DATA:/etc/openvpn -d -p 1194:3128/udp --cap-add=NET_ADMIN kylemanna/openvpn

Note, using the IP address is important in the likely event that DNS is broken until you connect to the VPN.

At this point, you should have a server running in the cloud.

Step 2 – Generate a Client Certificate

Change `CLIENT` variable if you want more then one client as clients aren't allowed simultaneous connections.

    CLIENT=client1
    docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full $CLIENT nopass
    docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient $CLIENT | tee $CLIENT.ovpn

Step 3 – Copy the Client Certificate

This is up to you. I'd recommend `scp` to copy the `.ovpn` file to your laptop.  You could also try to `cat $CLIENT.ovpn` and copy-paste the certificate, but don't screw it up.

Step 4 – Setup OpenVPN on Your Client

This is up to you, but I'll give you a hint at what I've tried:

* Linux: Simple as `sudo openvpn --config $CLIENT.ovpn` after installing the `openvpn` package.
* macOS: [Tunnelblick Project](https://tunnelblick.net/) and import the `$CLIENT.ovpn` package.
* Windows: Try the [installer from the OpenVPN project](https://openvpn.net/index.php/open-source/downloads.html) which needs to run `openvpn` as administrator.  I don't use Windows enough to figure out how to make this less painful, but it definitely works.
* Android: Check out [OpenVPN Connect App](https://play.google.com/store/apps/details?id=net.openvpn.openvpn) after copying it to your device using MTP file transfer.
* iOS: Check out [OpenVPN Connect App](https://itunes.apple.com/us/app/openvpn-connect/id590379981?mt=8).  I have not tested this, let me know if it works.

Step 5 – Place an Inflight Phone Call

Well, maybe.  You could do a VOIP phone call or a video chat, but please don't.  Your neighbors will hate you, for good reason.  Surf the web and try to get to [inbox zero](http://lmgtfy.com/?q=inbox+zero).

## I'm Too Lazy to Read

Well, I have a treat for you. A magic script that you can run as root (trust me! ha) and it'll generate one certificate for you on your disposable [$5/mo Digital Ocean droplet](http://do.co/2fDHYVv) that you can destroy at the end of your flight.

Quick and easy via a little [Github Gist](https://gist.github.com/3adcd465e709b8ff3300202f12fdfff1):

    curl -L https://gist.githubusercontent.com/kylemanna/3adcd465e709b8ff3300202f12fdfff1/raw/gogo-firewall-bypass.sh | sudo bash

Approximate expected output:

	root@docker-512mb-sfo1-01:~# curl -L https://gist.githubusercontent.com/kylemanna/3adcd465e709b8ff3300202f12fdfff1/raw/gogo-firewall-bypass.sh
	| sudo bash
	  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
									 Dload  Upload   Total   Spent    Left  Speed
	100  1376  100  1376    0     0   3831      0 --:--:-- --:--:-- --:--:--  3843
	[*] Generating server config for 504.731.333.274
	Processing Route Config: '192.168.254.0/24'
	Processing PUSH Config: 'block-outside-dns'
	Processing PUSH Config: 'dhcp-option DNS 8.8.8.8'
	Processing PUSH Config: 'dhcp-option DNS 8.8.4.4'
	Successfully generated config
	Cleaning up before Exit ...
	[+] Generated server config for 504.731.333.274
	[*] Initialzing PKI (insecurely) for the truely lazy
	Generating a 2048 bit RSA private key
	.............................................+++
	..............................................................+++
	writing new private key to '/etc/openvpn/pki/private/ca.key.XXXXpEDboo'
	-----
	Generating DH parameters, 2048 bit long safe prime, generator 2
	This is going to take a long time
	............+.+..........+..................................................................................................................................................................................................+......................................................................................................................................................................+.................................................................................................................................+.......................................................+......................................................................................................+..........+...................................+..............................+...............................................+.....................................+.....................................................................................................................................................................+..........+......................................................................................................+.............................................................................................................................................................................................................................+......................................................................................................++*++*
	Generating a 2048 bit RSA private key
	..............+++
	......................................................................................+++
	writing new private key to '/etc/openvpn/pki/private/504.731.333.274.key.XXXXPgCELB'
	-----
	Using configuration from /usr/share/easy-rsa/openssl-1.0.cnf
	Check that the request matches the signature
	Signature ok
	The Subject's Distinguished Name is as follows
	commonName            :ASN.1 12:'504.731.333.274'
	Certificate is to be certified until Nov  2 22:50:17 2026 GMT (3650 days)

	Write out database with 1 new entries
	Data Base Updated
	[+] Initialized PKI magic
	[*] OpenVPN server starting up
	081347c0bb9fdd1b9c3c3536fc2eb519a2796fdc6d2f642db1380c81964aef36
	[+] OpenVPN server up and running
	[*] Generating client certificate for client1
	Generating a 2048 bit RSA private key
	............................................+++
	..................................................+++
	writing new private key to '/etc/openvpn/pki/private/client1.key.XXXXadBaIc'
	-----
	Using configuration from /usr/share/easy-rsa/openssl-1.0.cnf
	Check that the request matches the signature
	Signature ok
	The Subject's Distinguished Name is as follows
	commonName            :ASN.1 12:'client1'
	Certificate is to be certified until Nov  2 22:50:20 2026 GMT (3650 days)

	Write out database with 1 new entries
	Data Base Updated
	[*] Client certificate ready at client1.ovpn
	 _______________________________________
	< Server up and running, happy surfing  >
	 ---------------------------------------
			\   ^__^
			 \  (oo)\_______
				(__)\       )\/
					||----w |
					||     ||
	[?] Copy client1.ovpn to your client
	[x] Exiting
	root@docker-512mb-sfo1-01:~# ls -l client1.ovpn
	-rw-r--r-- 1 root root 4869 Nov  4 22:50 client1.ovpn

Have Fun.
