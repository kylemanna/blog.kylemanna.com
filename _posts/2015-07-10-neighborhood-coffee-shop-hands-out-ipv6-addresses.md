---
layout: post
title: "Neighborhood Coffee Shop Hands Out IPv6 Addresses"
description: ""
category: ipv6
tags: [ipv6, san francisco, comcast]
---
{% include JB/setup %}

## Another IPv6 Spotting

I frequent my neighborhood coffee shop in SF called The Brew.  Just today I noticed that their ATT WiFi now hands out a 2602:302::/64 IPv6 address.  Cool.

Running [test-ipv6.com](http://test-ipv6.com/) shows that it's using a 6RD tunneling mechanism to accomplish this over IPv4.  Almost as good as native and I'll take it.

## Surprise for VPN peoples

A number of my friends run VPNs and assume they are 'safe' at coffee shops. That is to say safe from sniffing of non TLS traffic and consider NAT as a *firewall*. If they get an IPv6 address that's [potentially not true](https://torrentfreak.com/vpn-providers-respond-to-allegations-of-data-leakage-150701/) and their IPv6 services may be public to the entire Internet by accident.

## Onward

We're one step closer to the death of NAT, and I can't wait.  I've been trying to find time to add IPv6 support to my [Docker OpenVPN image](http://bit.ly/1Cv7FN2) despite Digital Ocean's best efforts to make this difficult by not allocating a proper prefix.  As for actually wrangling iptables firewall rules, [FirewallD](http://fedorahosted.org/firewalld) seems to be the most compelling solution I've ever seen.
