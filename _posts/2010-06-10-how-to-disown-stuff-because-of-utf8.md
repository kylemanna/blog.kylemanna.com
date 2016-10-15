---
title: "How to disown stuff because of UTF-8"
excerpt: "What's this disown shell command you speak of?"
category: linux
tags: [gentoo, utf-8, cli]
---

## How'd I Get Here?

I've been uploading files to [DreamHost](http://bit.ly/2e9Zgop) for a two days now, and duplicity just purrs away in my `gnome-terminal` shell doing what it does, out of sight and out of mind. However, one day I reallllly wanted to fix the annoying encoding default of `ANSIX3.4-1968` `gnome-terminal` on my Gentoo machine.

After some research I learned that I needed to tweak some environmental variables and restart my gnome-terminals as they all run as one process it seems. I could test this out by setting `LANG=en_US.UTF-8` and running `gnome-terminal --disable-factory` causing it to start a new process. Perfect, now I can fix everything. I dug through my init scripts and found that on Gentoo gdm (aka xdm in someplaces) sets the `LANG` variable that gets inherited down stream. I made an `/etc/env.d/02locale` file with the following:

    LANG=en_US.UTF-8
    GDM_LANG=en_US.UTF-8

I ran `env-update` and all I needed to do was reload gdm and log back in.

Not quite that easy as I still have this duplicity process running and was approaching halfway at 2 days. If I had been smart when I started the backup I would have ran it in `screen` and just detached the `screen` session and let it run in the backgound, but I wasn't.

There had to be a way to change the parent of the process I thought, and after some googling I discovered the bash `disown` function. Awesome. Apparently I could change the parent of the running processor so it wouldn't close when I closed the terminal and subsequently my X session. So I opened the gnome-terminal running duplicity, CTRL+Z to stop the process, then I ran `bg` to background it in that terminal, and then I ran `disown`, and bam, its parent had changed to the init process as viewed by `pstree` success. Restarted my X session and it was still happily uploading away.

Now I know how to `disown` my computer and am no longer frustrated by UTF-8 and gnome-terminal.
