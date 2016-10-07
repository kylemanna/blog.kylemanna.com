---
title: "Linux + Radeon HD 4200 + Reduced Blanking"
tagline: "Less wasted bandwidth"
category: linux
tags: [linux, radeon, amd, ati, timings, modeline]
---

## HDMI Display Timing Adventure

I finally installed Arch Linux on my HTPC which has an integrated Radeon HD 4200.  The goal is to run Kodi (formerly XBMC) for movies, podcasts, audio and some other random things.  In the past I ran Windows 7 Media Center and things just worked.

However, XBMC and my desktop apps would constantly glitch with static on the screen or dropped HDMI audio.  Sigh.  Very unlikely to be the cables or AV receiver in the middle since nothing changed between booting Windows 7, which works fine, and Linux.  So, this must be a driver problem.  I asked Google, but it looked at me like I was silly.

I had this feeling that maybe it's a timing issue and reviewed the EDID data from my receiver, but everything looked ok.  I messed around some mroe and stumbled on "CVT Reduced Blanking" as a timing hack to reduce bandwidth for high resolution displays over traditional cabling.  Hack out some `Modeline` in my Xorg config and boom, it works.

Gist with details:
<script src="https://gist.github.com/kylemanna/8d90218f031a12aa87c4.js"></script>

## A Window to What Works?

I booted back into Windows to attempt to determine if it was doing the same thing but could never find an app that gave me the impression that it was giving me actual timing info and not EDID data.  Maybe I'll find one, maybe not.

If I get really ambitious I might also see if the same issue occurred with OpenElec (don't recall seeing it though) and perhaps can blame a recent driver Arch has granted me the privilege of using.  If that's the case, I can hope that it might fix itself in a new kernel or Xorg driver, but that would require me to remember to remove the reduced blanking mode line.

Until then, reduced blanking is the way to extend the life of this cheap HTPC rig for a year or so.

## Update 2014.08.24

The reduced blanking is working great as I don't think I've observed a single stick after 10+ hours half watching / half listening.  Previously an error would be observed in less than 1 hour of XBMC / Kodi usage.

Meanwhile, I stumbled on some interesting [commits](http://lists.freedesktop.org/archives/dri-devel/2014-August/066738.html) that might make their way in to 3.17 on the *dri-devel* mailing list for "older ASICs (RV6xx, RS[78]80, RV7[79]0)".  Oh, interesting, but what's the name of the ASIC behind the "Radeon HD 4200" branding and is it relavent to my chip?

    $ lspci | grep VGA
    01:05.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] RS880 [Radeon HD 4200]

Confirmed as relavent.  [This patch (fdeaa939ce91c770b615ebe35cc1348756e09c5e)](http://cgit.freedesktop.org/~deathsimple/linux/commit/?h=uvd-r600-release&id=fdeaa939ce91c770b615ebe35cc1348756e09c5e) in particular is interesting because the comment says:

            /* the first reloc of an UVD job is the msg and that must be in
    -          VRAM, also but everything into VRAM on AGP cards to avoid
    -          image corruptions */
    +          VRAM, also but everything into VRAM on AGP cards and older
    +          IGP chips to avoid image corruptions */

Do I care enough to recompile my kernel and mess with the ucode now?  Nope, reduced blanking works.  This primarily serves as a mental note for me to check at some point in the future.  This blog is essentially a collection of semi-coherent mental notes...
