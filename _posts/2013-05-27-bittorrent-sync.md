---
layout: post
title: "BitTorrent Sync"
tagline: "almost too easy"
category: sharing
tags: [sharing, files, p2p, btsync]
---
{% include JB/setup %}

BitTorrent Sync
---------------

I played with [BitTorrent Sync](http://labs.bittorrent.com/experiments/sync.html) this weekend a bit.  It's quite an interesting technology and works on Mac OS X, Windows, Linux, and ARM Linux.  It could function as a Dropbox replacement that doesn't need files on a dedicated third-party cloud server.

A user can share a folder with nothing more then 32 character *secret*.  The folder can be shared read-only, read-write, and a one-time *secret* valid for 24 hours.  Another computer or series of computers that knows the *secret* can then connect to the folder and sync with it.  That's it.

No messing with firewalls, no hosting formal services.  Just make sure the btsync daemon is running and can connect to the network.  The btsync daemon will then sync files between the other computers using the local network if it can discover the *secret* on the LAN.  This means you can copy files significantly faster than was ever possible with Dropbox.

It uses peer-to-peer technology to find hosts over the Internet.  All data is encrypted using a AES-256 bit key created using the *secret* described above.  The remote hosts on the Internet only know that certain hosts are communicating, but nothing about the data itself.

[Check it out!](http://labs.bittorrent.com/experiments/sync.html)


The Good
--------

Simple to use, an individual could set it up using the binary installers for Windows or Mac OS X and securely send the *secret* to access some files and vice-versa.  Awesome for collaborating with other users.

Doesn't cost money!

No effective sharing limits.  Only constraints are network bandwidth and disk size.

Future uses?  Probably has more applications for things I haven't even thought of yet...


The Bad
-------

Unfortunately, BitTorrent Sync isn't open source.  I'm sure it's only time before someone makes an open source replacement.  I'm hard to sell on ultimate security unless it's open source.

I'm kind of annoyed by the way the metacache is handled.  I whined about it on the forum when I realized it [wastes 90%+ disk space](http://forum.bittorrent.com/topic/20092-metacache-organization-wastes-90-disk-space/).  Hopefully this will get fixed so that it scales better.  If it was open source...

Another negative is that it doesn't preserve file permissions.  Preserving file permissions across multiple platforms is difficult to implement and I don't have a clue how to do it effectively.  Not sure that this will ever change.

No version control, yet.  Looks like this is a planned enhancement.

Web UI is missing more information about transfers.

Also doesn't appear to allow a way for individual computers to not sync certain parts of a share.  It's all computers or no computers with the *.SyncIgnore* file.

Tests
-----

All I really did was sync some files between my laptop, workstation, and my vps.  Worked pretty seamless.  I'll have to find an excuse to share some files with friends and get creative.

One of the BitTorrent Sync guys setup a [simple cloud with a Raspberry Pi](http://blog.bittorrent.com/2013/05/23/how-i-created-my-own-personal-cloud-using-bittorrent-sync-owncloud-and-raspberry-pi/).  I could dig up an old BeagleBoard and an old harddrive with a USB 2.0 enclosure, ship it to my parents and mirror my obnam gpg backups using it.  I suppose I could have done that already though with rsync + ssh + OpenVPN.

I'll keep looking for clever applications...
