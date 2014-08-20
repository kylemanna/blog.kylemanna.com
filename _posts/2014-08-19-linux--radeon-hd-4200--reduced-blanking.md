---
layout: post
title: "Linux + Radeon HD 4200 + Reduced Blanking"
tagline: ""
category: 
tags: []
---
{% include JB/setup %}

## HDMI Display Timing Adventure

I finally installed Arch Linux on my HTPC which has an integrated Radeon HD 4200.  The goal is to run Kodi (formerly XBMC) for movies, podcasts, audio and some other random things.  In the past I ran Windows 7 Media Center and things just worked.

However, XBMC and my desktop apps would constantly glitch with static on the screen or dropped HDMI audio.  Sigh.  Very unlikely to be the cables or AV receiver in the middle since nothing changed between booting Windows 7, which works fine, and Linux.  So, this must be a driver problem.  I asked Google, but it looked at me like I was silly.

I had this feeling that maybe it's a timing issue and reviewed the EDID data from my receiver, but everything looked ok.  I messed around some mroe and stumbled on "CVT Reduced Blanking" as a timing hack to reduce bandwidth for high resolution displays over traditional cabling.  Hack out some `Modeline` in my Xorg config and boom, it works.

Gist with details:
<script src="https://gist.github.com/kylemanna/8d90218f031a12aa87c4.js"></script>

## A Window to What Works?

I booted back into Windows to attempt to determine if it was doing the same thing but could never find an app that gave me the impression that it was giving me actual timing info and not EDID data.  Maybe I'll find one, maybe not.

If I get really ambitious I might also see if the same issue occurred with OpenElec (don't recall seeing it though) and perhaps can blame a recent driver Arch has granted me the privilege of using.  If that's thes the case, I can hope that it might fix itself in a new kernel or Xorg driver, but that would require me to unconfigure the reduced blanking mode.

Until then, reduced blanking is the way to extend the life of this cheap HTPC rig for a year or so.
