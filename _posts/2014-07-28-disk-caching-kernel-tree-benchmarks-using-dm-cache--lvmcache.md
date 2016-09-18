---
title: "Quick Benchmarks of dm-cache / lvmcache"
tagline: "caches ftw"
category: linux
tags: [dm-cache, linux, cache, ssd, dmsetup, device-mapper, performance, server, disk, lvmcache, lvm]
---

## Quick Benchmarks

I'm going to run some quick and dirty benchmarks showing the efficacy of dm-cache, this time setup using `lvmcache`.  Often times I will run `git grep` over source files to locate symbols or strings of interest.  On tradional mechanical disks, this operation is slow until Linux caches the filesystem metadata and file data in RAM.  Let's see if this speeds up a real-work use case.

The test setup is as follows: Seagate 4TB HDD (ST4000DM000-1F2168) + Samsung 840 EVO 256 GB SSD + lvmcache + ext4.

The following test shows the freshly added cache getting warmed up after repeated access to the filesystem metadata and later data files of the kernel tree while performing a `git grep`:

    $ while true; do echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null ; time git --no-pager grep -q blah ; sleep 1; done
    git --no-pager grep -q blah  0.95s user 1.77s system 6% cpu 44.203 total
    git --no-pager grep -q blah  0.81s user 1.61s system 7% cpu 30.566 total
    git --no-pager grep -q blah  0.80s user 1.50s system 13% cpu 17.135 total
    git --no-pager grep -q blah  0.80s user 1.50s system 14% cpu 16.356 total
    git --no-pager grep -q blah  0.74s user 1.45s system 49% cpu 4.446 total
    git --no-pager grep -q blah  0.64s user 1.50s system 53% cpu 3.969 total
    git --no-pager grep -q blah  0.67s user 1.51s system 56% cpu 3.881 total
    git --no-pager grep -q blah  0.71s user 1.46s system 56% cpu 3.847 total
    git --no-pager grep -q blah  0.76s user 1.39s system 54% cpu 3.934 total
    git --no-pager grep -q blah  0.70s user 1.48s system 56% cpu 3.889 total
    git --no-pager grep -q blah  0.63s user 1.53s system 57% cpu 3.794 total
    git --no-pager grep -q blah  0.67s user 1.47s system 55% cpu 3.883 total

For reference, the same kernel on the SSD itself (was on a btrfs partition though):

    $ while true; do echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null ; time git --no-pager grep -q blah ; sleep 1; done
    git --no-pager grep -q blah  0.66s user 1.33s system 69% cpu 2.881 total
    git --no-pager grep -q blah  0.59s user 1.39s system 69% cpu 2.828 total
    git --no-pager grep -q blah  0.68s user 1.29s system 68% cpu 2.871 total
    git --no-pager grep -q blah  0.63s user 1.34s system 69% cpu 2.847 total
    git --no-pager grep -q blah  0.66s user 1.32s system 69% cpu 2.848 total
    git --no-pager grep -q blah  0.73s user 1.24s system 69% cpu 2.833 total

What can we learn from this?  The old spinner will take ~44 seconds to grep the kernel tree with no kernel file system caching.  The new SSD will take about ~2.8 seconds.  The SSD is about 15x faster, nobody is surprised by this.

What is interesting is that after ~6 accesses, the cache is warmed and the `git grep` operation settles down at 3.8 seconds to do the same operation.  That's 11.5x faster then the standalone harddrive and ~25% slower then the completely native SSD operation.

## What About the Kernel's Filesystem Caching?

Naturally, system RAM is absurdly fast.  Re-run the same test, but don't drop the filesystem caches:

    $ while true; do time git --no-pager grep -q blah ; sleep 1; done
    git --no-pager grep -q blah  0.61s user 0.31s system 266% cpu 0.345 total
    git --no-pager grep -q blah  0.60s user 0.23s system 258% cpu 0.322 total
    git --no-pager grep -q blah  0.65s user 0.23s system 257% cpu 0.343 total
    git --no-pager grep -q blah  0.58s user 0.24s system 255% cpu 0.320 total

Now the operation completes in 330 ms.  More RAM the better for work flows like thise.

## Conclusion

Dedicating 100 GB or so from a high speed SSD to automatically cache the slower mechanical harddrives yields a significant speed-up (10x+) and would be crazy to not exploit.  After the SSD serves the files, letting the Linux filesystem cache serve them will offer another order of magnitude of speed-up.

Caches FTW.
