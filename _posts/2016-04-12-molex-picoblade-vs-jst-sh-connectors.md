---
title: "Molex PicoBlade vs JST SH Connectors"
description: ""
category: hardware
tags: [hardware, connectors, picoblade]
---

## Connector Hunt

I wanted a small pitch connector series to use on a new project.  In the past I had used hacky solutions along the lines of 2.54mm and 1.27mm breakaway headers and wanted something more robust with positive retention.  In theory I only need board to wire, but more options would be nice.  Max current of 1A, max voltage of 16V and crimpable for prototype work.

The JST SH series hit all my requirements and were available in surface mount package.

## Initial Concerns

I was initially concerned about the terminals being too small to work with for prototype work.  I dug around the Internet and found some people saying they were too small and a few saying they were workable with the [$40 Engineer PA-09](https://www.amazon.com/Engineer-PA-09-Micro-Connector-Crimpers/dp/B002AVVO7K) from Amazon.  For the price I figured why not.  So I took the plunge, ordered the crimp tool and made my boards to use the JST SH surface mount connectors.

And then reality caught up with me

## Engineer PA-09 Crimp Tool

First, this connector works fine for many connectors, but not the 1 mm pitch JST-SH connectors.  It would crush the terminal conductor crimp fingers.  I'd then have to rotate the terminal 90 degrees to crush back to a size that would fit int he JST SH housing.  And when it didn't fit, it would crack the plastic dividers separating the terminals in the housings.

I wasted 20+ terminals trying to crimp 7 wires, which then failed later.  Double fail.

## Search for an Alternative

I poke around the Internet and stumbled on the [Molex PicoBlade 1.25 mm series](http://www.molex.com/product/picoblade.html) before getting confirmation from a few friends that used them without issue.  A friend had the very nice and [$300  Molex crimper #63819-0300](http://www.digikey.com/product-search/en?keywords=WM9984-ND).  And the crimps were perfect.  Not exactly surprising given the fact that the crimper is 10x the price.  That said, the only crimp tool for the JST SH connectors I could find was the [YRS-850 for $1100 on Digi-Key](http://www.digikey.com/product-search/en?mpart=YRS-859&vendor=455).  Forget that.

## Bonus

After adopting the PicoBlade I fell in love with them for a number of other reasons:

* Through hole *and* surface mount receptacles. JST SH are surface mount only.
* Wire gauge of 26-32 AWG vs 28-32 AWG.  Finding [26 AWG stranded wire](https://www.amazon.com/Remington-Industries-26UL1007STRKIT-Stranded-Diameter/dp/B00N51OOJE/) is considerably easier when [prototyping](https://www.adafruit.com/categories/472).
* Pre-crimped wires in two lengths to skip crimping all together.  These appear harder to source then the rest of the series components.
* Optional wire-to-wire housings.
* Visibly larger contact area for slightly higher current handling and perhaps better reliability.
* Feel less fragile when unplugging.
* Not that much bigger despite being 1.25mm vs 1mm pitch.
* Can sample some parts and stocked by both Digi-Key and Mouser as opposed to no samples and only stocked at Digi-Key.

## Glamour Shots

I took some quick pictures of my JST SH <-> Molex PicoBlade adapter.

[![Connector Image](https://i.imgur.com/4OgHyJ5l.jpg)](https://imgur.com/a/VqOvI)

[Checkout the Imgur image gallery](https://imgur.com/a/VqOvI)

## Update: 2016.10.15

Molex has expanded their offering to now offer [Molex PicoBlade Connector Assemblies](/hardware/molex-picoblade-connector-cable-assemblies/) to further enhance their offering for low volume prototype and production products.
