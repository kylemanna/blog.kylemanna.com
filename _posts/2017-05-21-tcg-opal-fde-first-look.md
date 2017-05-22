---
title: "TCG Opal FDE with Samsung 960 EVO First Look"
excerpt: "Adventures with TCG Opal FDE on Dell Precision M5510 Laptop"
category: hardware
tags: [hardware, crypto, nvme, tcg opal, ssd, samsung, security, linux]
header:
  image: https://i.imgur.com/BOsFu4n.jpg
  overlay_color: "#000"
  overlay_filter: "0.5"
  overlay_image: https://i.imgur.com/BOsFu4n.jpg
---

## Diving in to Hardware Full Disk Encryption with Samsung 960 EVO

I purchased a Samsung 960 EVO NVMe drive for my Dell Precision 5510 with the goal of leveraging the [TCG Opal](https://en.wikipedia.org/wiki/Opal_Storage_Specification) support for security and performance.  With TCG Opal, the NVMe drive can do hardware based cryptography at full speed.  The performance is impressive and the cryptography is *always* turned on.  By default the drive has a key and the cryptography engine is always in the data pipeline whether you've explicitly locked your NVMe drive or not.

### TCG Opal Advantages

* Full speed always on cryptography.  The NVMe drive is designed to encrypt and decrypt data whether you provide a key or not, it will fallback to a default key for non-Opal operation.
* No CPU cycles wasted on block level (LUKS or `dm-crypt`) or filesystem level (ext4 crypto) crypto.  This saves battery and improves performance.
* Once the drive is unlocked, the encryption is transparent to the OS.  Simple to dual boot Linux or Windows on the same TCG Opal drive.

### TCG Opal Disadvantages

* Need to setup a Pre-Boot Authorization image to *unlock* the drive.  This slows down the boot and can get clumsy with UEFI that expect consistent EFI boot options.
* Due to the transparent operation, it's hard to lock the drive while the laptop is sleeping (S3) without operating system support.  But, only maybe, see below.
* Your data is always visible to malware while booted.  This is the same as most FDE solutions like LUKS and Bitlocker.  Something like ext4 encryption would allow me to selectively encrypt data, I've used `ecryptfs` on my desktop for years for sensitive data at rest.

My core goal is to protect the data on my laptop from access in the event the laptop is lost or stolen.  Secondary goals are performance and battery life. TCG Opal checks all these boxes for me.

## Dell Precision 5510 with LUKS before TCG Opal

My Dell Precision 5510 laptop came with an OEM Toshiba THNSN5256GPU7 NVMe 256GB drive from Dell.  The NVMe drive is nice and fast, but didn't have hardware crypto. Nor did it have enough space for standard laptop stuff and massive Yocto builds + Win10 dual boot install.  I ran [LUKS](https://en.wikipedia.org/wiki/Linux_Unified_Key_Setup) on the device to secure it in the event the laptop was stolen.   However, I was always concerned that the max performance of the `dm-crypt` software would potentially slow down the drive and would certainly affect power efficiency.

Here's a benchmark of the laptop's crypto algorithm performance (run from battery):

    $ cryptsetup benchmark
    # Tests are approximate using memory only (no storage IO).
    PBKDF2-sha1      1424695 iterations per second for 256-bit key
    PBKDF2-sha256    1688528 iterations per second for 256-bit key
    PBKDF2-sha512    1353001 iterations per second for 256-bit key
    PBKDF2-ripemd160 1057032 iterations per second for 256-bit key
    PBKDF2-whirlpool  773286 iterations per second for 256-bit key
    #     Algorithm | Key |  Encryption |  Decryption
            aes-cbc   128b  1117.1 MiB/s  3625.9 MiB/s
        serpent-cbc   128b    91.5 MiB/s   732.3 MiB/s
        twofish-cbc   128b   212.9 MiB/s   394.9 MiB/s
            aes-cbc   256b   859.6 MiB/s  2888.9 MiB/s
        serpent-cbc   256b    94.2 MiB/s   726.2 MiB/s
        twofish-cbc   256b   218.0 MiB/s   395.6 MiB/s
            aes-xts   256b  3584.8 MiB/s  3593.8 MiB/s
        serpent-xts   256b   708.3 MiB/s   700.6 MiB/s
        twofish-xts   256b   383.7 MiB/s   391.0 MiB/s
            aes-xts   512b  2865.5 MiB/s  2865.6 MiB/s
        serpent-xts   512b   708.4 MiB/s   698.8 MiB/s
        twofish-xts   512b   383.5 MiB/s   390.3 MiB/s

Arch Linux defaults for reference:

    $ cryptsetup --help
    Default compiled-in key and passphrase parameters:
            Maximum keyfile size: 8192kB, Maximum interactive passphrase length 512 (characters)
    Default PBKDF2 iteration time for LUKS: 2000 (ms)

    Default compiled-in device cipher parameters:
            loop-AES: aes, Key 256 bits
            plain: aes-cbc-essiv:sha256, Key: 256 bits, Password hashing: ripemd160
            LUKS1: aes-xts-plain64, Key: 256 bits, LUKS header hashing: sha256, RNG: /dev/urandom

As you can see the default `aes-xts-plain64` algorithm maxes out at *3,500 MiB/s* on my [Intel E3-1505M Skylake processor](https://ark.intel.com/products/89608/Intel-Xeon-Processor-E3-1505M-v5-8M-Cache-2_80-GHz).  This is very close to the max performance of the 960 EVO under ideal conditions, see the benchmark on the 960 EVO in my TCG Opal setup:

![960 EVO Benchmark](http://i.imgur.com/JUU5sIQ.png "960 EVO Benchmark")

That said, there's no way that LUKS could match the performance or power efficiency of the integrated TCG Opal support.

## Using `sedutil-cli` and `linuxpba` on Arch Linux

I wrestled quite a bit with `sedutil-cli` and `linuxpba` to get it to recognize drive and work with it.  Initially, `sedutil-cli` needed some patches to work with NVMe, which [some people contributed but aren't merged](https://github.com/Drive-Trust-Alliance/sedutil/pull/108).  After verifying the drive looked good for integration, I discovered that the Pre-Boot Authorization image needed similar patches to unlock the drive at boot time.  Rebuilding the images was fraught with frustration as the Makefiles incorrectly build with the host toolchain and link against the host libraries instead of associated toolchains, this is evident by the symbol mismatches that are printed before the tools bail.  I hacked together a fix for this and was able to get it to build and run on my laptop.

The next struggle was understanding that on the Dell Precision 5510 (and likely the Dell XPS 9550 and new Dell XPS 9560 and Precision 5520) modifies the boot order and doesn't respect the settings set by `efibootmgr` as the partition table changes when it's locked and unlocked due to the way the shadow MBR works.  The result was Syslinux failing at the `boot:` prompt after failing to load its config file when the MBR was locked.  This was ultimately resolved by manually inserting to entries in to the Dell UEFI settings for Syslinux when the shadow MBR is present (drive locked) and when the drive is unlocked to use the `systemd-boot` boot loader I had been previously using.

At this point I was able to boot to Linux and Win10 without issue.  As these things go, there was (is?) a problem with the device sleeping as S3 support is necessary to unlock the drive upon resume from sleep.  Without proper resume support, all the file systems disappear and everything melts down and then blows up.  Of course it does.

I learned that [Linux 4.11 included support for OPAL SED devices and unlocking on resume from this patch set](http://lists.infradead.org/pipermail/linux-nvme/2017-February/008002.html).  I upgraded my laptop to a 4.11.1 kernel and began digging in to setting the key in the kernel with `ioctl(IOC_OPAL_SAVE)`.  Calling the `ioctl()` with my ASCII password of course didn't work for many reasons. To start, `IOC_OPAL_SAVE` is only available on the NVMe name space devices (see `sed_ioctl()` in the kernel) and my utility reported `Inappropriate ioctl for device`. I disabled OPAL support following the sedutil wiki and re-ran the setup changing the device this time from `/dev/nvme0` to `/dev/nvme0n1` thinking that the kernel support and OPAL configuration needed to operate on the same name space, but am not sure if this even mattered.

Now calling `ioctl("/dev/nvme0n1, IOC_OPAL_SAVE, ...)` didn't return any errors, but failed to unlock after resume with error "Not Authorized".  After digging deeper I learned that that `sedutil-cli` was using `pbkdf2` to hash my password (as it should). This requires deriving the hashed password the same way `sedutil-cli` does when it configures the device using `pbkdf2` and friends.  I ran `sedutil-cli` with `gdb` and extracted the derived hash and hacked it in to my test utility and ran it, this time it seemed to work, but I'm skeptical.

## Things Don't Make Sense

Things don't add-up, and when I least expect it something is going to blow-up in my face.  What doesn't work?  Well, the laptop doesn't seem to need the `ioctl(IOC_OPAL_SAVE)` called on every boot like the kernel code suggests.  Now it spontaneously comes out of sleep just fine with no issues. **HOW?  This bothers me.**

Perhaps when I re-configured OPAL support on the `/dev/nvme0n1` device (as opposed to the initial `/dev/nvme0`) device *and* updated my kernel to 4.11 (which added SED OPAL support) I enable a code path that fixes the sleep issue?  I'm not sure, and when I don't understand how things go from broken to fixed I expect them to return to broken with no warning.

Win10 (booted from `systemd-boot`) seems to work just fine with resume as well, but I only tested it after everything seemed to work, I wish I tested it when Linux failed to resume from sleep.  So, I'm concerned the thing isn't actually locked. *However*, after every power on reset, the PBA appears (which is only present on the shadow MBR) asking me to unlock th device before rebooting and going to `systemd-boot` boot loader as expected.

## Conclusion

What gives?  Does anyone know what's going on?  Does anyone else have Linux NVMe + TCG Opal + Sleep support working? I think I might have it working.  I also might not.  Stay tuned!

If you're trying out NVMe on UEFI system, checkout my [sedutil repo with necessary fixes](https://github.com/kylemanna/sedutil/) and definitely skip to the [pre-built images](https://github.com/kylemanna/sedutil/releases) if you can.  Then you can help decipher the S3 sleep mystery.

I've got problems, and I hope my readers have answers, drop me a line in the comments section below!
