---
title: "The systemd journalctl Process Hogs A lot of Memory"
excerpt: "What causes journalctl to consume 10%+ of RAM? The priority level."
category: linux
tags: [linux, systemd, journalctl, memory, ram, oom]
header:
  image: https://i.imgur.com/tOdLKhy.png
  overlay_color: "#000"
  overlay_filter: "0.5"
  overlay_image: https://i.imgur.com/tOdLKhy.png
---

## Out of Memory Killer is Killing My Processes!

I have a small [$5/mo Digital Ocean droplet](http://do.co/2dsUAbr) (Use my [promo code](http://do.co/2dsUAbr) to get a $10 credit!) with 512MB of RAM running a number of small low volume services.  I recently added a [Syncthing relay](/sharing/syncthing-relay-docker-container/) and started logging to [Papertrail](/linux/logging-all-the-things-with-rsyslog-and-papertrail/).  I would notice that the Syncthing relay would periodically get killed as the system was out of memory and Papertrail would send me some alerts around the out of memory killer running.  Shocked that the poor system is out of memory, I dug deeper.  I killed off some old Tahoe-LAFS docker containers I had running, after I gave up on using Tahoe-LAFS and kept looking for memory hogs.  The culprit was much unexpected: systemd's [journalctl](https://www.freedesktop.org/software/systemd/man/journalctl.html).

## Finding the Memory Hog

Finding the hog was easy with `ps`:

    ❯❯❯ ps aux --sort -rss | head -n5
    USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
    root      5300  0.0 17.7 976640 89724 ?        S    16:02   0:00 /usr/bin/journalctl -afb -p info -n1 -o cat SYSLOG_FACILITY=4 SYSLOG_FACILITY=10
    65534     1017  4.3  7.0  39432 35736 ?        Ssl  02:49  36:56 /usr/local/bin/strelaysrv
    root       200  0.0  6.7 1026188 34296 ?       Ss   02:49   0:02 /usr/bin/syslog-ng -F
    root       311  0.0  4.0 439296 20240 ?        Ssl  02:49   0:29 dockerd -H fd:// --ipv6 --storage-driver=overlay

Whaat?  Why?  I had a good guess as to which service was responsible for starting this `journalctl` process, but `systemd` makes it trivially to confirm by querying the status of the `pid`:

    ❯❯❯ systemctl status 5300
    ● sshguard.service - Block hacking attempts
       Loaded: loaded (/etc/systemd/system/sshguard.service; enabled; vendor preset: disabled)
       Active: active (running) since Thu 2016-10-20 16:02:11 UTC; 52min ago
     Main PID: 5292 (sshguard-journa)
        Tasks: 5 (limit: 4915)
       Memory: 27.8M
          CPU: 652ms
       CGroup: /system.slice/sshguard.service
               ├─5292 /bin/sh /usr/lib/systemd/scripts/sshguard-journalctl -b 120:/var/db/sshguard/blacklist.db SYSLOG_FACILITY=4 SYSLOG_FACILITY=10
               ├─5300 /usr/bin/journalctl -afb -p info -n1 -o cat SYSLOG_FACILITY=4 SYSLOG_FACILITY=10
               ├─5301 /usr/bin/sshguard -b 120:/var/db/sshguard/blacklist.db
               └─5303 /bin/sh /usr/libexec/sshg-fw

    Oct 20 16:02:12 void1 sshguard-journalctl[5292]: DROP       all  --  116.31.116.18        0.0.0.0/0
    Oct 20 16:02:12 void1 sshguard-journalctl[5292]: DROP       all  --  69.84.29.186         0.0.0.0/0
    Oct 20 16:02:12 void1 sshguard-journalctl[5292]: DROP       all  --  120.25.227.240       0.0.0.0/0
    Oct 20 16:02:12 void1 sshguard[5301]: blacklist: blocking 88 addresses
    Oct 20 16:02:12 void1 sshguard[5301]: Monitoring attacks from stdin
    Oct 20 16:10:41 void1 sshguard[5301]: 64.137.168.194: blocking for 240 secs (3 attacks in 477 secs, after 1 abuses over 477 secs)
    Oct 20 16:14:46 void1 sshguard[5301]: 64.137.168.194: unblocking after 245 secs
    Oct 20 16:25:58 void1 sshguard[5301]: 64.137.168.194: blocking for 480 secs (3 attacks in 459 secs, after 2 abuses over 1394 secs)
    Oct 20 16:34:25 void1 sshguard[5301]: 64.137.168.194: unblocking after 507 secs
    Oct 20 16:44:46 void1 sshguard[5301]: 64.137.168.194: blocking for 960 secs (3 attacks in 443 secs, after 3 abuses over 2522 secs)

*(log not obfuscated to intentionally incriminate the guilty)*

There you have it, the seemingly simple [sshguard](http://www.sshguard.net/) process.  For those who don't know, the `sshguard` process watches log files for failed login attempts, and then temporarily bans offending IP addresses (using iptables firewall) that are attempting to brute force logins.  I use it because it keeps my logs cleaner, slows down the bot nets running the scans and might even be slightly more secure assuming you have a bad passwords.

But, why and how is it using 17.7% (I've seen up to 25%) of my available memory?  Nobody knows.


## Investigating journalctl

If we look at the arguments passed to the `journalctl` process we can try to understand what `sshguard` needs:

    journalctl -afb -p info -n1 -o cat SYSLOG_FACILITY=4 SYSLOG_FACILITY=10

* `-a` - show all fields.
* `-f` - follow or stream the log data as it happens.
* `-b` - display only logs from this boot.
* `-p info` - filter for syslog messages of [priority](https://en.wikipedia.org/wiki/Syslog#Severity_level<Paste>) *info* and lower, effectively everything with an assigned priority and not priority *debug*.
* `-n1` - upon beginning the follow mode, print at most 1 previous message.
* `-o cat` - send the only log message text, no timestamps or extra metadata.
* `SYSLOG_FACILITY=4` - select syslog [facility](https://en.wikipedia.org/wiki/Syslog#Facility) *auth*.
* `SYSLOG_FACILITY=10` - select syslog [facility](https://en.wikipedia.org/wiki/Syslog#Facility) *authpriv*.

Random thoughts and comments:

* `-b` - seems unnecessary as it's only streaming log messages as it comes in, but doesn't seem to hurt.
* `-n1` - seems slightly ambiguous, is fetching one old message of significance?  Is there a quirk here?  Using `-n0` would be more clear that it doesn't matter.
* `-a` sounds suspicious, with `-o cat` do other *fields* even make sense?  Perhaps the cause of memory consumption?

Turns out, all of the initial thoughts and comments are of no real consequence.  Deeper digging shows that `-p info` is to blame.  See the following test where I manually run the `journalctl` command:

    ❯❯❯ ps aux --sort -rss | grep journalctl
     PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
    6639  0.4 23.7 947548 119908 pts/1   S+   17:16   0:00 /usr/bin/journalctl -afb -p info -n1 -o cat SYSLOG_FACILITY=4 SYSLOG_FACILITY=10
    6632  0.1  8.2 890204 41868 pts/4    S+   17:16   0:00 /usr/bin/journalctl -afb -n1 -o cat SYSLOG_FACILITY=4 SYSLOG_FACILITY=10
    6700  0.0  8.3 857436 42220 pts/4    S+   17:21   0:00 /usr/bin/journalctl -f -n0 -o cat SYSLOG_FACILITY=4 SYSLOG_FACILITY=10


Wow, just dropping `-p info` brings the *rss* memory size down from 120MB to 42MB or 23.7% -> 8.2% of total system RAM (512MB on this server).  In theory, I'd think that `-p info` would *reduce* memory consumption as it'd be dropping the *debug* priority system log messages.  Seems to work quite a bit different.

Even 42MBs seems like excessive memory consumption for streaming log data, but this is already an order of magnitude improvement.

Stripping off the other `-b`, `-n1` and `-a` flags that I commented on before, makes no difference.  It's possible those flags are there for a reason, and I'm not aware of something yet, so the risk is greater then the reward with this set of primitive tests.

For those curious, `journalctl` running on Arch Linux on a 512 MB DigitalOcean Droplet:

    ❯❯❯ journalctl --version
    systemd 231
    +PAM -AUDIT -SELINUX -IMA -APPARMOR +SMACK -SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD +IDN

## Quick Attempt to Repeat


### Home Workstation on Arch Linux

Also running `systemd 231`:

      PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
    27154  0.9  0.2 566856 43916 pts/9    S+   10:31   0:00 journalctl -f -n0 -p info
    27006  0.1  0.1 562440 17928 pts/7    S+   10:31   0:00 journalctl -f -n0

Result: 44 MB -> 18 MB.  Massive change, but not as much memory, perhaps it has to do with the log contents?

### Ubuntu 16.04 512 MB Cloud Server

On another 512MB droplet running on [Vultr](http://bit.ly/2e4Yydk) running Ubuntu 16.04:

     PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
    5670  0.0  1.1 128756  5660 pts/3    S+   17:36   0:00 journalctl -f -n0 -p info
    5725  0.0  0.2  79604  1452 pts/6    S+   17:36   0:00 journalctl -f -n0

Result: 6 MB -> 1 MB. Wow. This is awesome, and is mostly what I'd expect for memory usage, very reasonable.

For completeness, the version for this much desired result:

    ❯❯❯ journalctl --version
    systemd 229
    +PAM +AUDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ -LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD -IDN

## Interim Solution

The interim solution for `sshguard` is to modify wrapper script to drop the priority filtering.  This will get overwritten on the next update, but hopefully we can swim upstream and fix `journalctl` so that it behaves more like the Ubuntu build.

To do that, update `/usr/lib/systemd/scripts/sshguard-journalctl` to the following:

    #!/bin/sh
    SSHGUARD_OPTS=$1
    shift
    LANG=C /usr/bin/journalctl -f -n0 -o cat "$@" | /usr/bin/sshguard $SSHGUARD_OPTS

Restart `sshguard`:

    sudo systemctl restart sshguard

Limp along.


## Ideal World

Hopefully `journalctl` has a bug that is easily fixed to bring this back to reality so that it is not an unnecessary resource hog for just streaming log files.

With open source software, you can only blame yourself for not making something better.
