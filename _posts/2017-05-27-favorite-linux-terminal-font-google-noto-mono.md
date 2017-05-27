---
title: "My Favorite Linux Terminal Font: Google Noto Mono"
excerpt: "Terminus font doesn't quite look right with desktop scaling and 4K UHD displays."
category: cli
tags: [programming, font, cli, terminal, google, tmux, linux, monospace]
header:
  image: https://i.imgur.com/aJ9awXn.png
  overlay_color: "#000"
  overlay_filter: "0.5"
  overlay_image: https://i.imgur.com/aJ9awXn.png
---

## Monospace Before and after 4K UHD

For years I've spent the better part of my day staring at terminals for my day to day work.  I've used [GNOME Terminal](https://en.wikipedia.org/wiki/GNOME_Terminal) with [Terminus font](http://terminus-font.sourceforge.net/) for years without issue on 1600x1200 and 1080p displays.

Recently I bought two [LG 27UD58 monitors](http://www.lg.com/us/monitors/lg-27UD58-B-4k-uhd-led-monitor) for my desktop and swapped out my laptop display with the 4K UHD display offered by Dell as UHD slowly stole my heart with its sharpness and increased screen real estate.

Immediately the ability to scale the UI in GNOME became important and the Terminus font quickly looked odd and felt uncomfortable.  I could never find a font size that felt natural like Terminus did for years before UHD.

I dug around the web reading various blog posts about monospace fonts, but none of the popular fonts quite felt right.  I always installed [Google's Noto fonts](https://www.google.com/get/noto/) to handle international characters on [Arch Linux](https://www.archlinux.org/packages/extra/any/noto-fonts/) but never gave it much more thought for anything beyond web page rendering.

## Enter Google Noto Mono Regular

One day while wrestling with the awkward font sizes in GNOME terminal I stumbled on [Noto Mono](https://www.google.com/get/noto/#mono-mono) and instantly fell in love.  I can't remember if I was on my desktop or laptop when I first discovered the font, but I quickly reviewed the font on the other machine and was delighted.  The font looked amazing on both machines at size 11.  Not too tall, not too wide and nothing weird.

After a few months of running this font, I figured it's now my turn to share with the world so this underrated font gets some more attention.  That said, [go check it out](https://www.google.com/get/noto/#mono-mono).

## Screenshots

To try and demonstrate the differences of the font, I setup a series of GNOME terminals with a simple directory listing of the Linux kernel that I had lying around on both my machines in the default terminal size of 80x24 for comparison.

The comparison isn't representative of how I normally use my computer, but highlights the differences between the fonts on the same screen.  Typically I tile windows like the web browser and data sheets and dedicate one monitor to a full screen tmux session on dual display setups or a virtual desktop when using my laptop and within tmux I tile the panes to my heart's content.

That said, this isn't about terminal productivity setups, it's about monospace fonts.  So, see below for font setups on my desktop and laptop.

### Dell Precision 5510 UHD Display

[![Dell Precision 5510 UHD font comparison](https://i.imgur.com/aJ9awXn.png "laptop font comparison")](https://i.imgur.com/aJ9awXn.png)

* Top left: Noto Mono 11
* Top right: Terminus 12
* Bottom left: Terminus 11

On the laptop Terminus felt too "tall" or too small. I could never get the balance right.  The difference based on font size of the `❯❯❯` characters in my terminal also bothered me.  Noto Mono is better on all fronts except it lacks the "slash" through the zero character for disambiguation with "O" character (`0` vs `O`).  But, typically my brain fills seamlessly fills in the context when reading, so it doesn't bother me much.


### LG 27UD58 UHD Display

[![LG 27UD58 UHD Display font comparison](https://i.imgur.com/2tVJu7R.png "desktop font comparison")](https://i.imgur.com/2tVJu7R.png)


* Top left: Noto Mono 11
* Bottom left: Terminus 13
* Top right: Terminus 11
* Bottom right: Terminus 12

Similar comments as the laptop, but on the desktop but Noto Mono 11 has a little more width to the fonts making them easier to read.  Also, note how dramatically the different the font sizes are with Terminus.  On the laptop and desktop Noto Mono looks perfect at size 11, but Terminus needs to be about size 11.5 on the laptop and size 13 on the desktop.  Why the size discrepancy if I have the desktop scaled to about the same visual settings for everything else?  Well, it probably has to do with Terminus being a "fixed width bitmap font" and doesn't scale well.  I don't know much about fonts, but it sounds like it was designed to be pixel perfect on certain displays, but with the proliferation of 4K UHD this isn't quite necessary or appropriate anymore.  That's just my guess though, I'm not a font guy.

## Favorite Font

I don't consider myself a font obsessed person and my subjective requirements are simple: I want a font that is easy to read and not distracting on my desktop or laptop with simple licensing (for easy distribution).  Terminus was that font for years, but does not work well with UHD and desktop scaling.  Google's Noto Mono font now fits the bill.  Looking back on it, I may have used Noto Mono in place of Terminus years ago had it existed and I merely discovered it first.



