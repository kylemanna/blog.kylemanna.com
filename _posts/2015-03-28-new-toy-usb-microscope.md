---
layout: post
title: "New Toy: USB Microscope"
tagline: ""
category: hardware
tags: [microscope, usb, pcb, hardware, alibaba, aliexpress]
---
{% include JB/setup %}

## The Expectation

Picked up a cheap $15 USB microscope from AliExpress.  The posting claimed it would do 5MP.  I was skeptical (i.e. USB 2.0 bandwidth constraint) and figured it would realistically do 1600x1200 resolution or 2MP.

## The Result

Upon receiving it and hooking it up I was delighted to see that it just worked out of the box with Linux.  I tried VLC, Cheese, and Guvcview to manage it.  I'm going to stick with Guvcview as it seems to have an easier to use interface and seems to have slightly lower latency.

The bad part is that it only appears to do 320x240 and 640x480... or 0.3MP.  What?!  Well, the seller is getting a bad rating on Alibaba should there not be some way to get to at least 2MP.  I dumped the USB descriptors in [GitHub Gist](https://gist.github.com/6d96540ff9ee56dd138a) for those interested in what not to buy when looking for 2MP/5MP camera.  In a nutshell, the USB VID:PID = `0ac8:3420`.

Despite being only 0.3MP, the pictures are actually quite *amazing*.  I uploaded some quick shots of stuff lying on my desk to my [Google+ Image Gallery](http://bit.ly/1G3zdYR).

Select shots:
![USB Micro connector](https://lh5.googleusercontent.com/-7KqnMAL9X_U/VRdGl7Ytm3I/AAAAAAAAaO4/dPN49tvyDPI/w640-h480-no/my_photo-5.jpg)
![Inside an LED](https://lh5.googleusercontent.com/-mBN9mo19n8E/VRdDwtMUchI/AAAAAAAAaNc/zcsnO_LahEQ/w640-h480-no/my_photo-7.jpg)


## Conclusion 

I'll use it for sure, just pissed off about a mis-represented product on Alibaba.  Sigh.
