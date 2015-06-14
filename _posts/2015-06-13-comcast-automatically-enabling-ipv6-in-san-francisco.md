---
layout: post
title: "Comcast Automatically Enabling IPv6 in San Francisco"
description: ""
category: ipv6
tags: [ipv6, san francisco, comcast]
---
{% include JB/setup %}

## Wait What?

Today I was playing around with my laptop at a friend's house in San Francisco.  While converting form netctl to NetworkManager on Arch Linux I noticed in the logs that I had received IPv6 addresses for DNS servers and was getting IPv6 router solicitations.  Oh strange, some how my laptop is confused with my home network where I explicitly setup native IPv6 after Comcast enabled it.  Wait, what -- this doesn't make sense.

## It Happened Automatically

Reality was that Comcast seems to have updated their provided gateways (or routers) to just work with IPv6.  Nice.  I took a peek at my friend's Windows 8 laptop and noticed via her Gmail acccount activity (which has had native IPv6 for a while) had been transparently working for at least today with no effort.

## What's Next?

Nice.  With Comcast rolling out IPv6 to make regions it's only going to push other providers to (maybe) catch-up and enable IPv6 on their networks.  Google has an [IPv6 statistics page](https://www.google.com/intl/en/ipv6/statistics.html) and it's approaching 7% as a result of things like this.  I think this is a good thing.

## The Bad

Where this will surely go wrong is where IPv6 starts working automatically but the infrastructure isn't built to work with it.  Companies that haven't prioritized IPv6 surely haven't tested it and in many cases their devs haven't thought about it.  The result will be strange issues where some online services (imagine Netflix for example) only support IPv4, but one day their third party CDN turns on IPv6 (i.e. Cloudflare) and now something doesn't quite work (i.e. a naive authentication example that assumes the same IP on the website and via some content delivery service) and support requests build-up.

How will the company handle this issue?  The first line of defense will be the support techs that may not even know IPv6 so they send consumers down the path to troubleshoot the wrong things (not their fault).  Eventually some requests will get escalated to program managers or developers and they'll most likely miss the IPv6 hint at first because their company hasn't prioritized IPv6. After some time IPv6 will be discovered and *blamed* for the issues. In the case of a lesser program manager, IPv6 will be disabled because it causes "problems".  Unfortunately this is my experience at BigCo Inc.  The better program managers will disable IPv6 and prioritize an engineering plan to properly support it should a longer term solution be necessary.

We've seen it before:  Look at how long it has taken to make HTTPS + TLS ubiquitous which is arguable more beneficial immediately.

Meanwhile, the tech leaders like Google and FaceBook, for instance, enabled IPv6 a while ago and are on top of their stuff.

## Closing Thoughts

I'm excited to see IPv6 come to fruition!  I'm excited to see NAT die, which at best is a hacky workaround.  I hope that the stumbling blocks don't scar IPv6 as big roll outs happen but anticipate sensational journalist playing the stumbling blocks for all they're worth.
