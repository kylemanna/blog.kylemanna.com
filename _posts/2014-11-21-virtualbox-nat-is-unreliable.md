---
title: "VirtualBox NAT is unreliable"
tagline: "surprise"
category: osx
tags: [linux, osx, virtualbox, vm, networking]
---

## Mac OS X + VirtualBox + NAT = Problems

I was running Mac OS X Mavericks + VirtualBox 4.3.18r96516 setting up a build system for Android when all of a sudden... random unexplinable corruption with a normal Android `repo sync`

    Write failed: Broken pipe
    fatal: The remote end hung up unexpectedly
    fatal: early EOF
	fatal: index-pack failed

Most unexpected?

    Connection to 10.x.x.x closed by remote host.
    fatal: The remote end hung up unexpectedly
    fatal: early EOF
	fatal: index-pack failed

Corrupt?

    Received disconnect from 10.x.x.x: 2: Packet corrupt
    fatal: The remote end hung up unexpectedly
    fatal: early EOF
	fatal: index-pack failed

This was while testing a local `repo` mirror I was setting up.  First instinct was to blame the old computer acting as the server, but hosting a git repo on old hardware shouldn't corrupt data, instead it should just be slow. Naturally, I ported the repo mirror mess over to a faster machine, same problem.

## Real Problem?

Virtual Box NAT.  That's it.  All I did was add a network bridge or *public network* in Vagrant speak and the problem was resolved.  Sigh.  Add default NAT and Shared Folders to the list of VirtualBox features that you should never touch unless you want poor performance and sometimes outright failure or corruption.

## In Other News

Checkout my Docker image for easily building Android or Cyanogenmod images on any Linux system without clobbering your host:

* [github.com/kylemanna/docker-aosp](https://github.com/kylemanna/docker-aosp)
* [registry.hub.docker.com/u/kylemanna/aosp](https://registry.hub.docker.com/u/kylemanna/aosp)

And for those of your forced to live in an Mac OS X world without a readily accessible Linux dev machine, checkout my Vagrant wrapper (which is way better then boot2docker):

* [github.com/kylemanna/vagrant-aosp](https://github.com/kylemanna/vagrant-aosp)
* [vagrantcloud.com/kylemanna/boxes/aosp](https://vagrantcloud.com/kylemanna/boxes/aosp)

Hopefully some day I can write them up!
