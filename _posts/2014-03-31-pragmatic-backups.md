---
layout: post
title: "Pragmatic Backups"
tagline: "in case my apt burns down"
category: linux
tags: [ backup, linux, archive, security, sharing. distributed, obnam ]
---
{% include JB/setup %}

Philosophy
==========

[World backup day](http://www.worldbackupday.com/) is March 31st, and while running <code>obnam fsck</code> on my remote backups I re-visited by backup strategy. In order to backup my data successfully, I need to first define what I'm trying to protect myself from.

Data loss causes in order of likeliness:

1. Me, myself and I.  Human error.
2. Unstable development file systems (btrfs) or fancy block devices (dm-cache or dm-crypt)
3. Hardware failure
4. Catastrophic loss like fire or theft

### Human Error

First off, I'm my own worst enemy.  The single biggest cause (or frequency?) of data loss for me is over zealous cleaning of old projects.  Humans aren't good at [data depulication](https://en.wikipedia.org/wiki/Data_deduplication).  After that, the command line sometimes bites me with more advanced invocations of the classic n00b <code>rm -rf /</code>, but I tend to go one step further and make the loss more interesting interesting something along the lines of <code>find / &lt;stuff&gt; -print0 | xargs -0 rm -rf</code>, ooops.  Same effect.

This happens. Not often, but usually the damage is obvious within a second or not noticed for months.

### Exotic Toys

I get excited about new file systems like [btrfs](https://btrfs.wiki.kernel.org) (file system level RAID, compression, [COW](https://en.wikipedia.org/wiki/Copy-on-write) snapshots, data-dedupe someday).  I jumped in and started using it before the fsck tools happened.  Unfortunately, my [SSD had flakey firmware](/linux/2013/05/05/ssd-trim/) and this caused problems that were only resolved with a power cycle because it put my entire system in disk I/O wait on the root file system.  Bad OCZ Agility SSD.  Turns out if I waited longer it would eventually return, but it wasn't obvious at first.

Guess what happens to data on a file system when you pull the power.  Uhoh.  Guess what happens to the file system when the fsck tool doesn't exist?  It stays broke.  I learned.

Then there was [dm-cache](/linux/2013/06/30/ssd-caching-using-dmcache-tutorial/) which I was obsessed about for awhile.  I'm still waiting for the lvm tools to integrate proper assembly and teardown userspace tools.  I still live dangerously (with data I can loose, ie ~/.cache).

### Hardware Failure

Hard drives physically fail.  RIP mechanical hard drives.  Some [SSDs are just flakey](/linux/2013/05/05/ssd-trim/) and eventually wear out as the underlying NAND approaches end of life.  I haven't yet had a drive spontaneously fail though, they all gave warnings. I took my data and I ran.  I don't assume I'll continue to be lucky.

### Catastrophic loss

My apartment has never burnt down.  My backup hard drives (or computer itself) were never stolen.  I assume it could happen though and must hedge against it.

Defining Tiers
==============

To assign value to different sets of data, I assign the data to a tier

### Tier 0

Tier 0 is data I can afford to lose.  It's not backed-up.  This is the insane amount of stuff I download and put in ~/tmp.  If it's gone I might be sad.  Maybe.  Probably not, I'd be happy I didn't have to delete it.

### Tier 1

Operating system files are in Tier 1, most aren't backed-up.  They are easily replaced in a disaster with a package re-install or recovery form a LiveUSB or similar should I blow them up.  For example, I don't need to back up my man pages.

### Tier 2

Configuration and media are files that would set me back if I lost.  Things like music and movies that I'd have to go and find again.  I'll consider <code>/etc</code> important, it's the only part of the OS anyone should ever really modify that's not packaged.  This also includes most of my home directory that I blindly assume I care about it.

### Tier 3

Tier 3 consists of files I cannot lose.  I'll be devastated if any of these files were to be lost.  Things like tax documents, pictures, private git repositories, security keys, e-mail, etc.  Losing these would ruin my digital life.

# Solutions

With the causes for data loss defined, and the value assigned to different tiers of data, I can now suggest solutions.

### Tiers 0 and 1

Ignore tiers 0 and 1, that data is easily replaced.  File systems with [COW](https://en.wikipedia.org/wiki/Copy-on-write) snapshots would easily protect these files from the most common cause of data loss (human error) with almost no real effort.

### Tier 2

Tier 2 is easily backed-up with rsync to another hard drive in my computer.  Every night via cron (or systemd timers soon enough).  Most UNIX guys can bang out a less then 100 line bash script that does what they want.  I used to use something more elaborate with rsync and hardlinks pretending to snapshot data, but that's gone.  [KISS](https://en.wikipedia.org/wiki/KISS_principle).  My current script just rsyncs over the top (destroying yesterday's data if I deleted it on accident and didn't notice).  Maybe someday I'll update it to use file system snapshots to replace the hardlink approach I once used.  Maybe not.  The important data is also in Tier 3 anyways.

Using a 2 TB mechanical harddrive is incredibly cheap and fast.  Backing up the data is fast and recovering from a loss (rm -rf /path/to/project) is fast as well.  With rsync, my data is essentially mirrored every morning to another drive and it's as simple as copying it back.

Every morning I get an email from the <code>rsync -a --verbose --stats</code> output and typically skim it and delete it.  This is feedback so that I know the backup happened. Some might consider it annoying, but it helps me sleep at night.  I know the backup happened and didn't run out of space on the backup drive.  Also I can see what churns in my system and investigate if it doesn't seem right.

Tier 2 is my first defense against myself and toy file systems. :)

### Tier 3

Backing up my Tier 3 data is a bit more complicated and expensive.  It involves more money and remote backups.  Remote back-ups require data confidentiality (aka encryption) and integrity.

I want it to be automated and that rules out USB3 external hard drives.  I don't have that volume of data, and if we put a human in the loop, the human (read: me) will fail.

Since the data is finding its way to a remote system, it must be encrypted before it leaves my system, and I'm not talking about transport layer security.  My files must be encrypted with something like GPG or something that uses AES behind the scenes.  I want it to be open source too so I can at least review it or fix it if I need to.

For the past year I've been solving this problem with [obnam](http://liw.fi/obnam/).  I have a simple obnam script that backs-up my Tier 3 data to two remote servers every night.  Dreamhost offers [50 GB of personal sftp accessible backup space](http://wiki.dreamhost.com/Personal_Backup).  In addition to that I use one of my ChicagoVPS OpenVZ servers.  The cost for Dreamhost is essentially free since I already have it for other things.  The ChicagoVPS server gives me ~ 120 GB of space for $55 / year (this was a promotion).  Pretty good deal when compared to things like DropBox (and DropBox is a sharing app not, backup app people!).

Obnam basically runs twice every morning and backs-up the data to each remote endpoint.

The data confidentially requirement happens automatically with, obnam via GPG encryption.  Done.  Setup gpg-agent and don't worry about it.  Unfortunately it needs the private key to access the backup metadata.  It'd be nice if it only used the public key for encryption so the private key could be better protected.  Good enough for now.

Data deduplication is handled by obnam, so my backup sizes stay small.  Obnam performs incremental backups using B-trees.  The script then expires (obnam calls it "forget") old data and prints out the "generation" information aka snapshot.  My daily email from the simple script looks like the following (note the separate backups to different servers):

	Backed up 979 files (of 13716 found), uploaded 54.7 MiB in 2m6s at 444.5 KiB/s average speed
	11635	2013-04-26 03:27:25 .. 2013-04-26 03:36:04 (18006 files, 36761547006 bytes) 
	13061	2013-05-31 03:27:25 .. 2013-05-31 03:28:38 (17842 files, 34614847082 bytes) 
	14696	2013-06-30 22:22:22 .. 2013-06-30 22:25:02 (17749 files, 34622950118 bytes) 
	15873	2013-07-31 03:27:28 .. 2013-07-31 03:29:32 (17707 files, 34721604237 bytes) 
	17474	2013-08-31 03:27:28 .. 2013-08-31 03:29:12 (24565 files, 34889404792 bytes) 
	18927	2013-09-30 03:27:28 .. 2013-09-30 03:28:44 (18742 files, 35395434340 bytes) 
	20246	2013-10-30 22:57:11 .. 2013-10-30 22:59:59 (18869 files, 35516056512 bytes) 
	21466	2013-11-30 03:27:28 .. 2013-11-30 03:27:54 (19888 files, 36024472725 bytes) 
	22535	2013-12-31 03:27:30 .. 2013-12-31 03:29:00 (19989 files, 35712483841 bytes) 
	25036	2014-01-31 03:27:28 .. 2014-01-31 03:28:53 (20933 files, 35962312282 bytes) 
	26395	2014-02-28 03:27:28 .. 2014-02-28 03:28:24 (18262 files, 35679125624 bytes) 
	26446	2014-03-02 03:27:31 .. 2014-03-02 03:28:41 (18262 files, 35681209647 bytes) 
	26722	2014-03-09 03:27:34 .. 2014-03-09 03:28:42 (18404 files, 35681223036 bytes) 
	27115	2014-03-16 03:27:31 .. 2014-03-16 03:28:39 (18414 files, 35716180727 bytes) 
	27273	2014-03-20 03:27:29 .. 2014-03-20 03:28:41 (18522 files, 35720653265 bytes) 
	27306	2014-03-21 03:27:29 .. 2014-03-21 03:28:36 (18522 files, 35718873510 bytes) 
	27341	2014-03-22 03:27:27 .. 2014-03-22 03:28:44 (18522 files, 35719528712 bytes) 
	27385	2014-03-23 03:27:31 .. 2014-03-23 03:28:36 (18522 files, 35719615910 bytes) 
	27417	2014-03-24 03:27:30 .. 2014-03-24 03:28:36 (18524 files, 35720142314 bytes) 
	27470	2014-03-25 03:27:29 .. 2014-03-25 03:28:39 (18524 files, 35720975216 bytes) 
	27506	2014-03-26 03:27:29 .. 2014-03-26 03:28:31 (18524 files, 35725286154 bytes) 

	Backed up 979 files (of 13716 found), uploaded 54.7 MiB in 1m25s at 659.2 KiB/s average speed
	735	2013-06-30 22:28:16 .. 2013-06-30 22:32:46 (14995 files, 25509263450 bytes) 
	1917	2013-07-31 03:32:13 .. 2013-07-31 03:36:07 (14950 files, 25607790365 bytes) 
	3197	2013-08-31 03:32:23 .. 2013-08-31 03:37:15 (21808 files, 25775590920 bytes) 
	4493	2013-09-30 03:32:21 .. 2013-09-30 03:35:39 (15985 files, 26281619811 bytes) 
	5526	2013-10-30 23:03:08 .. 2013-10-30 23:05:19 (16112 files, 26402271650 bytes) 
	6540	2013-11-30 03:29:30 .. 2013-11-30 03:29:50 (17131 files, 26910658853 bytes) 
	7478	2013-12-31 03:31:46 .. 2013-12-31 03:32:48 (17232 files, 26598670311 bytes) 
	9921	2014-01-31 03:31:33 .. 2014-01-31 03:32:36 (20750 files, 27140681274 bytes) 
	11202	2014-02-28 03:30:47 .. 2014-02-28 03:31:28 (18079 files, 26857316902 bytes) 
	11253	2014-03-02 03:30:20 .. 2014-03-02 03:31:10 (18079 files, 26859400925 bytes) 
	11518	2014-03-09 03:30:20 .. 2014-03-09 03:31:04 (18221 files, 26859414360 bytes) 
	11780	2014-03-16 03:30:16 .. 2014-03-16 03:31:05 (18231 files, 26894372209 bytes) 
	11926	2014-03-20 03:31:41 .. 2014-03-20 03:32:27 (18339 files, 26898844743 bytes) 
	11959	2014-03-21 03:31:19 .. 2014-03-21 03:32:10 (18339 files, 26897064988 bytes) 
	11993	2014-03-22 03:31:31 .. 2014-03-22 03:32:30 (18339 files, 26897846686 bytes) 
	12036	2014-03-23 03:30:15 .. 2014-03-23 03:30:53 (18339 files, 26897807188 bytes) 
	12068	2014-03-24 03:32:28 .. 2014-03-24 03:33:15 (18341 files, 26898333916 bytes) 
	12118	2014-03-25 03:31:22 .. 2014-03-25 03:32:13 (18341 files, 26899176738 bytes) 
	12152	2014-03-26 03:31:12 .. 2014-03-26 03:31:57 (18341 files, 26903477472 bytes)

Note the frequency the incremental data is kept.  Daily backups for the last week, and then monthly backups after that.  Perfect!  I could even increase the frequency to several time sa day if I wanted to, but I see no need.

I have two minor issues with obnam. First, when I run <code>obnam fsck</code> it complains that I have unlinked/orphaned chunks that it currently doesn't clean-up.  I assume these are from interrupted backups. Secondly, I don't understand why the data backup sizes and file counts are different between the servers, potentially due to the orphaned chunks?

Evolution
=========

I'd like to find a solution that lets me backup more data in Tier 2 and possibly merge Tier 2 and 3 if I can find a remote solution that would let me cost effectively store that much data.  That's a problem for another day.

I keep looking at and playing with [SpiderOak](https://spideroak.com/download/referral/190e74541014e319ba3dd116976563ba).  I wish I took advantage of their "unlimited" backup promotion, should they offer it again I'll definitely sign-up.  [SpiderOak](https://spideroak.com/download/referral/190e74541014e319ba3dd116976563ba) is very [security concious](https://spideroak.com/zero-knowledge/) and I enjoy following their [blog](https://spideroak.com/blog/).  I've been playing with their free package for a few weeks and think it's "ok".  I'd definitely recommend it to any of my less tech savvy friends as a back-up and DropBox replacement (see [SpiderOak Hive](https://spideroak.com/hive/)).  Use my referral link to get an extra 1 GB by clicking [here](https://spideroak.com/download/referral/190e74541014e319ba3dd116976563ba)

Or maybe a larger VPS from someone like [Backupsy](http://backupsy.com/)(Uses KVM too ftw, hate OpenVZ).

I **love** the idea of distributed back-ups with anonymous peers, but they all seem pretty immature and I'm concerned about availability:
* [Tahoe-LAFS](https://tahoe-lafs.org/trac/tahoe-lafs) - the web interface kills it, the ghetto FUSE implmentation and incompataiblity with NAT kill it.  The security and data distribution principals are awesome though.
* [Symform](http://www.symform.com) - tries to be exactly what I want, but is of terrible quality (back-up software written in Mono!?).  Basically you get 1 GB for ever 2 GB of space you contribute.  I failed to make their lame Linux software ever work.  Enough to scare me away for some time.
* [SpaceMonkey](https://www.spacemonkey.com/) - would be perfect if I didn't have to use their embedded device, but could just run an app on my file server.  Also afraid it maybe be crude or immature like Symform.
* Others? Let me know!
