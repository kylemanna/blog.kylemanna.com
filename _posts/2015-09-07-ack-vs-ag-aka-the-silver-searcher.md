---
title: "Ack vs Ag aka The Silver Searcher"
description: ""
category: linux
tags: [linux, ack, ag]
---

## Silver Searcher

Today I stumbled upon [the silver](http://geoff.greer.fm/ag/) [searcher](https://github.com/ggreer/the_silver_searcher) (command line `ag`) which appears to be a replacement for the fast `grep` replacement `ack`.

It appears to be a drop in replacement.  Instead of typing `ack` I save one letter and type `ag` and get the same output.  I'm sure that some buried options are different, but I never used the advanced options of `ack`.

Arch Linux has it readily available (package name `the_silver_searcher`) and the package size is a tick smaller, not that it matters, at all.


## Benchmark

To decide if it was worth it, I took it for a quick spin searching for a rare keyword in the Linux kernel.  I preheated my file system cache to ensure I wase testing the program and not my disks.

The result? A significant speed-up!  **My simple benchmark search went from 20 seconds to 0.5 seconds**.  It's possible the silver searcher is skipping certain things, but by noting the parallel operation and increased CPU usage jumping from 99% to 325% suggests it's capitalizing on my spare cores.  I'll take it.

Just need to remember to type `ag` instead of `ack`.


## Raw Benchmark Commands

    ~/t/linux ❯❯❯ time ack canbus
    arch/sh/drivers/pci/pci.c
    35:static void pcibios_scanbus(struct pci_channel *hose)
    125:            pcibios_scanbus(hose);
    145:            pcibios_scanbus(hose);

    arch/mips/pci/pci.c
    79:static void pcibios_scanbus(struct pci_controller *hose)
    209:            pcibios_scanbus(hose);
    248:            pcibios_scanbus(hose);

    drivers/net/can/Kconfig
    64:       LEDs and you want to use them as canbus activity indicators.
    ack canbus  19.28s user 0.71s system 99% cpu 19.992 total

    ~/t/linux ❯❯❯ time ag canbus
    arch/sh/drivers/pci/pci.c
    35:static void pcibios_scanbus(struct pci_channel *hose)
    125:            pcibios_scanbus(hose);
    145:            pcibios_scanbus(hose);

    arch/mips/pci/pci.c
    79:static void pcibios_scanbus(struct pci_controller *hose)
    209:            pcibios_scanbus(hose);
    248:            pcibios_scanbus(hose);

    drivers/pci/hotplug/cpqphp_pci.c
    206:static int PCI_ScanBusForNonBridge(struct controller *ctrl, u8 bus_num, u8 *dev_num)
    271:                            if (PCI_ScanBusForNonBridge(ctrl, tbus, dev_num) == 0) {

    drivers/net/can/Kconfig
    64:       LEDs and you want to use them as canbus activity indicators.
    ag canbus  0.93s user 0.44s system 322% cpu 0.425 total

    ~/t/linux ❯❯❯ time ack canbus
    arch/sh/drivers/pci/pci.c
    35:static void pcibios_scanbus(struct pci_channel *hose)
    125:            pcibios_scanbus(hose);
    145:            pcibios_scanbus(hose);

    arch/mips/pci/pci.c
    79:static void pcibios_scanbus(struct pci_controller *hose)
    209:            pcibios_scanbus(hose);
    248:            pcibios_scanbus(hose);

    drivers/net/can/Kconfig
    64:       LEDs and you want to use them as canbus activity indicators.
    ack canbus  19.39s user 0.55s system 99% cpu 19.944 total
