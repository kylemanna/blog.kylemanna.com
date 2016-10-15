---
title: "Retiring My Old Colocated Server"
excerpt: "Personal server colocation is largely becoming a thing of the past"
category: hardware
tags: [linux, server, cloud, colocation, colostore, waveform]
header:
  image: https://i.imgur.com/AlIOpeV.jpg
  overlay_color: "#000"
  overlay_filter: "0.5"
  overlay_image: https://i.imgur.com/AlIOpeV.jpg
---

## Passing of an Era

The time has come to save a few bucks on something I don't use anymore -- my colocated web/mail/dns server. In November of 2005 I put together the parts to a modest Pentium 4 webserver with a long time friend. We took it to a colocation place in Troy, MI called waveform.net that offered space for a Tower Server, 100Mb/s Internet connection and 1TB/mo of transfer.... for $50. Ridiculous deal.

We did that, ran fine for years (actually the server never had any problems short of the BIOS on the ASUS motherboard was uber slow booting some timers). Hosted tons of crap and experiments on there. One day it dropped offline, called and called and called the host. Never an answer, no email, no phone call back. So, I decided to drive there and pick itup and move it to [Colostore](https://colostore.com) which was 4 hours closer to home for the same services + KVM on request. Excellent decision and I've enjoyed Colostore for 2 years now. However, the server no longer does much for me and it's time to move on.

If anyone is looking for a solid reliable colocation company for their personal server, I recommend Colostore. They have raised their prices since I started, but still worth it. The building isn't quite what you'd expect a "datacenter" to look like, but it got the job done for me and did it better then the guys before them.

I always figured I'd move to a small $20/mo virtual private server running on XEN virtualization technology. However, I always felt restricted by available diskspace and memory. Then the other day I saw a deal on slickdeals.net for [DreamHost](http://bit.ly/2djbFVo). Came out to something liek $66/2 years of webhosting with "unlimited" diskspace, transfer, domains and mail accounts with ssh access. Cool, I can move all my domains and be happy, main priority was email and that the server has SMTP + TLS/SSL and IMAP over SSL. They do.

Researched the name and you get bad stuff here and there, but otherwise gather that they are a huge company and fairly well known, so with that comes bad press. The price combined with the recommendation from LifeHacker a few weeks ago and I was sold. For $60+ for 2 years, if I don't like them then I move in 2 months and call it a savings over the colocation deal I'm leaving.

Here I am, with a [DreamHost](http://bit.ly/2djbFVo) account and so far so good in my opinion. I've moved half a dozen sites and still have 2 more to go. Most notably I've moved a 50GB subversion repository for a student organization I was a part of when I was in school... all without a hitch. Their server ( yangon.dreamhost.com ) that hosts my site has a very low load averages and transferring the files form the ColoStore in Indiana to [DreamHost](http://bit.ly/2djbFVo) in California all zipped along over rsync+ssh at 9MB/s +. Pretty solid if you ask me. I'll post some specs about the server later. I figure in a few months we will see how much they actually oversell their servers.

![Intel Pentium 4 630 CPU](http://i.imgur.com/XS2D1tS.jpg "Intel Pentium 4 630 CPU")
