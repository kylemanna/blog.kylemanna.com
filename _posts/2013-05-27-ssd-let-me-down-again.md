---
layout: post
title: "SSD let me down again"
tagline: "time to start moving on..."
category: linux
tags: [linux, ssd, disk failure]
---
{% include JB/setup %}

This ship is sinking...
-----------------------

[It](/linux/2013/05/12/btrfs-crash/) happened again.  Btrfs began complaining about failed checksums on my rootfs and remounted itself as read-only.  I rebooted and the BIOS didn't see my OCZ Agility 2 SSD again.  Rebooted a few more times to confirm.

Shut off the power supply completely and then turn it back on and everything was fine again.  It's only time until it fails completely.  Until then I'll keep backing up and waiting for a good SSD deal on Slick Deals.  Too bad I missed the [500 GB Samsung 840 SSD for $285](http://slickdeals.net/permadeal/95602/dell-home-outlet-500gb-samsung-840-series-solid-state-drive-ssd-mz7td500).  Should have bought it.

I'll soon learn how exactly a SSD fails when it does fail.  No failed AHCI/SCSI operations, just warnings from the file system.  I guess this means the NAND memory is failing and the controller has no clue.  Interestingly enough, the controller didn't respond when rebooted and the BIOS enumerated the AHCI ports.

Good thing I have regular backups, just to be safe I explicitly snapshotted my rootfs with:

    sudo tar cf - --one-file-system / /boot | bar | lbzip2 -cs &gt; /mnt/massive/backup/sda5-rootfs.2013.05.27.tar.bz2

Health Data?
------------

&lt;sarcasm&gt;
As you'd expect, the [S.M.A.R.T.](http://en.wikipedia.org/wiki/S.M.A.R.T.) data says the drive is 100% ok.  Oh yeah, it passes the short, long and conveyance tests with flying colors.  I'm glad S.M.A.R.T. helps me confirm my drive is failing. **Not**.
&lt;/sarcasm&gt;

<script src="https://gist.github.com/kylemanna/5661039.js"></script>

Kernel Log
----------
<script src="https://gist.github.com/kylemanna/5660953.js"></script>
