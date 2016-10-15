---
title: "New Filesystem and Hard Drives?"
excerpt: "When your hard drive starts making a clicking noise, it's over"
category: linux
tags: [hardware, linux, seagate, fail, gentoo, btrfs]
header:
  image: https://i.imgur.com/O4VF8Xp.jpg
  overlay_color: "#000"
  overlay_filter: "0.5"
  overlay_image: https://i.imgur.com/O4VF8Xp.jpg
---

## Upgrade Plan

I have been planning on upgrading my main PC which double as my HTPC fileserver at the end of the year when Intel releases Sandy Bridge.  A new motherboard, processor, a SSD, and some DDR3 were the original plan.  However, in light of my recent hard drive fiasco, my 250GB Seagates may be retired sooner then originally planned.  My SMART reallocated sector count (SMART id# 5) is at 7, and I anticipate it growing.  Until it becomes an issue I intend to keep using it, and send it out a few months before the warranty expires in 2011.

That said, I've been reconsidering my entire filesystem approach.  Originally I had the following setup:

* `/dev/sd{a,b}1`
    * /boot partition consisting of /dev/sda1 and /dev/sdb1
* `/dev/sda2`
    * Win7 system partition
* `/dev/sdb2`
    * Linux root partition
* `/dev/sda3`
    * Linux RAID0 striping + LVM

Following the hard drive failure, Win7 has been reinstalled on a partition on 1TB hard drive  (which is mostly my backup drive for Linux data), and my Linux root partition became the more stable /dev/sda2 partition since sdb is on it's way out.

That said, I've been looking for a way to pool my growing number of old disks in to a backup filesystem (I have a few old 120GB - 300GB PATA drives laying around).  I've looked at things like FlexRAID and unRAID, but they don't seem to be really that well thought out and more targeted for Windows HTPC users.  ZFS has been an industry buzzword for sometime, but it lacks native kernel level implementation in Linux, and I fear it won't let me add/remove drives on the fly (I don't want to use RAIDZ).

## Consider btrfs

This leads me to btrfs or "butter fs".  So far I've gathered that it is seriously lacking in things like man pages, but for the most part it seems to work as a simple file system.  I've setup sda2 and sdb2 (my former Linux RAID0 + LVM) to be a btrfs.  My home directory (which is backed-up daily) has been running from it and so far it works as just a file system.  It has the filesystem metadata mirrored on both drives and the data is stripped.  I'm not sure of an effective way to benchmark the filesystem other then just use it, and so I will until my Seagate sdb drive is on its last legs leading me to RMA it and purchase some new Samsung Spinpoint 1TB F3 HD103SJs (which are the current hot ticket and pretty cheap @ $70 shipped from Newegg.  At that point, I'll pick something stable and go back to not worrying about it.

Until then btrfs has some other appealing features I'm looking to test out:

* Compression
* De-duplication
* Snapshots
* Multi-device file-system (ie the filesystem knows about two drives rather then letting RAID masquerade this.

First off, compression is just that, it seems that it uses zlib and compresses some files on the fly as it writes them resulting increased write/read speeds for plain-text compressible files.

I know I have multiple copies of the same file scattered all over my drive, and de-duplication is an easy way for me to save some space without doing anything.  Good deal.

Snapshots would be handy way to protect me from `rm -rf ./dir` followed my "OH SHIT".  Although my current nightly rsyncs to a backup drive make me feel plenty safe.

And finally, the most important is the multi-device file-system support.  This would enable me to replace md + LVM for my primary storage and it would help me to achieve my goal of pooling old disks for use as a backup.  I'm still having a hard time dropping my old way of RAID thinking where all the drive properties have to match.

For example, say I have a ghetto RAID setup (which I do for the purposes of testing), like:

* `/dev/sda3` (190GB)
* `/dev/sdb3` (190GB) and is maybe dying
* `/dev/tb1/btrfstest` (70GB) lvm on a 1TB WD Black

You could start out by striping data and mirroring metadata like this:

    # mkfs.btrfs -L newhome /dev/sda3 /dev/sdb3
    # mount /dev/sda3 /home

You then copy your home data over using rsync...

Now, at this point I wanted to remove /dev/sdb3 from the setup, but was shot down with: 

    # btrfs-vol -r /dev/sdb3 /home
    btrfs: unable to go below two devices on raid1

Okay, so lets add that logical volume from my 1TB drive just for kicks and then re-stripe/balance the data for performance.


    # btrfs-vol -a /dev/tb1/btrfstest /home
    ioctl returns 0
    # df -h
    Filesystem            Size  Used Avail Use% Mounted on
    /dev/sda3             461G   56G  402G  13% /home
    # btrfs-vol -b /home

That easy huh?  All without unmounting the filesystem (and infact, all while writing this).  Now lets pretend sdb3 starts dying again and we want it out as we tried before:

    # btrfs-vol -r /dev/sdb3 /home

Filesystem grinds and after some time it finishes.  Running dmesg shows it's working:

    btrfs: found 2594 extents
    btrfs: found 2594 extents
    btrfs: relocating block group 84854964224 flags 9

Easy enough, and impressive to say the least. The only real question now is, if I can add/delete drives to btrfs filesystems on the fly, should I go for data striping and possibly (not confirmed with btrfs method of striping objects) incurring a latency penalty, or just have the data in "single" for the backup volume(s).

Time will tell...
