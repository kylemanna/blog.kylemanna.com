---
title: "Major Linux Speed Up with tmpfs"
excerpt: "Put your volatile files in a tmpfs so it never touches the disk"
category: linux
tags: [hardware, linux, performance, ram, tmpfs]
header:
  image: https://i.imgur.com/JDZ3Uxw.jpg
  overlay_color: "#000"
  overlay_filter: "0.5"
  overlay_image: https://i.imgur.com/JDZ3Uxw.jpg
---

## Keep it in RAM

A few years ago I maxed out the RAM on my Intel Core 2 Duo system at 8GB.  RAM was super cheap for the time and why not?  Reality is that most of that RAM doesn't get used for much unless I'm running several virtual machines with large RAM allocations.

However, this past weekend I saw a post about using a RAM disk to speed-up your web browser.  Okay, cool idea, I read their post and it seemed over complicated.  Instead I figured I could do better, so I logged out of my Gnome desktop and logged in to a virtual terminal and added the following my `/etc/fstab`:

    tmpfs      /home/user/.cache  tmpfs    size=1G     0   0

Followed  by mount /home/user/.cache and the so far the speed-up has been huge.  I've been itching to replace my 4 year old Core 2 Duo with a new Sandy Bridge setup, but this may let me hold out for a while longer at least until the Intel Z68 chipset comes out or even as long as the Intel Ivy Bridge debut.

What that simple line does is creates a 1GB `tmpfs`, aka RAM file system, for everything in the cache folder. Consequently Chromium keeps it's cache there as does Compiz.  I look forward to more programs just using the directory and speeding up everything a little bit.

Simple task, huge difference.
