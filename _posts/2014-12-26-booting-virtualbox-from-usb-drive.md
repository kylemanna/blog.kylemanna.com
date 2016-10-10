---
title: "Boot VirtualBox from USB Drive"
tagline: ""
category: linux
tags: [backup, security, offline, grub, linux, ubuntu, osx, mbr, gpt, efi, virtualbox, vm]
---

## A Story that Turns into a Use Case

While doing some year-end back up and archiving I had to reconsider my use of [TrueCrypt given the announcement](https://en.wikipedia.org/wiki/TrueCrypt#End_of_life_announcement) this past year.  Do I really need TrueCrypt and cross platform support for my cold storage of GPG keys and Bitcoin wallets if I use Linux 90% of the time?  Maybe not, maybe I can just use LUKS which is very popular and less suspect these days.

If I'm going to use LUKS, then I want to prove to myself that I can access it from Windows or Mac OS X if I need to.  The question was raised: Can I boot from my [Bootable GRUB2 Emergency Flash Drive](/linux/boot-linux-isos-from-usb-sticks-using-grub/) using VirtualBox?  And so the use case was born.

Turns out it was semi easy to do.

## How To


1.  Setup `DEV` for the device to be accessed from the virtual machine:

        DEV=/dev/sdx

2.  Create the VirtualBox disk (on Linux, other OS are similar):

        sudo chown $USER $DEV
        VBoxManage internalcommands createrawvmdk -filename ~/VirtualBox\ VMs/usb.vmdk -rawdisk $DEV

    Unfortunately the permissions are screwy and your local user needs to access `$DEV`.  Since udev manages `/dev` these days, the permissions will revert to normal on the next hotplug.

3.  Create a new VirtualBox machine.  When prompted to create a new hard drive, specify `~/VirtualBox VMs/usb.vmdk`.  Ubuntu 14.04 Desktop requires at least 1 GB of RAM, so keep that in mind when creating the virtual machine.


## Apple OS X Notes

* Sometimes OS X insists on automounting volumes which causes VirtualBox to complain about with errors like `VBOX_E_OBJECT_NOT_FOUND`.  Try unmounting to release the resource:

        diskutil unmountDisk $DEV
