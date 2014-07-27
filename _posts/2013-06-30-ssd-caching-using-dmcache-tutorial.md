---
layout: post
title: "SSD Caching Using dm-cache Tutorial"
tagline: "big and fast"
category: linux
tags: [cache, dm-cache, ssd, linux, dmsetup, device-mapper, howto, tutorial, performance, server, disk]
---
{% include JB/setup %}

## Update - 2014 July

Many of the following steps in this post are **no longer required or recommended**.  Consider it more of a behind the scenes guide for dm-cache from the early days. :)

* Modern distros have kernel support for dm-cache out of the box, so don't worry about updating the kernel.
* The latest lvm2 tools have support for `lvmcache` which is a front-end to dm-cache and is *much* easier to use.  At the time of this update, it appears that only Fedora (and derivatives) have support.  [Arch Linux bug 40754](https://bugs.archlinux.org/task/40754) and [the 41291 dupe I reported](https://bugs.archlinux.org/task/41291) will track the *currently* missing feature in Arch Linux.
* For more documentation on `lvmcache` consider `man lvmcache` if your lvm2 package is up to date and has cache support.  Also consider [Richard Jones' LVM Cache blog post](http://rwmj.wordpress.com/2014/05/22/using-lvms-new-cache-feature/) for a guide that approximates the man page.
* I've played with `lvmcache` and like it, if I have time I'll write-up a blog post regarding performance.  For reference, running `git grep blah` on a recent kernel tree takes 25-30 seconds on traditional HDD, 2 seconds on a SSD and 4 seconds on the same HDD + SSD + dm-cache with a warm cache.  A good compromise.

What's dm-cache?
----------------

Dm-cache is a device-mapper level solution for caching blocks of data from mechanical hard drives to solid state SSDs.  The goal is to significantly speed up throughput and latency to frequently accessed files.

What's About to Happen
----------------------

This tutorial is going to cover the basic steps to setup dm-cache on a Ubuntu 13.04 machine.  It easily translates to other distributions, but users will need to find a sufficient kernel and modify the init scripts to fit their init system.

One of the nice things about dm-cache is that it doesn't require you to create a new block device to store your file system on.  Instead dm-cache sits on top of your existing file system or you create a new file system.  I'm going to assume you already have a file system and you just want to add caching.  If not, creating a file system on a block device is trivial.

If you have no clue what I just said, this tutorial definitely isn't for you and you may lose your data.  Your dog will die.  And your house will burn down.  Don't say I didn't warn you.


How I've Been Using dm-cache
----------------------------

All of my testing over the past few months has been with test data and my <code>$HOME/.cache</code> folder for my Unity desktop.  All the data on dm-cache volume was data that could easily be replaced in the event of a disaster.  I suggest you do the same until dm-cache earns your trust.  Once I trust dm-cache the plan is to cache my entire /home file system.

My SSD has been slowly dying on me, and to this point it appears that dm-cache has sustained hardware block device failure with a resiliency similar to that of a standard ext4 file system.  See [my old blog post](/linux/2013/05/12/btrfs-crash) for aimless babbling on the topic.

Additionally, I have daily backups up all my important data.  Complete backups are done to another hard drive, and off site backups are done using [obnam](http://liw.fi/obnam/).  If you don't have backups and you're playing with this new technology, you're crazy.  Back it up.


Update Your Kernel
------------------

The Linux v3.9 kernel added support for the dm-cache support, so you'll need to get at least version Linux v3.9 kernel to get this to work.  Ubuntu 13.04 comes with a v3.8 kernel.  We'll need to update that.  At the time of this writing, I'm using Ubuntu's v3.10 saucy release on Ubuntu 13.04 with no issues.  You can download that form the Ubuntu [kernel ppa site](http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.10-saucy/).

For an x64 system (and if you are running x86, wow...) updating the kernel is as easy as: 


    $ wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.10-saucy/linux-headers-3.10.0-031000-generic_3.10.0-031000.201306301935_amd64.deb http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.10-saucy/linux-headers-3.10.0-031000_3.10.0-031000.201306301935_all.deb http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.10-saucy/linux-image-3.10.0-031000-generic_3.10.0-031000.201306301935_amd64.deb

    $ sudo dpkg -i linux-headers-3.10.0-031000_3.10.0-031000.201306301935_all.deb linux-image-3.10.0-031000-generic_3.10.0-031000.201306301935_amd64.deb linux-headers-3.10.0-031000-generic_3.10.0-031000.201306301935_amd64.deb


Now reboot your system and verify you're now running the new kernel:

    $ cat /proc/version
    Linux version 3.10.0-031000-generic (apw@gomeisa) (gcc version 4.6.3 (Ubuntu/Linaro 4.6.3-1ubuntu5) ) #201306301935 SMP Sun Jun 30 23:36:16 UTC 2013


Setup Your Caching SSD Device
-----------------------------

There are a number of ways to setup your SSD.  Essentially, we need to create two sections to store the SSD metadata and cache regions.  There are three ways you can do this:

1. Create two traditional partitions
2. Use device mapper's dm-linear feature to split up a single partition
3. Use LVM as a front-end to device mapper

To keep things simple, I just did #2, it allowed me the most flexibility during my initial testing.  Create a partition on your SSD device for use later in this tutorial with dm-linear.  Ensure no valuable data resides on that partition as it will be lost.


Manually Configure the SSD Cache
--------------------------------

Now is the time to assemble the dm-cache device for the first time and see how it works.  Ensure that your original file system is unmounted before proceeding.


1. Find the actual size of your SSD used for caching blocks.  According to [this mailing list posting](https://www.redhat.com/archives/dm-devel/2012-December/msg00046.html), the metadata size will be about <code>4 MB + ( 16 bytes * nr_blocks )</code>, where nr_blocks is ths number of blocks on the device volume.  For this tutorial I'm going to use 256 KB (262144 bytes) cache block size.  To keep the math simple, ignore the chunk that is about to be cut out from the metadata from the entire SSD partition allocated for the caching.  Determine the size:

       $ sudo blockdev --getsize64 /dev/disk/by-id/scsi-SATA_OCZ-AGILITY2_f2d200034-part6
       96782516224

2. Calculate the ssd-metadata size in bytes: <code>4194304 + (16 * 96782516224 / 262144) = 10101440</code>, where 96782516224 is the total size of our ssd cache partition. The result is the size of the metadata partition in bytes, convert it to number of sectors: <code>10101440 / 512 = 19729.375</code>, round up to <code>19730</code> to play it safe.
3. Create the ssd-metadata dm device and zero it out so it isn't misinterpreted by dm-cache (happened to me when re-creating caches):

       $ sudo dmsetup create ssd-metadata --table '0 19730 linear /dev/disk/by-id/scsi-SATA_OCZ-AGILITY2_f2d200034-part6 0'
       $ sudo dd if=/dev/zero of=/dev/mapper/ssd-metadata

4. Calculate the remaining size available for ssd-blocks: <code>96782516224 / 512 - 19730 = 189008622</code>
5. Create the ssd-blocks dm device that will hold the actual data blocks, it will follow the metadata region:

       $ sudo dmsetup create ssd-blocks --table '0 189008622 linear /dev/disk/by-id/scsi-SATA_OCZ-AGILITY2_f2d200034-part6 19730'

6. Determine and number of sectors of your existing file system you want to add cache support to:

       $ sudo blockdev --getsz /dev/vg0/spindle
       1048576000

5. Create the actual dm-cache device with 256 KB cache blocks (512 * 512):

       $ sudo dmsetup create home-cached --table '0 1048576000 cache /dev/mapper/ssd-metadata /dev/mapper/ssd-blocks /dev/vg0/spindle 512 1 writeback default 0'

6. Verify that the device was created and working:

       $ ls -l /dev/mapper/home-cached
       lrwxrwxrwx 1 root root 7 Jun 30 22:20 /dev/mapper/home-cached -> ../dm-5
       $ sudo dmsetup status /dev/mapper/home-cached
       0 1048576000 cache 1105/65536 144554 179602 336023 1797 0 1 28139 28139 0 2 migration_threshold 2048 4 random_threshold 4 sequential_threshold 512

7. Put it to use by mounting it:

       $ sudo mkdir /mnt/cache
       $ sudo mount /dev/mapper/home-cached /mnt/cache 

8. Play with it, re-run the status command from above to view cache status.
9. That's it.  Simple as that.  Let me know what you think.  Note, the home-cached device will disappear on reboot, so init scripts will need to be setup to properly construct the dm-cache block device each time.  See the next section for hints on how to do that on Ubuntu with upstart.


Install init Scripts to Setup SSD Cache At Boot
-----------------------------------------------

Ubuntu upstart script to setup the device-mapper devices every time at boot and cleanly shutdown the device-mapper devices the moment the volume is unmounted using inotify:

<script src="https://gist.github.com/kylemanna/5899179.js"></script>

Install these files as root under /etc/init.  Upstart will take care of the rest on next reboot.


Actually Using It
-----------------

I have backed up my old files and then copied them to my ssd-cached file system.  I create symlinks from my more important file systems to this test file system.  Again, the goal is test it for now.  Later I'll use dm-cache to cache my entire /home file system and won't need symlinks.


My <code>$HOME/.cache</code> directory is an excellent test candidate. Things like file browsing (thumbnails and what not) are stored on the ssd-cached file system and are much snappier then before.  Google Chrome stores its caches under <code>$HOME/.cache</code> here too, so cached web browsing is now faster.

Another good idea is the Linux kernel source tree.  Running <code>git grep</code> on files cached by the ssd is significantly faster.

Go wild.  Let me know what other clever things I can cache before I take the risk of putting my entire /home file system on a dm-cache volume.


Disabling The Cache
-------------------

If you ever want to decommission the cache, you'll need to run the cleaner policy.  The cleaner policy will write all the dirty cached blocks back to the underlying device.  In a nutshell it works like this:

    $ sudo umount /dev/mapper/home-cached
    $ sudo dmsetup table home-cached
    0 1048576000 cache 252:3 252:4 252:0 512 1 writeback default 0
    $ sudo dmsetup status home-cached
    0 1048576000 cache 737/2466 1018 224354 0 3 0 89 89 0 0 2 migration_threshold 2048 4 random_threshold 4 sequential_threshold 512
    $ sudo dmsetup suspend home-cached
    $ sudo dmsetup reload home-cached --table '0 1048576000 cache 252:3 252:4 252:0 512 0 cleaner 0'
    $ sudo dmsetup resume home-cached
    $ sudo dmsetup wait home-cached
    <wait for dirty data blocks to be written out>

In theory, you should be able to fsck on the underlying device (/dev/vg0/spindle) and it should look just fine at this point.  You could then disable the init script and never use the cache again.  Alternatively you could reconfigure it to your heart's content.

Follow this up with <code>dmsetup remove &lt;dev-name&gt;</code>


Kernel Documentation
--------------------
* [Device Mapper Documentation](https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/Documentation/device-mapper)
* [Device Mapper - Cache](https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/Documentation/device-mapper/cache.txt)
* [Device Mapper - Cache Policies](https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/Documentation/device-mapper/cache-policies.txt)


Future Steps
------------

I need to purchase a new SSD, I have my sights set on a Samsung SSD 840 Pro, but I am waiting for a good deal.  At that point I can stop worrying about by dying SSD and then try dm-cache over my entire /home file system and see what kind of trouble I can get in to.

Later I'm going to explore tweaking the cache parameters as right now the policies don't seem to fit my desired use case.  I don't want long sequential operations going straight to the hard drives, I'd rather they go to the SSD until they need to migrated.  Additionally, it'd be nice if there was a continuous ongoing migration of all the dirty data on the SSD to the old hard drives.
