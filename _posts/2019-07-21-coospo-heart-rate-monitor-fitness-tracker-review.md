---
title: "CooSpo Heart Rate Monitor (HRM) Fitness Tracker Review"
excerpt: "Only because Garmin can't build a HRM that lasts"
category: fitness
tags: [health, running, fitness, biking]
header:
  image: https://i.imgur.com/dNnmjIa.jpg
  overlay_color: "#000"
  overlay_filter: "0.5"
  overlay_image: https://i.imgur.com/dNnmjIa.jpg
---

## Garmin Products Live Short Lives

My first Garmin product was a [Forerunner 305](https://amzn.to/2JZ9Qiv) and I purchased it in 2009 when I bought my first road bike.  The adhesive holding the face and backshell failed (blame Texas heat) causing the face to separate from the body. I was able to re-epoxy it one or twice, but each time the buttons became harder to use as a result of epoxy going places it shouldn't.  Somewhere along the way the charging contacts became increasingly corroded from sweat (also blame Texas heat) and I was able repair them, but it was finicky to charge for the rest of its life.  Finally, the watch entered retirement in 2014 as expected when the battery degraded to the point it wouldn't support my longer weekend rides.  The included [Garmin HRM1 (010-10997-00)](https://amzn.to/2YqohFX) outlasted the watch needing only a few battery replacements.

Next up was the [Forerunner 310XT](https://amzn.to/2JW5IQA).  This watch had improved on all my previous complaints: improved button feel, improved GPS signal reception, and a revised more comfortable HRM, and an improved (still clumsy) ANT+ synchronization USB dongle.  Five years of progress yielded a better product.  However, this watch's life was abruptly terminated in 2017 by a silly failure: the plastic wristband pin boss failed making it impossible to retain the wristband.  The later generation [Garmin HRM3 (010-10997-07)](https://amzn.to/2LywJfZ) outlasted the watch it was sold with needing only a battery replacement or two.

Currently I own a [Forerunner 920XT](https://amzn.to/2JTLCX2).  This watch like the watch before it improved on features again: the buttons were even better, the watch now seamlessly synchronizes with Garmin Connect using BLE to my phone and sometimes WiFi, and the wristband bosses are substantially larger. So far this watch has been pretty painless with the exception of some WiFI issues (easily overcome by letting it use BLE to upload via my phone).

The latest [Forerunner 920XT](https://amzn.to/2JTLCX2) ships with a [Garmin HRM4-Run (010-10997-12)](https://amzn.to/2SwKBbb) which has the nicest band by far. But, that's where the fun ends. This thing is a train wreck.

## Garmin Heartrate Monitors

The [Garmin HRM4-Run](https://amzn.to/2SwKBbb) included with the Forerunner 920XT died in less then 2 years.  It appeared as if the battery was dead, but even after replacing the battery the device would only work for a few workout sessions before killing the new battery.  It seems as if sweat has entered the device and corroded something that now conducts and discharges the battery prematurely.

But I can't be the only one with this problem, right? Nope, many Amazon reviews have the same issue:
![Sad Amazon Customer Review #1](https://i.imgur.com/NA5UK28.png)
![Sad Amazon Customer Review #2](https://i.imgur.com/L2I0zvq.png)
![Sad Amazon Customer Review #3](https://i.imgur.com/ULXV32b.png)
![Sad Amazon Customer Review #4](https://i.imgur.com/XiLT76m.png)

Right.

Good thing I have the old [Garmin HRM3](https://amzn.to/2LywJfZ) from my [Forerunner 310XT](https://amzn.to/2JW5IQA), right?  Well that lasted a few months before flat out dying as well.  Two Garmin HRMs down in only a few months after years of service.

Should I dig up the oldest, longest running [Garmin HRM1](https://amzn.to/2YqohFX) that's nearly a decade old, give Garmin more money for a replacement, or try something else?

Let's try something else.

## Enter CooSpo

I got the inspiration to try something else when I was reminded that any [ANT+](https://en.wikipedia.org/wiki/ANT_(network)) HRM would work.  After some poking around on Amazon I stumbled on the [CooSpo Fitness Tracker from Amazon for less then $40](https://amzn.to/2XWHXBP) which incorporates ANT+ and BLE.  The reviews suggested that the device would work with Garmin devices and the BLE would work directly with my phone should I want it. I took the plunge and ordered a device with no obvious model number on the product page.

![CooSpo HRM808S with chestband](https://i.imgur.com/fx0gtMz.jpg)

Features:
* ANT+ works fine with my Garmin Forerunner 920XT
* BLE works with Strava and various applications on my Android Google Pixel 3
* LED illuminates and beeps when I put the HRM on signaling it's working

Appears to be called "HRM808S" according to the "Model Number String" in the BLE profile for Device Information with firmware version "v5.0.19".

Screenshots of BLE info:
![BLE Screen #1](https://i.imgur.com/Asv9rXV.png)
![BLE Screen #2](https://i.imgur.com/ntwbN2h.png)
![BLE Screen #3](https://i.imgur.com/ykxaDlG.png)

## Certification

I could't find any FCC ID markings on the device. Also couldn't find them "CooSpo" [listed in the ANT directory](https://www.thisisant.com/directory). This seemed odd.

A representative at the company quickly replied when contacted via the email address on their website saying that the FCC ID is under their contract manufacturer's name "Shenzhen Fitcare Electronics Co., Ltd".  I was able to find a [document](https://fccid.io/2ACN7-HRM803S/Test-Report/Test-Report-DTS-4061228.pdf) mentioning the "HRM808S" as an additional model of the "HRM803S" which has FCC ID `2ACN7-HRM803S`.  Looks like it passed the certification process without issue.

Digging deeper, there is a "Fitcare Electronics" listing in the ANT directory, but not this model. The CooSpo representative said that ANT is slow to update their directory, so maybe it will show up there soon enough?

The CooSpo HRM808S device looks very similar to the ["HRM812" on Fitcare's website](http://www.fitcare.cn/product/detail/36.html).

### Outstanding Questions

What's the actual model of this product? There's no product / model number on the [Amazon Product Page](https://amzn.to/2XWHXBP) and there's nothing on [CooSpo's own website](http://www.coospo.com/) at the time of writing (July 2019).  Searching Google for "HRM808S" or "H808" yields nothing.  This is a ghost product that works amazingly well.

Will it last? I'll be sure to update this page with tears when it dies, hopefully it lasts more then 2 year unlike my Garmin HRM4.

Even if it only lasts 1 year, it's still a better value then a replacement Garmin HRM4-Run.
