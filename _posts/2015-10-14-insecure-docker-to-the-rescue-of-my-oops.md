---
layout: post
title: "Docker (in)security to the Rescue"
description: ""
category: linux
tags: [linux, docker, shadow, password, oops, backup]
---
{% include JB/setup %}

## How Not to Diff Config Files

While cleaning up some new config files under `/etc` I accidentally deleted my `/etc/shadow` file (aka password file).  Oh shit.  Note that I typed `rm` not `meld` as intended.  Oh snap. Quick! Try to recover if `sudo` will let me back in without a password:

    $ sudo rm /etc/shadow /etc/shadow.pacnew
    $ sudo su -
    su: Authentication service cannot retrieve authentication info

Fail.  Of course I can't ssh back in as root because that's locked down.

I prepared for a reboot and an adventure into single user mode.  When suddenly my annoyance with Docker security returned to the rescue!

## Docker and Backups to the Rescue

Why don't I just mount my root file system and run a container as the root user with a volume mount of my broke file system?

    $ docker run -v /:/wtf --rm -it ubuntu cp /wtf/mnt/backup/core/etc/shadow /wtf/etc/shadow

Done.  What did I learn?  `docker >> sudo`

If I didn't have a back-up I could just use the Docker container to write a new `shadow` file.

## Case for Backups

Who doesn't keep back-ups these days?  Back-ups primarily protect me from sketchy btrfs incidents with the second biggest offender being myself when armed with a keyboard.  Somewhere at the end of the spectrum is hardware failure and physical loss.
