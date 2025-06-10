---
title: "Silencing Netdata debugfs.plugin hwmon log spam with libsensors"
category: linux
tags: [linux, monitoring, netdata, sensors, hwmon, lm-sensors]
header:
  image: https://i.imgur.com/wqDZ544.png
  overlay_color: "#000"
  overlay_filter: "0.5"
  overlay_image: https://i.imgur.com/wqDZ544.png
excerpt: "Stop Netdata's sensor spam in your logs by tweaking libsensors config. I'll show you how with examples from my ASUS W680 board."
---

# Silencing Netdata `debugfs.plugin` hwmon log spam with `libsensors`

For some time I noticed my systemd journal was being inundated with Netdata sensor alarm state transitions. This increased the noise in the logs, making it hard to find important log entries and causing the journal logs to rotate too frequently.

## The Problem

Here's an example of the log spam I saw, showing a sensor rapidly flapping between states due to a motherboard with a poor sensor chip implementation, featuring a floating temperature input and bad thresholds that would flip back and forth many times a minute:

```
Jun 07 23:39:28 servuh debugfs.plugin[6036]: temperature sensor 'temperature_nct6798-isa-0290_temp3_AUXTIN0' transitioned from state 'clear' to 'critical' [device 'nct6775.656', driver 'nct6798', subsystem 'platform', path '/sys/class/hwmon/hwmon4']: input 127.000000 >= critical high 125.000000 (userspace evaluation using kernel provided thresholds)
Jun 07 23:39:32 servuh debugfs.plugin[6036]: temperature sensor 'temperature_nct6798-isa-0290_temp3_AUXTIN0' transitioned from state 'critical' to 'clear' [device 'nct6775.656', driver 'nct6798', subsystem 'platform', path '/sys/class/hwmon/hwmon4']
Jun 07 23:39:52 servuh debugfs.plugin[6036]: temperature sensor 'temperature_nct6798-isa-0290_temp3_AUXTIN0' transitioned from state 'clear' to 'alarm' [device 'nct6775.656', driver 'nct6798', subsystem 'platform', path '/sys/class/hwmon/hwmon4']: alarm == 1.000000 (kernel driver generated)
Jun 07 23:39:54 servuh debugfs.plugin[6036]: temperature sensor 'temperature_nct6798-isa-0290_temp3_AUXTIN0' transitioned from state 'alarm' to 'clear' [device 'nct6775.656', driver 'nct6798', subsystem 'platform', path '/sys/class/hwmon/hwmon4']
Jun 07 23:40:10 servuh debugfs.plugin[6036]: temperature sensor 'temperature_nct6798-isa-0290_temp3_AUXTIN0' transitioned from state 'clear' to 'alarm' [device 'nct6775.656', driver 'nct6798', subsystem 'platform', path '/sys/class/hwmon/hwmon4']: alarm == 1.000000 (kernel driver generated)
Jun 07 23:40:12 servuh debugfs.plugin[6036]: temperature sensor 'temperature_nct6798-isa-0290_temp3_AUXTIN0' transitioned from state 'alarm' to 'critical' [device 'nct6775.656', driver 'nct6798', subsystem 'platform', path '/sys/class/hwmon/hwmon4']: input 127.000000 >= critical high 125.000000 (userspace evaluation using kernel provided thresholds)
```

These messages typically appear due to poor hardware implementation by motherboard manufacturers:
- Floating sensor inputs that aren't properly tied high or low
- Incorrectly configured threshold values in the sensor chip

## The Search for a Solution

When I first encountered this issue, I spent quite a bit of time searching for solutions. Most of the search results and documentation pointed to Netdata's `go.d.plugin` for sensor monitoring.

The current implementation, starting with Netdata v2.2.0, uses the `debugfs.plugin` with `libsensors` integration, but finding accurate documentation about this was challenging. Many forum posts and documentation pages are outdated, still referencing the old `go.d.plugin` approach.

