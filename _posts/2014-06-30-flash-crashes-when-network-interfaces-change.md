---
title: "Flash Crashes When Network Interfaces Change"
tagline: "Docker kills SoundCloud!"
category: linux
tags: [linux, docker, flash, crash]
---

Boring Story of Discovery
=========================

I happened to be listening to a [SoundCloud](https://soundcloud.com) podcast while working on a Docker image.  At first the stream just seemed to be dropping for no apparent reason.  Closer investigation shows that *everytime* I did `docker run` or exited the container the stream would drop.  What?!  How is Docker related to my Chrome web browser on Arch Linux?!

How to crash it, the simplest Docker invocation possible:

    $ docker run --rm -it ubuntu:14.04 bash -c exit

Okay, lets try something else.  Chrome + YouTube, everything works and apparently all YouTube players are HTML5 now (finally!).  Vimeo? Well, same as YouTube.  I found site that had JWPlayer (Flash player), and it seems fine. What's going on?  Tried everything in Firefox, and it's the same as Chrome.  Lets blame Flash.

Back to docker, try to avoid creating network interfaces:

    $ docker run --rm -it --net=host ubuntu:14.04 bash -c exit

BOOM! No more crashing.  Flash is crashing everytime Docker creates veth network interfaces for my containers. Or at least tripping up the SoundCloud flash app.


Unexciting Fix
==============

Dug through the [SoundCloud Extra Settings](http://soundcloud.com/settings/extra) and clicked "HTML5 Audio" under "Experimental Features".

Life goes on.
