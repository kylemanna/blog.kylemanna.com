---
title: "Samsung 840 EVO SSD TRIM Support Blacklisted After Firmware Upgrade"
description: ""
category: hardware
tags: [linux, samsung, ssd, firmware, update, error, disk, performance]
---

## Firmware Upgrade Gone Wrong

A while back I did a firmware upgrade on my Samsung 840 EVO SSD because of potential performance problems with the TLC NAND.  I waited for the second release of the firmware and then bit the bullet and went on the Linux upgrade adventure.  The adventure didn't work out so well as I was hit with performance new problems after.  Annoyed, I scribbled up this [blog post](/hardware/samsung-840-evo-ssd--linux--firmware-update/) about that.

Someone posted a comment on my earlier blog post and I did some more digging and found that I'm not alone.  Ahhh, so I'm not imaging things.

## Search for Answers

My drive is now blacklisted as it relates to TRIM support in the kernel with this new little hint:

    [    1.056198] ata8.00: disabling queued TRIM support
    [    1.056201] ata8.00: ATA-9: Samsung SSD 840 EVO 250GB, EXT0DB6Q, max UDMA/133

The search starts and thanks to Linux and git, the search was finished in a few minutes with this [commit](http://bit.ly/1GumewK):

    commit 9a9324d3969678d44b330e1230ad2c8ae67acf81
    Author: Martin K. Petersen <martin.petersen@oracle.com>
    Date:   Mon May 4 12:20:29 2015 -0400

        libata: Blacklist queued TRIM on all Samsung 800-series

        The queued TRIM problems appear to be generic to Samsung's firmware and
        not tied to a particular model. A recent update to the 840 EVO firmware
        introduced the same issue as we saw on 850 Pro.

        Blacklist queued TRIM on all 800-series drives while we work this issue
        with Samsung.

        Reported-by: Günter Waller <g.wal@web.de>
        Reported-by: Sven Köhler <sven.koehler@gmail.com>
        Signed-off-by: Martin K. Petersen <martin.petersen@oracle.com>
        Cc: stable@vger.kernel.org
        Signed-off-by: Tejun Heo <tj@kernel.org>

Welp, that explains it.  At least it sounds likes Samsung might be working on an update which of course would mean a *third* firmware upgrade.  That sounds like software trying to fix a hardware problem.  Woof.  Might be searching for a new SSD if this is this affects data integrity and not just performance.

This patch came along in [Linux kernel 4.0.5](http://bit.ly/1GulVC0).  Which makes sense since my SSD has been behaving as I'm now running `linux-4.0.5-1 ARCH`.

Live dangerously my friends, but keep your backups up to date.
