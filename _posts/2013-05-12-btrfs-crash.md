---
layout: post
title: "Btrfs filesystem trips up"
tagline: "... again?"
category: linux
tags: [linux, kernel, btrfs, crash, bug]
---
{% include JB/setup %}

What Happened?
--------------

Btrfs let me down.  I left my computer for a few hours and came back and all disk IO to the root file system was hosed.  Load averages were 70+ as every process trying to read/write to the filesystem was hung in the dreaded disk wait state.  Luckily I was able to capture dmesg to my home directory as it was on another filesystem.  Any attempts to investigate further typically left that process in a disk wait state as well (couldn't even do ls -ltr /var/log).

Prior to the crash it's worth noting that the USB subsystem tripped up on a stalled endpoint (warning not a bug assertion) when I removed my Nexus 4 without properly disconnecting it.


Background
----------

I was a custom compiled kernel from an upstream Ubuntu 3.9 kernel package.  I was running this kernel so that I could experiment with dm-cache (which seemed fine...).  Perhaps I have bad patches?  We'll see if it happens again.  I couldn't re-create it with a quick test.

I also re-created my rootfs filesystem after I setup the 3.9 kernel due to troubleshooting my performance problems which were [actually caused by the discard flag](/linux/2013/05/05/ssd-trim).  The filesystem has no snapshots, no subvolumes (has the Ubuntu @home subvolume which is actually empty) and has very conservative mount options:

	$ mount
	/dev/sda5 on / type btrfs (rw,noatime,nodiratime,subvol=@)

More info on the filesystem:

	$ sudo btrfs filesystem show /dev/sda5
	Label: 'root'  uuid: 97ab20e5-14f9-4aa1-b7e3-5324702fa981
			Total devices 1 FS bytes used 5.82GB
			devid    1 size 21.42GB used 21.42GB path /dev/sda5

	Btrfs v0.20-rc1


Update - 2013/05/13
-------------------

About 12 hours later my system hung with a completely different error related to dm-cache not being able to commit metadata.  Coincidentally the metadata is stored on the same drive.  The system was completely unusable and my only option was a hard reboot.  Upon reboot grub tripped complaining that it couldn't find the drive.  I rebooted again, this time paying attention to the BIOS POST screens and noting the absence of my SSD.  I then powered the board off and checked the connectors and all was well again.

All things considered, this is probably due to the SSD connector being lose or the SSD approaching failure.  Looks like I'll need to backup my rootfs in a more complete manner to brace for the potential failure.  I'm also going to keep my eyes open for a good SSD on [slickdeals.net](http://www.slickdeals.net).


Original Kmesg Log
------------------

<script src="https://gist.github.com/kylemanna/5565930.js"></script>
