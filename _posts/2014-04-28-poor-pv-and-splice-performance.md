---
layout: post
title: "Poor pv and splice() Performance"
tagline: "slow"
category: linux
tags: [linux, pv, kernel, splice, pipeline, pipes]
---
{% include JB/setup %}

While messing around with a number of larger tar archives this past weekend, I noticed that they were obnoxiously slow when piped through pv.  Typically I use [pv](http://www.ivarch.com/programs/pv.shtml) for large operations that can be pipelined so that I can observe progress (or sometimes lack thereof).

# Overview

For those not familiar, pv provides insight in to the progress of operations, for instance compressing a tar archive:

	pv -CcN src linux-3.15-rc3.tar | lrzip -q | pv -CcN out > linux-3.15-rc3.tar.lrz
	src:  544MiB 0:00:00 [1.07GiB/s] [============================>] 100%
	out: 79.9MiB 0:01:18 [1.02MiB/s] [ <=>                                          ]

Usually I run it with no arguments as the default is pretty good and have used it for years.

# Problem

The simplest way to demonstrate the problem is to read data through two pipes and throw it away.  The splice() functionality appears to cause a significant performance hit on my Arch Linux workstation.

### Test Single Pipe

Legacy read()/write() that pv did prior to version 1.3.0 (5 June 2012):

	dd if=/dev/zero bs=64k count=256k 2>/dev/null | pv -abt -C > /dev/null
	16GiB 0:00:03 [ 4.3GiB/s]

This is the baseline performance for reading 16GB, passing it through a single pipe and throwing it away.

Test with splice() enable, which is the default:

	dd if=/dev/zero bs=64k count=256k 2>/dev/null | pv -abt > /dev/null
	16GiB 0:00:02 [6.21GiB/s]

As expected, splice() improves throughput, in this case almost 50% thanks to improved efficiency.

### Test Multiple Pipes

	dd if=/dev/zero bs=64k count=256k 2>/dev/null | pv -abt -cN one | pv -abt -cN two > /dev/null
	one:   16GiB 0:00:48 [ 338MiB/s]
	two:   16GiB 0:00:48 [ 338MiB/s]

For some reason, performance went from 6 GB/s to 338 MB/s.  Why?  That's odd, I'm sure context switching between processes hurt, but not that much!

Try this again without splice():

	dd if=/dev/zero bs=64k count=256k 2>/dev/null | pv -abt -cN one -C | pv -abt -cN two -C > /dev/null
	one:   16GiB 0:00:16 [1007MiB/s]
	two:   16GiB 0:00:16 [1007MiB/s]

Now performance is better, but this seems odd?  The splice() option should improve performance, how come disabling it improved performance?

# Real-World

My observation occurred with manipulating tar archives and compressing them.  Here's an example working with a recent kernel archive:

	pv -abt -cN src linux-3.15-rc3.tar | pbzip2 | pv -abt -cN out > linux-3.15-rc3.tar.bzip2
	src:  544MiB 0:01:26 [6.27MiB/s]
	out:   91MiB 0:01:26 [1.05MiB/s]

Without splice():

	pv -abt -cN src -C linux-3.15-rc3.tar | pbzip2 | pv -abt -cN out -C > linux-3.15-rc3.tar.bzip2
	src:  544MiB 0:00:14 [38.7MiB/s]
	out:   91MiB 0:00:14 [6.39MiB/s]


Ouch, a 600% performance hit.  It's also worth noting that pbzip2 didn't even consume an entire core with splice() enabled, clearly performance is being left on the table due to some bug.

This is running on an Intel i5-2500K and Arch Linux with kernel 3.14.1-1 and pv 1.5.2-1.
