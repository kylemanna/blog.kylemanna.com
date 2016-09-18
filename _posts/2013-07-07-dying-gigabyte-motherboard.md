---
title: "Dying Gigabyte Motherboard"
tagline: "Too red"
category: hardware
tags: [hardware, failure]
---

Long Time Coming?
=================

For a few weeks, the monitor plugged in the DVI port of the on-board graphics would sometimes fail to turn on after entering power saving mode.  I thought it was a buggy kernel driver and hoped a kernel update would fix it.  At times I would also noticed that my old Dell 2007FH would become unresponsive, as if it had crashed.  Power cycling the monitor resolved the issue.  Fun, a monitor that crashes?!

In every case the monitor would resolve itself after I power cycled it.  Time for a new monitor after I move to my new apartment right?  Not so fast...

<img src="http://i.imgur.com/q90GXWL.jpg"/>
<img src="http://i.imgur.com/mtGgN6V.jpg"/>

Next Level of Broken
====================

This weekend my *bad* monitor (plugged in the motherboard's DVI port) presented a new problem where the screen had red noise everywhere.  I immediately suspect the DVI cable (the cable that hasn't been touched in 7+ months) and replace it with another.  Same problem.  I swap the monitor over to the HDMI-&gt;DVI cable (HDMI port on motherboard, DVI on monitor) that was power the other monitor and the problem goes away.  I plug the *bad* DVI-&gt;DVI cable in to the *good* monitor and now it's *bad*.  Clearly eliminated the monitor to blame as the same input produces a perfect picture when coming from a different output.  I also think it's unlikely for two DVI monitor cables to spontaneously go bad.


Blame the Motherboard
=====================

I'm now blaming my Gigabyte Z68MX-UD2H-B3 motherboard.  I bet the HDMI transmitter, traces leading to or from it, or the connector itself has gone bad.  I checked the connector for debris (the kind that crawls in the connect while something is plugged in &lt;/sarcasm&gt;).  Tried wiggling the connector looking for a bad solder joint.  Nothing.

As a last hope, I went to the BIOS and reset everything to "Optimized Defaults" + AHCI and still no love.

Maybe the mysterious P13VDP buffer near the HDMI connector is to blame.

<img src="http://i.imgur.com/Gj0Zz7B.jpg"/>


Next Steps
==========

The motherboard is still under warranty with Gigabyte.  I'm going to attempt an RMA, but already have little faith.  I have a very pessimistic outlook on customer service these days. Hopefully they'll prove me wrong.

An RMA request has been submitted to their website yesterday, let's see what happens.


What Else Could Be Broken?
==========================

With the graphics on-board the CPU (Intel i5-2500K), it's possible that the processor is the source of the problem.  I'm assuming the processor outputs a parallel RGB type video signal where the signal is then fed to a HDMI/DVI/DP transmitter and serialized.  But maybe I'm wrong, maybe Intel put the transmitter in the chip to save pins.

Intel usually gets things right, everyone else, not so much.


Questions
=========

* Does anyone know the type of video signal outputted from the processor? Parallel RGB, serialized HDMI, etc?
* Has anyone experienced this problem before?
* Has anyone dealt with Gigabyte's RMA process?
