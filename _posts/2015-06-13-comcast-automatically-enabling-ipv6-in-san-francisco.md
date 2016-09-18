---
title: "Comcast Automatically Enabling IPv6 in San Francisco"
description: ""
category: ipv6
tags: [ipv6, san francisco, comcast]
---

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

## Update 2015.06.14

Alot of people are saying this isn't new and that IPv6 has been around for a while.  Yes, I have been using IPv6 at home after explicitly setting it up for almost 2 years.  What is noteworthy is that Comcast managed routers are now pushing it out automatically to residences that I know did not have it one month ago.

As further indication of changes within Comcast's network, they broke the /60 IPv6 prefix delegation that has been working for almost 2 years for me just a few days ago.  From my router logs ([full gist](https://gist.github.com/1cec3537f61aefd1d6bc)):

    Jun 12 18:24:16 core.hq dhcp6c[1354]: get_ia: update an IA: PD-1
    Jun 12 18:24:16 core.hq dhcp6c[1354]: update_prefix: update a prefix 2601:9:4f00:xxx0::/60 pltime=0, vltime=0
    Jun 12 18:24:16 core.hq dhcp6c[1354]: remove_siteprefix: remove a site prefix 2601:9:4f00:xxx0::/60
    Jun 12 18:24:16 core.hq dhcp6c[1354]: ifaddrconf: remove an address 2601:9:4f00:xxx0::1/64 on lan0
    Jun 12 18:24:16 core.hq dhcp6c[1354]: ifaddrconf: remove an address 2601:9:4f00:xxx1::1/64 on wifi0
    Jun 12 18:24:16 core.hq dhcp6c[1354]: update_prefix: create a prefix 2601:646:200:xxxx::/64 pltime=345600, vltime=345600

Something definitely changed.  And it's [affecting others as well](http://bit.ly/1Qxmy7Y).  A few steps forward, one step back.  I assume the Comcast network engineers will have this fixed shortly.
