---
title: "Boot Linux ISOs From USB Sticks Using GRUB"
tagline: "safe and sound"
category: linux
tags: [backup, security, offline, grub, linux, ubuntu, osx, mbr, gpt, efi]
---

## Bootable GRUB2 Emergency Flash Drive

The goal of this tutorial is to document the steps to create a simple USB flash drive with GRUB2 installed and configured to boot ISO images.  This will enable me to put Ubuntu, memtesters, etc on archival flash drives.

Storing the ISO images directly allows their integrity and authenticity to be easily verified using hashes.

Furthermore, the remaining portion of the disk can be used for anything.  I've had good luck creating additional partitions and creating LUKS partitions there.

## Steps

1. Define some environmental variables used later:

       DEV=/dev/sdx
       USB=/mnt/usb

2. Zero the old partition table and create a new one, feel free to tweak the size of the boot partition if you intend to hold more then 1 or 2 ISO images.  The `grub` partition is where the GRUB boot loader will be setup, don't use this partition directly.  The `boot` partition is where all the primary boot files are stored.

       sudo sgdisk --zap-all $DEV

       sudo sgdisk -n 1:0:+2M $DEV
       sudo sgdisk -t 1:ef02 $DEV
       sudo sgdisk -c 1:grub $DEV

       sudo sgdisk -n 2:0:+4G $DEV
       sudo sgdisk -t 2:8300 $DEV
       sudo sgdisk -c 2:boot $DEV

    Verify things went as expected:

       $ sudo sgdisk --print $DEV
       Disk /dev/sdc: 61739008 sectors, 29.4 GiB
       Logical sector size: 512 bytes
       Disk identifier (GUID): CC79C82D-BC1D-4D3C-BE85-0068162BC053
       Partition table holds up to 128 entries
       First usable sector is 34, last usable sector is 61738974
       Partitions will be aligned on 2048-sector boundaries
       Total free space is 53346237 sectors (25.4 GiB)

       Number  Start (sector)    End (sector)  Size       Code  Name
          1            2048            6143   2.0 MiB     EF02  grub
          2            6144         8394751   4.0 GiB     8300  boot

3. Create the file system for GRUB and the ISO images and then mount it:

       sudo mkfs.vfat -n SAFEBOOT003 ${DEV}2
       sudo mkdir -p $USB
       sudo mount ${DEV}2 $USB

4. Install GRUB

       sudo mkdir -p $USB/boot/grub

    For tradtional PCs:

       sudo grub-install --no-floppy --boot-directory=$USB/boot $DEV

    (Optional) Add support for EFI Apple computers:

       sudo grub-install --target=x86_64-efi --boot-directory=$USB/boot --efi-directory=$USB --removable --recheck $DEV


5. Create a basic GRUB configuration file, modify path to ISO as appropriate, add more menuentries if desired.  Becareful your shell doesn't replace `$iso`.

       cat <<EOF | sudo tee $USB/boot/grub/grub.cfg
       set timeout=10
       set default=0

       menuentry "Ubuntu 14.04.1 Live ISO" {
          set iso="/iso/ubuntu-14.04.1-desktop-amd64.iso"
          loopback loop \$iso
          linux (loop)/casper/vmlinuz.efi boot=casper iso-scan/filename=\$iso splash
          initrd (loop)/casper/initrd.lz
       }
       EOF

6. Fetch an ISO.  In this case Ubuntu 14.04.1 works well on my System76 Galgo UltraPro laptop.  Surprisingly, 14.04 *works* better then 14.10 on my Apple 2012 Retina MacBook Pro.

       sudo mkdir $USB/iso
       cd $USB/iso
       sudo wget -c http://releases.ubuntu.com/14.04/ubuntu-14.04.1-desktop-amd64.iso

7. For the *security paranoid*, download and verify signatures:

       cd $USB/iso
       sudo wget http://releases.ubuntu.com/14.04/SHA256SUMS.gpg http://releases.ubuntu.com/14.04/SHA256SUMS
       gpg --keyserver keyserver.ubuntu.com --recv-keys FBB75451
       gpg --export -a FBB75451 | sudo tee ubuntu.public.key
       gpg --verify SHA256SUMS.gpg SHA256SUMS
       sha256sum -c <(grep ubuntu-14.04.1-desktop-amd64.iso SHA256SUMS)

    After rebooting into LiveCD, a quick check can be performed to verify the integrity of hte boot media.  Be sure to manually verify the fingerprint to ensure the `ubuntu.public.key` file hasn't been tampered with.  Security usability is hard, *sigh*.

       gpg --import ubuntu.public.key
       gpg --verify SHA256SUMS.gpg SHA256SUMS
       sha256sum -c <(grep ubuntu-14.04.1-desktop-amd64.iso SHA256SUMS)

8. Add extra stuff.  Examples:

    * LUKS partition for sensitive data
    * General purpose partition for easy file transfers
    * Hash / checksum files for integrity verification
    * GPG tools and signatures for authenticity verification
    * Memory tester ISOs
    * Additional Linux distributions
    * Software to run offline code wallet storage like Bitcoin Armory for cold wallets
    * Backup software or recovery tools

I'd recommend all auxiliary software be stored on a LUKS secured partition to avoid concern of tampering (i.e. backdoored Bitcoin wallet software).

## Testing

* Insert flash drive in to a PC.  Interrupt the boot process and instruct the BIOS to boot off the USB flash drive.  The GRUB screen should appear.
* Insert flash drive in to a Mac.  Hold the "Option" key down during power on and select the "EFI Boot" option that should be present.  Prepare for a semi-broken user experience as the system boots on the edge of disaster that is Apple hardware.  Be ready for no Ethernet or WiFi.  The ultimate offline device.


## Notes

Grub2 version for generation using Arch Linux:

    $ pacman -Q grub
    grub 1:2.02.beta2-5
