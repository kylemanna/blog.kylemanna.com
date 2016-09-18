---
layout: post
title: "Docker + systemd-network Surprise"
description: ""
category: linux
tags: [arch, systemd, networking, linux]
---
{% include JB/setup %}

## How'd We Get Here?

Started off simple: Migrate my [DigitalOcean](http://bit.ly/1GdeZrN) Ubuntu droplet (RIP upstart disaster) to Arch Linux.  Seemed simple enough after I found the [digitalocean-debian-to-arch](https://github.com/gh2o/digitalocean-debian-to-arch) repository.  The Debian 8.1 to Arch script worked seamless and even setup `systemd-network` for me.  Nice, been looking for an excuse to play with `systemd-network`.

## Turn For the Worst

Except it seems that `systemd-network` doesn't quite play well with docker.  The default eth0 network file setup by the migration script (rightfully) doesn't enable the new `IPForward` or `IPMasquerade` options built in to `systemd-network`.  The result: Docker turns on IP forwarding and masquerade, and `systemd-network` turns them off as Docker containers and associated interfaces are brought up and down.  One minute a container is connected, the next it's not.  This blew my mind for an hour or so until I realized IPv4 forwarding was being mucked with.  Sigh.

What about IPv6?  That's just full broken.  According to [this article](http://www.tldp.org/HOWTO/Linux+IPv6-HOWTO/proc-sys-net-ipv6..html):

    In IPv6 you can't control forwarding per device, forwarding control has to be done using IPv6-netfilter (controlled with ip6tables) rulesets and specify input and output devices (see Firewalling/Netfilter6 for more). This is different to IPv4, where you are able to control forwarding per device (decision is made on interface where packet came in).

Systemd tries to do that instead of modifying `net.ipv6.conf.all.forwarding`.  Lennart Pottering [commented on the systemd-devel mailing list](http://thread.gmane.org/gmane.comp.sysutils.systemd.devel/32654/focus=32707) suggesting it was never tested.

From my [docker-openvpn](http://bit.ly/1Cv7FN2) [container](http://bit.ly/1eQ50mp) development work, I can confirm that changing the `net.ipv6.conf.$IFACE.forwarding` value has no affect.  Least it doesn't break it, but it doesn't enable IPv6 forwarding either.


## The Fix

Add `IPMasquerade=yes` to the eth0.network file.  Thanks to a [recent pull request](https://github.com/gh2o/digitalocean-debian-to-arch/pull/17), this is trivial to add to `/etc/systemd/network/template/dosync-eth0.network.tail`.

Problem solved.  Now if only I could regain the hour or so I wasted learning this.
