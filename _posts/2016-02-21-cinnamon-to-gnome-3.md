---
layout: post
title: "Cinnamon to GNOME 3"
description: ""
category: linux
tags: [linux, cinnamon, gnome]
---
{% include JB/setup %}

## Cinnamon Was Crampin' My Style

I had been using Cinnamon on Arch Linux for years without issue.   Recently I've noticed that my Chrome browser and terminals would get slow as hell after a few weeks and restarting Chrome didn't fix it.  Eventually I'd restart for updates and it would be better.  I assumed Chrome was becoming a resource hog and creating tons of memory fragmentation.

Wrong.  It appears it was Cinnamon or it's window manager or whatever.

## Enter GNOME 3

I switched my desktop environment to GNOME 3 and changed nothing else... and it's fine.  Perfect.  Weeks later and Chrome (and friends) are just fine now.  Ok.  I'll keep it.

## Minor Annoyances with GNOME 3

I want a semi-tiled desktop environment but can stand the full tiling window managers where every pop-up gets tiled.  Annoying.  Cinnamon had the perfect experience where I could hit SUPER+Left/Right Arrow and the selected window would tile on the left/right half.  Simple.  I would then typically resize one window to 2/3 instead of half.  The tiling works in GNOME 3, but it doesn't allow resizing.  I did some research (and lost the corresponding links) and there appears to be some work to evolve the tiling feature.  Ok.  I can wait and manually resize windows for now.

I don't remember screwing with my cinnamon screensaver before, but it just worked with things like YouTube.  Not in GNOME 3.  The Arch Linux [gnome-shell-extension-caffeine](https://aur.archlinux.org/packages/gnome-shell-extension-caffeine-git/) AUR fixes this in no time.  How is this not included in GNOME 3?

The UI consitencies between the new GNOME 3 shell UI, old GTK, and miscellaneous other things are annoying.  I'm annoyed that all pop-ups appear over the main window.  I tend to do things like open a PDF (typically an IC datasheet) with Evince and then save it with a correct name or part number in the directory where I want it.  But, I can't do that because the pop-up typically pops-up over the name of the part.  Agrh.  Annoying.  Perhaps there is a tweak.

Also, why are all the menus in GNOME 3 apps hidden away and difficult to access.  Why?

I could ramble on for a while, but for now GNOME 3 is better then Cinnamon because of performance issues in Cinnamon.  

## A Bigger Trend?

I think it's interesting that my common reason for switching tools/web platforms/operating systems/desktop environments/etc is that the incumbent pisses me off or lets me down.  Rarely is it that the competing products have such compelling features that I jump ship.  Instead the product I'm using moves in the wrong direction.

This reflects my move from the following tools:
* Mandrake -> RedHat -> Gentoo -> Ubuntu -> Arch Linux
* Firefox -> Chrome
* Home Rolled SMTP + IMAP + Thunderbird -> Fastmail
* Tahoe-LAFS -> Cloud Backups (it's complicated)
* GitHub -> GitLab

I've [casually commented this trend in the past](https://twitter.com/2bluesc/status/651938317034852352).  Perhaps this should be `Manna's Law`

    People tend to only look for product alternatives when they are fed up with the current product they are using
