---
title: "Sniffer Air Quality (AQI) Monitor using ESP32 + PMSA003 + BME680"
excerpt: "Monitor indoor or outdoor air quality index (AQI) with a Sniffer"
category: hardware
tags: [wildfire, aqi, esp32, irl, pmsa003, bme680, pcb, hardware, pcbway, bme280]
header:
  image: https://i.imgur.com/OBUTO4k.jpg
  overlay_color: "#000"
  overlay_filter: "0.5"
  overlay_image: https://i.imgur.com/OBUTO4k.jpg
---

## California Wildfires and My Home

The San Francisco Bay Area has been blanketed with wildfire smoke from record setting wildfires creating
strange phenomena such as turning the sky an [orange-red for a
day](https://www.cnn.com/2020/09/09/weather/california-orange-skies-wildfires-photos-trnd/index.html).
In response to an ever rising [air quality index (AQI, where higher value is less
healthy)](https://en.wikipedia.org/wiki/Air_quality_index) I've been forced to stay indoors and abandon my
normal bike rides, runs, and motorcycle adventures. 😞

With nothing better to do and curious about the air quality in my home I've been watching [PurpleAir's
local sensor data in my
neighborhood](https://www.purpleair.com/map?opt=1/mAQI/a10/cC0#9.22/37.7226/-122.1704).  PurpleAir is a
company that sells [consumer grade air quality
sensors](https://www2.purpleair.com/collections/air-quality-sensors) for about $250 and then publishes
the data to their site giving localized information.

AirNow.gov has [launched a site](https://fire.airnow.gov/?lat=37.7552896&lng=-122.38848000000002&zoom=10) that combines regulatory grade sensors and PurpleAir sensors to give a better picture.  The [SF regulatory sensor](https://ww3.arb.ca.gov/qaweb/site.php?s_arb_code=90306) is located in Potrero Hill and has [data available via CSV](https://www.arb.ca.gov/aqmis2/display.php?report=SITE31D&site=2373&monitor=-&year=2020&mon=09&day=20&param=PM25&units=001&statistic=HVAL&ptype=aqd&o3switch=new&hours=all) for those interested, but the data is not as easy to ingest as PurpleAir's API and lags behind up to an hour.

All that said, there's plenty of data about outdoor air quality, but not a good way to measure and track
the indoor quality at my home or better yet determine if my Winix P150 air purifier helps the situation.

There must be a way to collect this data, save it to InfluxDB, and plot it with Grafana with a little
hardware.


## Exploring Hardware Sensors

The core of assembling some hardware to measure air quality is to measure the concentration of
particulate matter in the air measuring smaller then roughly 2.5 μm in diameter.  This is commonly
referred to as ["PM2.5"](https://www.epa.gov/pm-pollution/particulate-matter-pm-basics) and the
concentration is a measure of mass with the units of μg/m³.  This is then converted to the [Air
Quality Index ("AQI")](https://en.wikipedia.org/wiki/Air_quality_index) everyone references.

To measure the PM2.5 concentration there are may techniques ranging from costly to cheap. Regulatory
sensors use methods such as as [beta attenuation
monitoring](https://en.wikipedia.org/wiki/Beta_attenuation_monitoring), but hosting a radioactive source
seems dangerous and cost prohibitive for my passing interest in monitoring AQI.  More accessible sensors
use a principle of [dynamic light scattering](https://en.wikipedia.org/wiki/Dynamic_light_scattering) to
measure the size of PM1, PM2.5, and PM10 particles.

The PurpleAir sensors use two [PlanTower PMS5003 sensors](http://www.plantower.com/en/content/?108.html)
for what I assume is fault tolerance (apparently not good enough as the PurpleAir sensor at UCSF seems to
be failing accordingly to the data and sporadic readings).  There have been some tests ([field
evaluation](http://www.aqmd.gov/docs/default-source/aq-spec/field-evaluations/purple-air-pa-ii---field-evaluation.pdf?sfvrsn=4)
and [laboratory
evaluation](http://www.aqmd.gov/docs/default-source/aq-spec/laboratory-evaluations/purple-air-pa-ii---lab-evaluation.pdf?sfvrsn=4))
showing that the sensor performs pretty well, especially for the cost.  Turns out there are a few
generations of the PlanTower products starting with the PMS3003, newer versions PMS7003, PMS1003 and with
PMSA003 being the newest.

The PMSA003 sensors can be bought on AliExpress for less then $20 each and roughly [$35 via Amazon third party
sellers](https://smile.amazon.com/dp/B082B8R29B). This is a very approachable price compared to what I feared.

I selected a TTGO ESP32 T-Display module as it has an ESP32 micro controller (with integrated WiFi for
those not familiar), a USB-C connector (it's 2020 after all), and a small 1.14" LCD display.  All this
for between $8 on AliExpress and ~[$13 through Amazon](https://smile.amazon.com/dp/B07XQ5G279).

Finally, I selected a [Bosch
BME680](https://www.bosch-sensortec.com/products/environmental-sensors/gas-sensors-bme680/) to measure
some interesting environmental parameters including temperature, humidity, pressure, and [volatile
organic
compounds](https://www.epa.gov/indoor-air-quality-iaq/volatile-organic-compounds-impact-indoor-air-quality).
The VOC sensor is novel and returns a "gas resistance" measurement using a 320°C hot plate within the
sensor, but I struggle to make much sense of the output.  Seems that higher resistance is lower VOC
concentration.  There's a driver from Bosch on [Github](https://github.com/BoschSensortec/BME680_driver),
but I haven't looked any closer at it.  This sensor is kind of expensive when compared to the BME280
where the only difference appears to be the absence of the gas resistance sensor which has limited
utility for my use.


## Software Options

The sensor emits data using a 9600 bps UART at regular intervals and seems to require no actual
configuration to start emitting data.

For platforms to build on, I want to use an ESP8266/ESP32 so that I can leverage platforms like [Tasmota](https://tasmota.github.io/docs/) (which
I've used in the past for IoT things) and [ESPHome](https://esphome.io/index.html) (which I've been looking for an excuse to use).

Tasmota has a basic driver for the
[PMS3003, PMS5003, and PMS7003 sensor](https://github.com/arendst/Tasmota/blob/master/tasmota/xsns_18_pms5003.ino).  I didn't dig any deeper then this as Tasmota primarily targets ESP8266 platform and I wanted to use an ESP32 as it's more capable for only a small price increase.

I learned that the ESPHome has support for the [PMSX003
platform](https://esphome.io/components/sensor/pmsx003.html) and my search halted there as ESPHome also
has great ESP32 support.

Starting in ESPHome v1.15.0 [support for the ST7789V LCD controller was
added](https://github.com/esphome/esphome/pull/918).


## Prototype

To start I wired up everything by hand. It was a mess. It was fragile and would break if you looked at it
wrong.  But, it worked!

![Sniffer prototype mess](https://i.imgur.com/hG1x8ta.jpg)

The ESPHome software was amazingly easy to use.  I did nothing more then fire up a Docker container to
compile the software and to then flash the device over USB for the first time. All from my web browser, I
have yet to directly touch a compiler for this project. Amazing.

Subsequent updates to re-flash the ESP32 were handled over the air and I never had to plug the device
back in to my computer.

All the device application specific parts of my project are implemented in YAML. Some of YAML ends up as
C++ lambda functions to do the heavy lifting.  The platform abstracts this away and it's easy to forget
it's actually compiled to C++ at the end of the process.

YAML itself is awkward to use for things like inline lambda functions but ESPHome platform is feature
rich enough to justify the clumsy nature of YAML syntax for these things.


## KiCad Schematic and PCB

To take the project to the next level I spent a few hours and put together a KiCad schematic and PCB
design to replace the wires and create some structure.  The PCB mounts the TTGO ESP32 T-Display module on
top with the PMSA003 particulate matter sensor and BME680 are on the back side mostly hidden from view as
it sits on my dresser.

![Sniffer PCB Rendering Front](https://i.imgur.com/3xxddGh.jpg)
![Sniffer PCB Rendering Back](https://i.imgur.com/XGgeu2g.jpg)

The PCB is extremely simple but has some components on it for flexibility if I needed it.  There are
solder jumpers to allow me to easily cut a trace and re-work something if needed, some decoupling
capacitors to smooth out the power supply (again only if needed) and finally some high side P channel
MOSFET that would allow me to turn off the various sensors if I wanted to make this battery powered and
needed more power management.

As of writing, I haven't used any of the extra features. The PCB is a glorified wire replacement back
plane just connecting pins and hold parts in place.  Only work necessary to assemble the PCB is to solder
2.54mm and 1.27mm pin headers using the headers included with the respected modules, no extra pieces
needed.

The design is available on [Github with the project affectionately named
"Sniffer"](https://github.com/kylemanna/sniffer).


## PCBWay

I've used PCBWay in the past to manufacture hundreds and hundreds of boards in the past.  They have an
amazingly smooth online submission process and lots of options to balance PCB technology and cost.

For this project I paid $5 for the 10x boards and $18 for DHL shipping.  I designed and ordered the board
on Friday and the PCBs were in my hand the next Friday.  Faster then expected delivery of a custom design
from across the world during a pandemic.

The gerbers used for the design are on
[Github](https://github.com/kylemanna/sniffer/tree/master/kicad/gerbers) and can also be uploaded to the
PCB manufacturer of your choice.  I tried OSH Park and the renderings looked correct. I didn't select
OSH Park as I'd get fewer boards for more money with a slower delivery time.  The OSH Park boards
had some better properties like ENIG vs HASL plating.

That said, if anyone wants to get PCBs made, checkout the [PCBWay shared project
page](https://www.pcbway.com/project/shareproject/Sniffer_Air_Quality_Monitor.html) that will let you
click "Add to cart" and order 'em with no fuss.

If you do order from PCB Way, check if they offer the [TTGO ESP32 T-Display
module](https://www.pcbway.com/project/gifts_detail/TTGO_T_Display_ESP32_WiFi_and_Bluetooth_Module_Development_Board_For_Arduino_1_14_Inch_LCD.html)
from the gift shop as they did when I ordered my boards for $8/module.

If you want to order from PCBWay please use my [referral code to save
$5](https://www.pcbway.com/setinvite.aspx?inviteid=3549) which I think might make the first PCB order for
you free (before shipping). Someone please let me know in the comments if this is true!

![Sniffer PCBs unpopulated](https://i.imgur.com/djgrSj6.jpg)

## Assembly

The PCB is easily assembled by doing nothing more than soldering the 1.27mm and 2.54 pin headers and
connectors included with each of the components.  No additional parts needed to assemble the Sniffer
electrically.

To finalize the mechanical assembly some fasteners or low profile double side tape (poster tape worked
well) for me to reduce the strain of the PMSA003 on the 2x5 1.27mm header.

I tried some fine pitch M2x5.5mm screws I had on hand to secure the PMSA003, but one hole is too shallow
(screw is too long) and the other isn't quite right.  Clearly fine pitch isn't the right move for
threading into soft plastic.

I ordered some M2x4mm and M2x6mm coarse pitch screws hoping they work better.

![Sniffer PCB Assembled Front](https://i.imgur.com/NaeZ17w.jpg)
![Sniffer PCB Assembled Back](https://i.imgur.com/77KQXdF.jpg)
![Sniffer PCB Assembled Front Vertical](https://i.imgur.com/Fa8yZ4f.jpg)
![Sniffer PCB Assembled Back Sensor View](https://i.imgur.com/m3SkfM2.jpg)
![Sniffer PCB Assembled Back PMSA003 Removed](https://i.imgur.com/5UzjO6i.jpg)


## Validation

To validate the accuracy of the sensor I placed it outside and logged the data for several hours and
compared it to nearby PurpleAir sensors.

Here's the plot of the data in Grafana, the Sniffer is `sniffer0_pm_2_5_aqi`.

![Grafana AQI plot of sniffer vs nearby sensors](https://i.imgur.com/5KR35hx.png)

The sensor data seems to be within about 1% of the other sensors in the area.

Grafana dashboard with the BME680 parameters:

![Grafana with BME680 data](https://i.imgur.com/fBRGtVl.png)


## What's Next

Next steps are to build more and give them to some friends.  To remove the dependency on WiFi and
HomeAssistant I'll explore updating ESPHome to drop the HomeAssistant connection for a time source and
use NTP instead.  This is just a matter of modifying YAML files on the project repo.

I'll probably drop the BME680 in favor of the BME280.  There's a BME280 module that is pin compatible
with the Sniffer design.  Would love it if someone could demonstrate a more useful use-case for the VOC
gas resistance sensor.  Seems this would be most useful in an industrial setting where strong solvents
are present, but my home isn't subject to those chemicals.

On the next boards I'm going to use 2.54mm pitch machined round pin headers and sockets to hold the
components in place so I can swap them for future testing.  The first build uses the included square
stamped pin headers and were soldered in place.

A friend mentioned they'd look at making a 3D printable enclousre to hold it, so that'd be cool.

Others have asked for an assembly tutorial, maybe I'll put together a follow-up post if there's more
interest.

Unrelated to the hardware, I want to ingest the CARB government PM2.5 data stream and log that to
InfluxDB and Grafana to have a more authoritative data source.


## Conclusion

The PMSA003 works as advertised and is close enough to the nearby sensors to give me enough confidence in
its readings to evaluate the air within my home.  My Winix P150 air purifier makes a notable difference
on the two highest speeds and doesn't do much at lower speeds.

ESP32 is a pretty awesome chip (price + features) and is enabled by an equally amazing ESPHome ecosystem.
