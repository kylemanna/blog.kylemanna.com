---
layout: post
title: "Samsung 840 EVO SSD + Linux + Firmware Update"
description: ""
category: hardware
tags: [linux, samsung, ssd, firmware, update, error, disk, performance]
---
{% include JB/setup %}
## The Problem

A while back I bought a Samsung 840 EVO as it seemed like the best bang for the buck consumer solid state drive.  It has performed flawlessly for almost 2 years.

There are [stories of people seeing decreasing performance](http://www.anandtech.com/show/8550/samsung-acknowledges-the-ssd-840-evo-read-performance-bug-fix-is-on-the-way) as the NAND cells degrade in this TLC SSD.  There was a [firmware update](http://www.anandtech.com/show/8617/samsung-releases-firmware-update-to-fix-the-ssd-840-evo-read-performance-bug) in October 2014 and then a [another one](http://www.anandtech.com/show/9196/samsung-releases-second-840-evo-fix) in April 2015 attempting to correct the issue.

I haven't noticed any issues, so I didn't rush the update.  Today I took some time and bit the bullet to update it and hedge against disaster.

## The Update

Naturally, the [update is distributed](http://bit.ly/1DLRxRh) primarily for Windows users and I run Linux.  Challenge accepeted.

I grabbed the [EXT0DB6Q 840 EVO firmware update](http://bit.ly/1DLV9mh) for "Windows" users and took a look (`2ad2496632c3eee3fc12b1673a2ee3a9965ae773  Samsung_SSD_840_EVO_EXT0DB6Q.iso`).  Inside the ISO9660 image is an [ISOLINUX](http://www.syslinux.org/wiki/index.php/ISOLINUX) bootloader, [MEMDISK](http://www.syslinux.org/wiki/index.php/MEMDISK) kernel wrapper and a FreeDOS filesystem.

After giving up trying to make the USB stick I flashed the image to boot with my BIOS, I resorted to using GRUB2.  To boot this mess, place the files somewhere accessible (i.e. /boot partition or USB stick) and run the following commands on the GRUB2 command line:

    linux16 (hd6)/isolinux/memdisk
    initrd16 (hd6)/isolinux/btdsk.img

Replace `(hd6)` with the path to your storage device of choice and then boot!

Pretty anticlimactic actually.  No data was lost going from `EXT0AB0Q` to `EXT0DB6Q`.  I had backs-up just in case though, and so should you.

## Testing

I did some quick before and after tests using (GNOME Disks Utility](https://wiki.gnome.org/Design/Apps/Disks).  There was a noticeable performance improvement in consistency of the device, but a slight average throughput decrease.

There is a [mess of images onthe before and after results were quite repeatable with the for people more interested in performance details.  Note the firmware version, partition and sample size in the screenshots.

The most significant improve is visible here.  The first image is before the image update and the second one is after (surprise!).
![Before](http://i.imgur.com/9QiLcyjl.png) ![After](http://i.imgur.com/H9oCZqWl.png)

For this partition, a rarely used 14% full 124GB btrfs partition, the first 20% of the partition had volatile throughput performance.  The before and after results were quite repeatable with and more tests can be found on [Imgur](http://bit.ly/1DLT6yr).  The latency was all over across tests since the disk partially in use by some background tasks in Linux, but largely unchanged by the update.  I speculate that the volatile performance is in the region of the disk where data is actually stored, the numbers seem to make sense.

It's worth noting that the peak performance did decrease a little bit: 385 MB/s -> 375 MB/s.

## Problems?

The biggest shock of the firmware update is all the new SATA errors my kernel (Arch Linux pkg `linux 4.0.1-1`) has been spewing on the same interface the SSD is on.  I went from a fast drive with minor performance inconsistencies to a consistently (slightly) slower drive with SATA link timeouts. Great!

    [ 3675.245174] ata8.00: exception Emask 0x0 SAct 0x20000 SErr 0x0 action 0x6 frozen
    [ 3675.245181] ata8.00: failed command: WRITE FPDMA QUEUED
    [ 3675.245187] ata8.00: cmd 61/08:88:cd:a5:8e/00:00:0e:00:00/40 tag 17 ncq 4096 out
                            res 40/00:ff:00:00:00/00:00:00:00:00/00 Emask 0x4 (timeout)
    [ 3675.245189] ata8.00: status: { DRDY }
    [ 3675.245193] ata8: hard resetting link
    [ 3675.731795] ata8: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
    [ 3675.732016] ata8.00: supports DRM functions and may not be fully accessible
    [ 3675.732374] ata8.00: supports DRM functions and may not be fully accessible
    [ 3675.732434] ata8.00: configured for UDMA/133
    [ 3675.732440] ata8.00: device reported invalid CHS sector 0
    [ 3675.732467] ata8: EH complete

More errors on my [Github Gist](http://bit.ly/1zFnmjM) for those interested.

It's worth mentioning that `dm-cache`/`lvmcache` is thrashing that SSD after I took my SSD cached logical volume out of `cleaner` policy and back to `mq` policy.  Eitherway, the device shouldn't timeout SATA commands even if it is busy.

Time to double check that my daily back-ups are operating as expected.

## Update

As of 2015.05.09 my system would still generate sporadic timeout errors.  I've abandoned the hope that a background firmware task was doing something and would pass.  I've now re-mounted all my filesystems (btrfs and ext4) without the `discard` flag I was using before.  There's a chance this is the smoking gun as I've [seen this before](/linux/2013/05/05/ssd-trim/).

Someone commented on my Github Gist saying they are seeing the same issues.  Anyone else?  Post in the comments below.
