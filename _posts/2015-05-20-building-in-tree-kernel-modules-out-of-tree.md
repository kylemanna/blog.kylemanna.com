---
layout: post
title: "Building In Tree Kernel Modules Out of Tree"
description: ""
category: linux
tags: [linux, arch, aur, kernel, pkgbuild]
---
{% include JB/setup %}

## Don't Rebuild the Entire Kernel

I wanted to enable some extra features in my Arch Linux kernel (SocketCAN in particular) but didn't want to build, and more importantly, maintain my own custom kernel build.  This should be this hard, I'm sure someone has already done this or wrote an article about it.

Google appears to disagree.  Instead I would find people that were proud of building their own kernel.  I was that guy once, back in my Gentoo days.  Nowadays, I'm more pragmatic.

## Want It Done Right?

What if I could extract the necessary source files (assuming they can standalone like SocketCAN) and build them against the currently running kernel?  I wouldn't have to maintain my own kernel, just setup a [Dynamic Kernel Module Support (DKMS)](http://bit.ly/1LlUBtn) build in Arch and be done.  The DKMS integration would magically recompile and build my kernel modules on every kernel upgrade.

Tada.  It actually works and that's the end of the story.

## Minimum Maintenance

Periodically I'll have to update the upstream kernel the modules are extracted from, but that shouldn't be nearly as bad as baby sitting an entire kernel and all the config changes, patches and new bugs that go with that.

## Tell Me More

* GitHub [kylemanna/aur/linux-can-dkms](http://bit.ly/1LlV6nr)
* AUR [linux-can-dkms](http://bit.ly/1LlVkuF)
