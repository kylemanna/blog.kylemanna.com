---
title: "Intermittent IPv6 Issues on Digital Ocean"
excerpt: "How to fix sporadic IPv6 connection issues due to ip6tables misconfiguration."
category: linux
tags: [linux, digital ocean, ipv6]
header:
  image: http://i.imgur.com/IJ91A3p.png
  overlay_color: "#000"
  overlay_filter: "0.7"
  overlay_image: http://i.imgur.com/IJ91A3p.png
---

## Locked Down and Out with IPv6

The other day I was setting up a [Digital Ocean Droplet](https://m.do.co/c/d19f7fe88c94) for a project with IPv6 and CloudFlare. After getting all the initial services setup, I decided to lock it down with `ip6tables`.  I setup some rules like I had on other machines to let obvious things through, tested it and moved on.

However, my ssh connection were very flaky and would have periodic lag followed by smoother operation.  The webserver *seemed* fine because CloudFlare was helping to mask my IPv6 problem I had inadvertently buried in my configuration.

I began to troubleshoot and realized IPv4 was operating flawlessly and IPv6 only acted up when I turn on basic IPv6 rules.  Further investigation showed that http was just as sporadic as ssh when I removed CloudFlare from the picture.

I had reduced my `ip6tables` rules to a very simple subset:

    ip6tables -A INPUT -p tcp --dport 22 -j ACCEPT
    ip6tables -P INPUT DROP

Which didn't help.  What was going wrong?  Why did it sometimes work and then not other times, and then magically recover?

I went to Google trying to figure out why `ip6tables` would cause intermittent connections, but couldn't find any direct results.

Finally, I dug deep enough to learn that I screwed up and needed a few more rules to just exist on the IPv6 network.

## Enter ICMPv6 Neighbor Discovery Protocol

That simple `ip6tables` firewall had blocked all the network discovery packets (kind of like IPv6 version of IPv4 ARP).  This effectively blocked all router and neighbor advertisement packets from the [Digital Ocean](https://m.do.co/c/d19f7fe88c94) router using the [IPv6 Neighbor Discovery Protocol](https://en.wikipedia.org/wiki/Neighbor_Discovery_Protocol).  Oops.  Quick fix:

    ip6tables -A INPUT -p icmpv6 --icmpv6-type router-advertisement -m hl --hl-eq 255 -j ACCEPT
    ip6tables -A INPUT -p icmpv6 --icmpv6-type neighbor-solicitation -m hl --hl-eq 255 -j ACCEPT
    ip6tables -A INPUT -p icmpv6 --icmpv6-type neighbor-advertisement -m hl --hl-eq 255 -j ACCEPT
    ip6tables -A INPUT -p icmpv6 --icmpv6-type redirect -m hl --hl-eq 255 -j ACCEPT

And everything worked perfect.  I updated my firewall rules and life was good.

Hopefully those running into similar problems will find this post and save an hour or two of screwing trying to fix their machines.
