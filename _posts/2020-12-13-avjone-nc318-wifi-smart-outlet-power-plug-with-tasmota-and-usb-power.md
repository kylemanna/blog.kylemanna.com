---
title: "AVJONE NC318 WiFi Smart Outlet Power Plug with Tasmota and 2xUSB Ports"
excerpt: "Flash Tasmota to a AVJONE Smart WiFi Outlet and modify to control USB output"
category: hardware
tags: [esp8266, tasmota, wifi, iot]
header:
  image: https://i.imgur.com/HumrTzf.jpg
  overlay_color: "#000"
  overlay_filter: "0.5"
  overlay_image: https://i.imgur.com/HumrTzf.jpg
---

## Update January 2021:

**Do not buy this and definitely don't modify it as originally described below. It's dangerous as it appears the circuit is wired backwards with USB ground referenced to the AC Hot Line.**

Read the update here: [Danger: AVJONE NC318 WiFi Smart Outlet is an Electrocution and Fire Hazard](/hardware/avjone-nc318-wifi-smart-outlet-power-plug-danger-electrocution-and-fire-hazard/)

## Highlights

[AVJONE NC318 Smart WiFi
Outlet](https://smile.amazon.com/Wifi-Smart-Plug-AVJONE-Premium-Power/dp/B07LGTXK87?) is a unique
connected WiFi smart outlet as it has two USB ports.  The USB ports are handy for powering nearby widgets.  By
default the outlet and the USB ports are switched on and off together.

![AVJONE NC318 marketing image](https://i.imgur.com/HumrTzf.jpg)

The outlet is built around the `PSC-B67-GL` module which includes a Espressif `ESP8266` and Chipsea
`CSE7759B` for energy monitoring. This Chipsea module tends to be more accurate out of the box as it uses
a UART to report the data as opposed to a frequency signal other devices use.

The USB ports are rated for 2.1A max combined at 5V.  I'm slightly skeptical that it can sustain this but
didn't test it.  This design is nice as it leverages a single 5V power supply for both the ESP8266 and an
external device.

The device has two LEDs (one is controlled by software) and a single button.

## Teardown and Internals

Opening the smart outlet is as simple as removing 4 screws from the back.  No guessing and popping or
breaking plastic clips.

The design and build quality of the outlet leaves quite a bit to be desired.  I hope the manufacturer
takes some steps to improve it as it's a in another world compared to things like the UL certified Sonoff
S31 on the power side and the `PSC-B67-GL` module doesn't have an RF shield as most `ESP8266` modules do.
It does have a chip antenna which is harder to screw up based on how hurried and unpolished this board
looks.

![AVJONE NC318 PCB front](https://i.imgur.com/lFhFCZK.jpg)
![AVJONE NC318 PCB back](https://i.imgur.com/0RNefPg.jpg)

## Tasmota 

[Flashing with Tasmota](https://tasmota.github.io/docs/Getting-Started/#flashing) is pretty straight
forward once the module pins are identified, and jumper wires soldered on.  See the image below for
labels of the essential pins.  I tested on Tasmota v9.1.0.

![PSC-B67-GL module pin labels](https://i.imgur.com/bXzhLnh.jpg)

The `RX` pin (from the perspective of the `ESP8266`) is shared with the Chipsea `CSE7759B` using a series
resistor to allow UART programming of the `ESP8266` to drive the line for programming. This confused me
for a while as I thought I had `TX` and `RX` backwards.  The bit rate to the `CSE7759B` is very low and
the signal is attenuated as a result of this resistor should you get stuck and hook up an oscilloscope.

The template is based off the Sonoff S31 as it uses the same `ESP8266` and `CSE7759B`.  I'm sure other
variations work as well.

```json
{"NAME":"AVJONE NC318","GPIO":[32,3072,225,3104,0,0,0,0,224,321,0,0,0,0],"FLAG":0,"BASE":41}
```

![Tasmota template live on the device](https://i.imgur.com/RDau2Sy.png)

This should be enough to make the outlet work.

**Note**:`Relay 2` and `Ledi_i 2` are to enable USB control after re-work.  Without the re-work they will
not serve any purpose.

## Rework to Support USB Power Control

The PCB can be re-worked by adding a simple jumper wire and re-using the existing resistor to allow `GPIO2` to
independently control what appears to be a P-channel MOSFET that controls the flow of power to the USB
Type-A connector ports. The 5V power supply is always on as it powers the `ESP8266`.

The signal path should be `ESP8266 GPIO2` -> `PSC-B67-GL` module -> re-used resistor -> re-work wire -> `R36`/`R37` pad -> P-channel MOSFET gate.

Steps to re-work:

1. Remove the resistor on `R36` or `R37`, save the resistor for use later.
1. Connect a jumper wire to one or both of the pads as shown in the picture below.
1. Connect the resistor to module as shown so it will be in series with the re-work wire.
1. Attach the remaining end of the wire to the re-located series resistor.

![AVJONE NC318 USB control rework front](https://i.imgur.com/RqThj1z.jpg)
![AVJONE NC318 USB control rework back](https://i.imgur.com/oIxLFqM.jpg)

At this point the Tasmota tempalte shared above should toggle the MOSFET using the `Relay 2` control in
Tasmota.

## Final Steps

As always, [perform Tasmota
calibration](https://tasmota.github.io/docs/Power-Monitoring-Calibration/).  I use a 40W incandescent
light bulb and a Fluke 187.

After this is complete I use this device for control control with MQTT and Home Assistant and logging
with InfluxDB and Grafana.

![AVJONE NC318 Tasmota Web UI](https://i.imgur.com/rzoc86Z.png)