I discovered the relevant information in the [Netdata PR #19251](https://github.com/netdata/netdata/pull/19251) which moved sensor monitoring to the `debugfs.plugin`, and later found the implementation details in the [`debugfs.plugin` module-libsensors.c](https://github.com/netdata/netdata/blob/9d9478303d3da58a35e302c46c40b629c6ad0f4c/src/collectors/debugfs.plugin/module-libsensors.c#L1221) source code.

After some digging through the Netdata source code and `libsensors` documentation, I discovered that the solution lies in properly configuring `libsensors` rather than trying to modify Netdata's behavior directly.

## The Solution: `libsensors` Configuration

Netdata uses `libsensors` to monitor hardware sensors. You can control these messages by configuring `libsensors` to:

1. Set custom thresholds for sensors
2. Ignore specific sensors
3. Adjust the sensitivity of state transitions
4. Configure how sensor events are logged

As a bonus, configuring the `sensors3.conf` configuration and friends will also make the `sensors` CLI command output match!

### Configuration Location and Example

For my ASUS W680 motherboard, I created a drop-in configuration file at `/etc/sensors.d/50-w680.conf`. Here's a real-world example of how to configure `libsensors` to reduce log spam on a W680 motherboard with an `NCT6798` sensor chip:

```conf
chip "nct6798-isa-0290"
    # Ignore the problematic temperature sensor AUXTIN0 (temp3)
    ignore temp3
    ignore temp7

    # Ignore the problematic voltage sensor in6
    ignore in6

    # Set reasonable voltage limits to make ALARM values useful
    # These are example values - adjust based on your hardware
    set in1_max 1.2
    set in2_max 3.5
    set in3_max 3.4
    set in4_max 1.2
    set in7_max 3.5
    set in8_max 3.3
    set in9_max 1.2
    set in10_max 1.2
    set in11_max 1.2
    set in12_max 1.2
    set in13_max 1.0
    set in14_max 1.0

    # Set minimum fan speeds for the fans you actually use
    set fan1_min 200
    set fan2_min 200
    set fan3_min 200
    set fan4_min 200
```

### Viewing Sensor Data

You can view the current sensor readings using the `sensors` command. Here's an example output for the `NCT6798` chip:

```bash
> sensors 'nct6798-isa-0290'
nct6798-isa-0290
Adapter: ISA adapter
in0:                      912.00 mV (min =  +0.00 V, max =  +1.74 V)
in1:                        1.01 V  (min =  +0.00 V, max =  +1.20 V)
in2:                        3.41 V  (min =  +0.00 V, max =  +3.50 V)
in3:                        3.30 V  (min =  +0.00 V, max =  +3.41 V)
in4:                      1000.00 mV (min =  +0.00 V, max =  +1.20 V)
in5:                       32.00 mV (min =  +0.00 V, max =  +0.00 V)
in7:                        3.39 V  (min =  +0.00 V, max =  +3.50 V)
in8:                        3.18 V  (min =  +0.00 V, max =  +3.30 V)
in9:                        1.04 V  (min =  +0.00 V, max =  +1.20 V)
in10:                       1.01 V  (min =  +0.00 V, max =  +1.20 V)
in11:                     928.00 mV (min =  +0.00 V, max =  +1.20 V)
in12:                       1.05 V  (min =  +0.00 V, max =  +1.20 V)
in13:                     440.00 mV (min =  +0.00 V, max =  +1.00 V)
in14:                     880.00 mV (min =  +0.00 V, max =  +1.00 V)
fan1:                     2960 RPM  (min =  200 RPM)
fan2:                     1105 RPM  (min =  200 RPM)
fan3:                     3013 RPM  (min =  200 RPM)
fan4:                     2980 RPM  (min =  200 RPM)
fan5:                        0 RPM  (min =    0 RPM)
fan7:                        0 RPM  (min =    0 RPM)
SYSTIN:                    +26.0°C  (high = +80.0°C, hyst = +75.0°C)
                                    (crit = +125.0°C)  sensor = thermistor
CPUTIN:                    +39.5°C  (high = +80.0°C, hyst = +75.0°C)
                                    (crit = +125.0°C)  sensor = thermistor
AUXTIN1:                   +26.0°C  (high = +80.0°C, hyst = +75.0°C)
                                    (crit = +125.0°C)  sensor = thermistor
AUXTIN2:                   +29.0°C  (high = +80.0°C, hyst = +75.0°C)
                                    (crit = +100.0°C)  sensor = thermistor
AUXTIN3:                   +32.0°C  (high = +80.0°C, hyst = +75.0°C)
                                    (crit = +100.0°C)  sensor = thermistor
PECI Agent 0:              +44.0°C  (high = +98.0°C, hyst = +95.0°C)
PECI Agent 0 Calibration:  +37.0°C
PCH_CHIP_CPU_MAX_TEMP:      +0.0°C
PCH_CHIP_TEMP:             +56.0°C
PCH_CPU_TEMP:               +0.0°C
pwm1:                          16%  (mode = pwm)  MANUAL CONTROL
pwm2:                          49%  (mode = pwm)
pwm3:                          16%  (mode = pwm)  MANUAL CONTROL
pwm4:                          16%  (mode = pwm)  MANUAL CONTROL
pwm7:                         128%  (mode = pwm)
intrusion0:               ALARM
intrusion1:               ALARM
beep_enable:              disabled
```

This output shows all the sensors available on the chip, including temperatures, voltages, fan speeds, and other status indicators.

### Applying Configuration at Boot

If you've configured min/max values to adjust alarm thresholds, you'll want to ensure these settings are applied at system boot. Create a systemd service to handle this:

```ini
# /etc/systemd/system/sensors-set.service
[Unit]
Description=Set NCT6798 Sensor Configuration
Before=netdata.service

[Service]
Type=oneshot
ExecStart=/usr/bin/sensors -s

[Install]
WantedBy=multi-user.target
```

Enable and start the service:
```bash
sudo systemctl enable --now sensors-set.service
```

This ensures your sensor configuration is applied before Netdata starts, allowing it to see the correct alarm values. While I haven't verified this, I believe Netdata only reads the sensor configuration once during initialization.

## Conclusion

While hardware sensor monitoring is important, the most frustrating aspect is dealing with poor sensor integration by motherboard manufacturers, followed closely by Netdata's lack of documentation on the new `debugfs.plugin`. However, these issues are easily solved using `libsensors` configuration, which provides a flexible way to maintain important monitoring while keeping your logs clean and manageable.