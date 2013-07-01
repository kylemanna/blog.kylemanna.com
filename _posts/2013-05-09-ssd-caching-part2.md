---
layout: post
title: "Linux SSD caching part 2"
tagline: "faster is better"
category: linux
tags: [cache, linux, core, performance, disk, server, ssd, dm-cache]
---
{% include JB/setup %}

Musings with dm-cache
---------------------

I've been playing around with dm-cache recently on my machine with Ubuntu 13.04 + a custom 3.9 kernel.  I setup 90GB SSD cache using my OCZ Agility 2 with an old btrfs volume on a logical volume on top of SW RAID0 array (I know... I'm compounding seek latencies).  Fun things we can do with device mapper these days.  I was pleasantly surprised to see that I didn't have to re-create my original file system, the cache was added, and then I mounted the cache device instead and that was it. Simple.

To remove the cache, there is apparently a cleaner policy that will force all the dirty blocks out of the cache and to the underlying disk so you can remove or reconfigure the cache.  I haven't tested this yet.

So far it seems that dm-cache is quite conservative in its caching policy by design and offloads sequential reads to the underlying spindle disks.  In my case I have 90GB + of space to buffer that data, I'd prefer it was put it on the SSD which is still faster for sequential writes then my RAID0 and write it back slowly in the background (migration).  I've read on some mailing lists that additional cache policies will become available later after the mq cache policy is considered more stable.

The one thing I've not sure about is if there is an easy way to setup my device-mapper tables every time I boot.  I'm betting I'll have to write a script to re-assemble my cache every time I boot.  That seems clumsy.

Right now I have my Google Chrome config directory (~/.config/google-chrome) and my entire user cache directory (~/.cache) running on the SSD in addition to some kernel and Android builds.  In the event I find a bug, I won't really lose anything.  In the mean time, Chrome seems quite a bit snappier and there is noticeably less audible disk thrashing when surfing.

When I feel more comfortable with it (maybe after v3.10?) I'll move my entire home directory to the cache.

Update with bcache
------------------

Apparently bcache has been merged in v3.10 kernel (via [Phoronix](http://www.phoronix.com/scan.php?page=news_item&px=MTM2ODM)).  After reviewing the kernel documentation, it appears that it is quite a bit more configurable and doesn't use device-mapper.  This means you can't just add the cache to an existing device-mapper device, instead you create a new block device.  I assume this trades the flexibility of adding/removing caches without re-creating file systems with performance.

Time will tell, maybe I'll give it a shot when 3.10 is released. Or maybe I'll stick with dm-cache in favor of simplicity for my generic work load.
