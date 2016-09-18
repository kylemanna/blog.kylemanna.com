---
title: "Start OpenOCD on USB hotplug"
description: ""
category: hardware
tags: [hardware, linux, openocd, usb, systemd]
---

## Working on Embedded

I work on embedded devices with few tools and avoid GUIs and IDEs like the plague.  I feel that GUIs and IDEs leave me too disconnected from what's actually going on.  While nice when walking a straight and narrow path set by others, they quickly  become a huge headache when I leave the path.  I like to tip-toe off the path and then blaze my own trails.

My daily tools include [neovim](https://neovim.io/) + [cscope](http://cscope.sourceforge.net/) + [cgdb](https://cgdb.github.io/) + [embedded gcc + gdb](https://launchpad.net/gcc-arm-embedded) + [OpenOCD](http://openocd.org).  OpenOCD talks to my SWD JTAG debugger of choice, these days it's anything that implements [CMSIS-DAP](http://www.keil.com/pack/doc/CMSIS/DAP/html/index.html) like my [FRDM-K64F](http://www.nxp.com/products/software-and-tools/hardware-development-tools/freedom-development-boards/freedom-development-platform-for-kinetis-k64-k63-and-k24-mcus:FRDM-K64F).  The `arm-none-eabi-gdb` tool then talks to OpenOCD and provides me an interface to program and debug everything from Cortex-M0s to Cortex-M4s.  Good enough and when it doesn't support the latest chip, I can patch OpenOCD and charge on.

## The Problem

The problem is that I don't want to run OpenOCD manually.  I'm lazy.  The IDEs do all this stuff behind the scenes while you wait 30 seconds to launch each debug session.  It slowly launches `openocd`, then `arm-none-eabi-gdb` then connects, then programs the target and somewhere along the line it wasted a few seconds changing it's view/perspective.

Why can't a lot of this happen in parallel or only happen once?

Read on my friend.

## Solution

The solution is simple, as all good solutions are:
1. Launch `openocd` in the background whenever the debugger is plugged in via USB.  Kill it when it is disconnected.  Simple.
2. Make it easy for `gdb` to reconnect to `openocd`
3. Add a simple `gdb` function to reprogram the chip.
4. Regain 10's of minutes from each day or more!

## Enter `systemd`

I love systemd.  Most of the time it does what I want ([but not always](https://bugs.freedesktop.org/show_bug.cgi?id=88483)).  I use `systemd` as a process manager to manage the lifetime of the `openocd` process.  When `udev` tells `systemd` a certain device is plugged in, start the `openocd` process.  When the device is removed, kill the process.  Oh yeah, handle graceful initialization of the chip when `gdb` connects.

### Setup udev

Tell `udev` to watch for a certain USB product identification string matching `*CMSIS-DAP*`and add a device alias to it.  This device alias will be something `systemd` can act on the addition and removal of.

    # Copy this file to /etc/udev/rules.d/

    ACTION!="add|change", GOTO="cmsis_dap_rules_end"
    SUBSYSTEM!="usb|tty|hidraw", GOTO="cmsis_dap_rules_end"

    # CMSIS-DAP compatible adapters
    ATTRS{product}=="*CMSIS-DAP*", MODE="664", GROUP="uucp", TAG+="systemd", ENV{SYSTEMD_ALIAS}="/sys/devices/swd/cmsis/dap/%E{ID_SERIAL_SHORT}"

    LABEL="cmsis_dap_rules_end"

For reference, this file is on [Github](https://github.com/kylemanna/systemd-utils/blob/2f37c792ba91030c2f378fff357a56808a06997b/scripts/98-cmsis-dap.rules).

Place the file at `/etc/udev/rules.d/98-cmsis-dap.rules` and reload `udev`:

    sudo udevadm control --reload-rules

To test if this worked, plug and unplug a FRDM-K64F with OpenSDA with `udevadm monitor` running:

    $ udevadm monitor -up
    UDEV  [17366.055607] add      /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.3/1-1.3.3/1-1.3.3:1.1/tty/ttyACM0 (tty)
    ACTION=add
    DEVLINKS=/dev/serial/by-path/pci-0000:00:1a.0-usb-0:1.3.3:1.1 /dev/serial/by-id/usb-MBED_MBED_CMSIS-DAP_02400226c3123e5e0000000000000000000000003ecbc3e6-if01
    ID_MODEL=MBED_CMSIS-DAP
    ID_MODEL_ENC=MBED\x20CMSIS-DAP
    ID_MODEL_FROM_DATABASE=LPC1768
    ID_SERIAL=MBED_MBED_CMSIS-DAP_02400226c3123e5e0000000000000000000000003ecbc3e6
    ID_SERIAL_SHORT=02400226c3123e5e0000000000000000000000003ecbc3e6
    ID_TYPE=generic
    ID_USB_CLASS_FROM_DATABASE=Communications
    ID_USB_DRIVER=cdc_acm
    ID_USB_INTERFACES=:080650:030000:020201:0a0000:
    ID_USB_INTERFACE_NUM=01
    ID_VENDOR=MBED
    ID_VENDOR_ENC=MBED
    ID_VENDOR_FROM_DATABASE=NXP
    ID_VENDOR_ID=0d28
    SYSTEMD_ALIAS=/sys/devices/swd/cmsis/dap/02400226c3123e5e0000000000000000000000003ecbc3e6
    TAGS=:systemd:
    ...

Note the `SYSTEMD_ALIAS` property.  Udev is fulfilling it's task of creating a device alias.

### Setup systemd service

Next step is to configure `systemd` to launch a service while the device is attached.  To do that, we need to create a service file:

    # Author: Kyle Manna <kyle[at]kylemanna[d0t]com>

    [Unit]
    Description=OpenOCD Daemon
    After=sys-devices-swd-cmsis-dap.device
    BindsTo=sys-devices-swd-cmsis-dap.device

    [Service]
    ExecStart=/bin/sh -c 'sleep 1; exec openocd -f interface/cmsis-dap.cfg -f target/kx.cfg -c "kx.cpu configure -event gdb-attach { reset init }"'

    [Install]
    WantedBy=sys-devices-swd-cmsis-dap.device

Also [available on Github](https://github.com/kylemanna/systemd-utils/blob/2f37c792ba91030c2f378fff357a56808a06997b/units/openocd-cmsis-dap.service).

Tweak the service file as needed for your target device, mine works on a NXP Kinetis FRDM-K64F dev board as well as some custom KV11 and K22 boards.

Place the service file in a place where the user's `systemd` daemon (not system!) will pick it up: `$HOME/.config/systemd/user/openocd-cmsis-dap.service` and reload `systemd`:

    systemctl --user daemon-reload

  Next enable the service so that the binding starts it:

    systemctl --user enable openocd-cmsis-dap.service

If all goes well, unplug (if currently plugged) and re-plug the CMSIS-DAP's USB cable should launch `openocd`. Ensure there is an embedded target attached to the SWD interface for `openocd` to talk to.  Verify with:

    $ systemctl --user status openocd-cmsis-dap.service
    ● openocd-cmsis-dap.service - OpenOCD Daemon
       Loaded: loaded ($HOME/.config/systemd/user/openocd-cmsis-dap.service; enabled; vendor preset: enabled)
       Active: active (running) since Tue 2016-05-24 13:53:11 PDT; 3s ago
     Main PID: 20333 (openocd)
       CGroup: /user.slice/user-1000.slice/user@1000.service/openocd-cmsis-dap.service
               └─20333 /usr/bin/openocd -f interface/cmsis-dap.cfg -f target/kx.cfg -c kx.cpu configure -event gdb-attach { reset init }

    May 24 13:53:12 core.hq sh[20333]: cortex_m reset_config sysresetreq
    May 24 13:53:12 core.hq sh[20333]: Info : CMSIS-DAP: SWD  Supported
    May 24 13:53:12 core.hq sh[20333]: Info : CMSIS-DAP: Interface Initialised (SWD)
    May 24 13:53:12 core.hq sh[20333]: Info : CMSIS-DAP: FW Version = 1.0
    May 24 13:53:12 core.hq sh[20333]: Info : SWCLK/TCK = 0 SWDIO/TMS = 1 TDI = 0 TDO = 0 nTRST = 0 nRESET = 1
    May 24 13:53:12 core.hq sh[20333]: Info : CMSIS-DAP: Interface ready
    May 24 13:53:12 core.hq sh[20333]: Info : clock speed 1000 kHz
    May 24 13:53:12 core.hq sh[20333]: Info : SWD IDCODE 0x2ba01477
    May 24 13:53:12 core.hq sh[20333]: Info : kx.cpu: hardware has 6 breakpoints, 4 watchpoints
    May 24 13:53:12 core.hq sh[20333]: Info : MDM: Chip is unsecured. Continuing.

Unplugging the CMSIS-DAP debugger will seamlessly stop it:

    $ systemctl --user status openocd-cmsis-dap.service
    ● openocd-cmsis-dap.service - OpenOCD Daemon
       Loaded: loaded ($HOME/.config/systemd/user/openocd-cmsis-dap.service; enabled; vendor preset: enabled)
       Active: inactive (dead)

    May 24 13:55:39 core.hq sh[20333]: Error: error writing data: (null)
    May 24 13:55:39 core.hq sh[20333]: Error: error writing data: (null)
    May 24 13:55:39 core.hq sh[20333]: Error: CMSIS-DAP command CMD_DISCONNECT failed.
    May 24 13:55:39 core.hq sh[20333]: Error: error writing data: (null)
    May 24 13:55:39 core.hq sh[20333]: Error: CMSIS-DAP command CMD_CONNECT failed.
    May 24 13:55:39 core.hq sh[20333]: Error: error writing data: (null)
    May 24 13:55:39 core.hq sh[20333]: Error: Could not initialize the debug port
    May 24 13:55:39 core.hq sh[20333]: Examination failed, GDB will be halted. Polling again in 100ms
    May 24 13:55:39 core.hq systemd[7275]: Stopping OpenOCD Daemon...
    May 24 13:55:39 core.hq systemd[7275]: Stopped OpenOCD Daemon.

## Tweak GDB a Little

I have two handy user-defined commands I use to simplify using `gdb` (via `cgdb` of course) and they are located in my `~/.gdbinit` file:

    define reconnect
        target remote :3333
    end

    define reload
        mon reset halt
        make
        load
        mon reset init
        continue
    end

The `reconnect` command reduces the amount of typing to connect `gdb` to `openocd`.  I'm lazy, and tab-completion helps even more.

The `reload` command runs `make` in my current working directory to rebuild my `.elf` file and then flashes it to the target.  Handles explicitly halting the remote target and resuming execution to avoid surprises.

## Conclusion

This systemd magic makes it so that openocd is always running before I know I need it and the gdb commands allow me to easily reflash my target for debugging.

Run this all in tmux with minicom and vim on different windows or panes and you'll be considerably more productive.

Cheers.
