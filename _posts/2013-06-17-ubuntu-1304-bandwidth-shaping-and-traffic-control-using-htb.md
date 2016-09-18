---
layout: post
title: "Ubuntu 13.04 Bandwidth Shaping and Traffic Control using HTB"
tagline: "keepin' things fair"
category: linux
tags: [linux, ubuntu, qos]
---
{% include JB/setup %}

Problem
-------

I don't want to allow a client on my network to consume all the available upload network bandwidth when doing something like online backups.  Instead I want to have guarantees that each class of devices can consume a certain <code>rate</code>.  After that certain amount they are welcome to share up to a defined <code>ceiling</code> with the other classes.

Note that traffic shapping can only occur on the host that has control over the transmit queue.  That is to say that my NAT router can only do QoS on outgoing traffic, not incoming traffic.  The key to maintaining a responsive low-latecny connection when uploading large amounts of data is to keep the upload buffer under control with Linux instead of letting the cable modem or upstream router just blindly queue up all the packets.


Solution
--------

I threw together a quick hierarchical token bucket filter (htb or tc-htb for short) to solve this problem.  It works by splitting traffic into 3 classes: my personal workstation that also doubles as the NAT router, Ethernet connected devices, and WiFi connected devices.  Each class is guaranteed some bandwidth as described by the <code>rate</code> parameter and can borrow up to the <code>ceil</code> parameter.  To actually classify the traffic so they fall in the right buckets, I use a simple iptables mangle rule.

There are numerous guides around on the Internet describing how to set these up in a distribution independent way.  I wanted to provide an example for others to correctly set up QoS in Ubuntu 13.04 (and likely old versions without any issues) so that it's automatically configured at start-up.

My cable modem uplink is capped at 10 Mbit/s.  I never want to exceed this rate as then that will move control queue to the cable modem instead of my NAT router.


Implementation
--------------

1. Add the traffic control rules to the <code>/etc/network/interfaces</code> file:

       auto eth0
       iface eth0 inet dhcp
          post-down tc qdisc del dev eth0 root
          post-up tc qdisc replace dev eth0 root handle 1: htb default 10
          post-up tc class replace dev eth0 parent 1:  classid 1:1  htb rate 10mbit
          # My workstation / server
          post-up tc class replace dev eth0 parent 1:1 classid 1:10 htb rate 5mbit ceil 8mbit prio 1
          # LAN NAT routes
          post-up tc class replace dev eth0 parent 1:1 classid 1:20 htb rate 3mbit ceil 8mbit prio 2
          # WLAN NAT routes
          post-up tc class replace dev eth0 parent 1:1 classid 1:30 htb rate 3mbit ceil 8mbit prio 2

2. If using ufw for firewall management, append the following to <code>/etc/ufw/before.rules</code>:

       *mangle
       :POSTROUTING ACCEPT [0:0]
       -A POSTROUTING -s 192.168.10.0/24 -o eth0 -j CLASSIFY --set-class 0001:0020
       -A POSTROUTING -s 192.168.11.0/24 -o eth0 -j CLASSIFY --set-class 0001:0030
       COMMIT

3. Reload the firewall and interface to apply the settings:

       $ sudo ufw reload
       $ sudo ifdown eth0 ; ifup eth0

4. Test it by uploading a huge file to a remote server somewhere while streaming a download somewhere else.
