---
title: "DreamHost and Duplicity Backups"
excerpt: "Random thoughts on using Duplicity to backup data to Dreamhost"
category: linux
tags: [backup, duplicity, dreamhost, rsync]
header:
  image: https://i.imgur.com/Ya8tcwD.gif
  overlay_color: "#000"
  overlay_filter: "0.5"
  overlay_image: https://i.imgur.com/Ya8tcwD.gif
---

## Backup Destination DreamHost

I started on Monday backing up my home computers to [DreamHost](http://bit.ly/2e6u0cw) backup using [duplicity](http://duplicity.nongnu.org/).

[DreamHost](http://bit.ly/2e6u0cw) gives their shared hosting users 50GB of backup for personal files. [DreamHost](http://bit.ly/2e6u0cw) offers "unlimited" diskspace on their webservers for hosting files accessed by the web. However, my personal files aren't to be accessed by anyone but me and I just wanted an offsite backup.

I researched backup solutions, initially turning to my tried and true over the past 10+ years rsync scripts. However, I don't trust [DreamHost](http://bit.ly/2e6u0cw) to keep my data secure, so I *need* encryption. I narrowed down the choices to either a TrueCrypt image that I could mount in Linux and then split and rsync, or use duplicity.

## Does TrueCrypt make sense?

I considered TrueCrypt for quite a while as the community following for it is rather impressive. However, syncing a single large image wasn't feasible. Splitting the 30-50GB image in to smaller pieces (guessing 250MB maybe) using the UNIX split command seemed to work with rsync, only transferring the major parts seemed to work on a 1GB test file I modified parts of. However, this just meant that now I needed to always keep 50GBs of space free so I could split the image which in turn was sync'd upstream.

## Fallback to Duplicity

I then resorted to duplicity. Initially, I didn't like idea of using tar (behind the scenes) which was then encrypted using GPG. I'm a long time users of rsync, where if I need one or two files I can instantly access them. However, I can't remember the last time I needed to that, so I bit the bullet and tried it. GPG is more secure as well (in my opinion) then TrueCrypt.

On Monday I gave it a shot, backing up my system's `/etc` directory and `/home` for the time being. The `--dry-run` in duplicity calculated approx 31GB of data to be copied... do some math using Wolfram Alpha considering my ~ 700Kb/s upload and we get 4 days 2 hours. Lovely, okay so my system will be hogging my Internet for a few days.

![Estimated Backup Time](http://i.imgur.com/Ya8tcwD.gif "Estimated Backup Time")

Some more research (via Google not firsthand) seems to suggest that duplicity won't pick-up where it left off either should it get interrupted, one of the features rsync does very well since it only deals with items on a file by file basis. So, I'll let it run.

After that I'll do incremental backups and then do a full backup next month. I also need to research compression algorithms in gpg's by adding `--gpg-options='--compress-algo=bzip2 --bzip2-compress-level=9'` to duplicity's options.

Oh yeah, and I need to make sure I can restore the backup.

## Conclusion

Duplicity is a glorified version of tar.
