---
title: "Danger: AVJONE NC318 WiFi Smart Outlet is an Electrocution and Fire Hazard"
excerpt: "Do not use this device, it's dangerous"
category: hardware
tags: [esp8266, tasmota, wifi, iot, fire, fail]
header:
  image: https://i.imgur.com/f7HwcYO.png
  overlay_color: "#000"
  overlay_filter: "0.5"
  overlay_image: https://i.imgur.com/f7HwcYO.png
---

## Danger

**tl;dr; Do not buy this! At minimum this will damage devices connected to it.  At worst it could hurt
somebody or start a fire.**

It appears the USB shield and USB ground is directly connected to AC mains line voltage.  This means the
outer shell of any USB connected cable is connected to mains voltage which is 120 VAC in the United
States.  The cable can electrocute you if you touch the other end (any metallic part exposed of any USB
cable) and are even slightly grounded (i.e. feet on damp concrete floor).

If you're lucky, it will only destroy inanimate objects on the path to ground when connected to any other
properly designed device. This happened to me. Read below for the story.


## Update 2021-01-31

A few weeks after posting this I was contacted by Willi Hilgers from Germany who had seen this post and
measured his version of the outlet to confirm the same problem!

See photo of the German version from Willi Hilgers below:

![Photo of similar outlet showing 230VAC on USB shielding!](https://i.imgur.com/OqLEFRe.jpg)

This confirms my suspicions and dismisses my concerns that my modification caused this issue.
Thanks for sharing!  I can rest better knowing I didn't directly cause this safety hazard, but still am
disappointed I didn't measure this out of the box. Live and learn.

Original post follow.


## Perhaps I Caused This?

In an [earlier post](/hardware/avjone-nc318-wifi-smart-outlet-power-plug-with-tasmota-and-usb-power/) I
described a way to modify the circuit to control the high side USB MOSFET that supplies 5V to the USB
connector from the microcontroller.

There's a chance that I misunderstood something in the circuit and bridged high voltage side to low
voltage side and created this dangerous situation.  In reviewing my notes I'm confident that my
understanding was and still is correct. If I was wrong I'd expect the circuit to have instantly smoked or
for the re-worked wire to show damage from the short circuit situation that was created and descrbied in
the following section.

The only way to learn more would be to find a new un-modified circuit to confirm this by making the same
measurements shown below with the device fully assembled.

Unfortuantely, these outlets are no longer listed on Amazon. On the product page I ordered from is now a
similar shaped outlet without the USB ports.  Perhaps the discontinuation of this product is the most
confirmation of an original design flaw I'll ever get.

I'd like to get closure to know with certainty whether I misunderstood something and made the device
dangerous or if it was designed dangerous and failed to check this while investigating it in my earlier
post.  Eitherway, something to be learned here is to be careful with mains AC powered items.


## Learning the Hard Way

I've been working on a project to build a
[HDMI-CEC](https://en.wikipedia.org/wiki/Consumer_Electronics_Control) and
[HDMI-ARC](https://en.wikipedia.org/wiki/HDMI#HDMI_Ethernet_and_Audio_Return_Channel) digital audio
amplifier to replace my overkill, power hungry, and buggy AVR for my stereo TV setup.

The prototype matured to a stage where it was ready to be tested with my TV.  The TV and USB devices in
this setup were connected to this dangerous outlet.

See the block diagram below for an overview of how things were connected:

![Prototype block diagram](https://i.imgur.com/eIGFkbC.png)

The short circuit occurred the moment I attempted to connect the USB cable between my Khadas VIM3L (which
was plugged in and running) and the Khadas Tone DAC which was connected to the Topping MX3 audio
amplifier via RCA cables (MX3 was powered and running).

This USB cable, which is expected to have nothing more then 5V on it, sparked upon touching the outer
housing of the USB connector of the DAC. This instantly flipped the 15A circuit breaker.  At this moment
I was shocked as to how a 5V USB connector (expecting 5W at most) could flip a 1800W circuit breaker.

Aware that something just went *very wrong* I made sure to take a mental note of what I was doing and
what was connected.  Disconnected all the devices in the block diagram and reset the circuit breaker.


## Diagnosing the Design Flaw

Working backwards (in a now much safer, more controlled environment since this was clearly hazardous)
from the USB connector I quickly learned that 120V was present on the connector.

First observation is that the USB shield is directly connected to the AC mains hot line with less then 1Ω
of resistance.  **This is clearly designed wrong**.  The shield should be connected to ground or at
worst case neutral.  This is how every other device is designed when not fully isolated.

The safety protection of the USB outlet is effectively shorted to the hot line of the AC outlet.  This is
the opposite of safe.


### Resistance between USB shield and AC outlet

![Short between USB shield and AC Hot](https://i.imgur.com/qYWcrko.jpg)

Quick measurement shows that there's only 0.35Ω of resistance between AC Hot and the shield of the USB
connector.  I'd hope this would be at least 1MΩ.

![1 MΩ between USB shield and AC Neutral](https://i.imgur.com/rFe7oHb.jpg)

The resistance of the others shows that neutral line is 1 MΩ of resistance to the USB shield.

![Infinite resistance between USB shield and AC Ground](https://i.imgur.com/6OC7qRH.jpg)

AC Ground is effectively not connected to the USB shield.

### Resistance between USB power/ground and AC outlet

Using a USB charging cable with a magnetic end made it easier to probe +VBUS and GND on the cable.  The
outer ring is attached to USB GND and the inner pin is USB VBUS.

![Short between USB GND and AC Hot](https://i.imgur.com/v5oeo48.jpg)

Short (less then 1Ω) between AC Hot and USB GND.

![340Ω from AC Hot to USB VBUS](https://i.imgur.com/2Oktw5W.jpg)

There was 340Ω of resistance from AC Hot to USB VBUS.

![1MΩ from USB VBUS to AC Neutral](https://i.imgur.com/NhmNNzJ.jpg)

1MΩ from USB VBUS to AC Neutral.

### Live Dangerously

I confirmed the resistance measurements by measuring voltage while the dangerous switch is plugged in.
This was probably not a good idea in hindsight based on the proximity of fingers to the now known high
voltage design flaw.

![0V from USB GND to AC Hot](https://i.imgur.com/8cI3sCr.jpg)

0V from USB GND to AC Hot.  This means the line is at 120 VAC (relative to Neutral) as there's no voltage difference.

![120 VAC from USB GND to AC Neutral](https://i.imgur.com/Leh1zK2.jpg)

120 VAC from USB GND to AC Neutral.  This is very bad and unsafe. I probably shouldn't be so close to
touching this.

![Not even ground is safe](https://i.imgur.com/OcMRuhp.jpg)

USB GND to AC Ground is also 120 VAC.  Again very dangerous. 


## Collateral Damage

The collateral damage from this innocent setup was:

* Topping MX3 has two blown ferrite and shorted capacitor at minimum preventing it from working.  I
  assume these ferrites connected the RCA ground to the ground from the AC-DC power supply which in turn
  connects ground to the AC Neutral line.  This was the weakest link in the inadvertent short.

  ![Damage to Topping MX3](https://i.imgur.com/wcQfjVK.jpg)

  I think I can repair this poor amplifier.

* JBL Link 10 which was an innocent (yet historically flaky) bystander in all this stopped working,
  drained it's battery and hasn't powered up or charged since.  No dangerous currents flowed near this
  thing. At worst it experienced a voltage transient.  I assume this device was just poorly designed.
* Magnetic USB connector used to make the connection (RIP).

Surprisingly, the sensitive Khadas VIM3L single board computer and Khadas Tone Board DAC survived
unscathed (as far as I can tell) despite each experiencing instantaneous current of roughly 15A traverse
their ground paths. 

## Conclusion

This AVJONE NC318 WiFi Smart Outlet is bad news, avoid it.

There's a chance that my earlier modification caused an unexpected side effect of bridging low voltage
to high voltage in my post about [flashing Tasmota and modifying it to control the USB
ports](/hardware/avjone-nc318-wifi-smart-outlet-power-plug-with-tasmota-and-usb-power/).  However
unlikely I think that is, I can't say with certainty.

I fear I'll never know, and if they're no longer on sale hopefully nobody else has to find out either.
