---
title: "Use JSON and jq to Sort systemd's journalctl by Program Frequency"
excerpt: "A series of jq filters can sort the output of journalctl to help find the programs that log the most."
category: linux
tags: [cloud, linux, logging, papertrail, systemd, journalctl, json, jq]
header:
  image: https://i.imgur.com/KTZpbFX.png
  overlay_color: "#000"
  overlay_filter: "0.5"
  overlay_image: https://i.imgur.com/KTZpbFX.png 
---

## Papertrail Gets SPAMMED by Verbose Programs 

I started using [Papertrail](https://papertrailapp.com/?thank=384510) to [log all the things a while back](https://blog.kylemanna.com/linux/logging-all-the-things-with-rsyslog-and-papertrail/).  After the free trial expired, I was put on the free tier which allows only 100 MB of log data transfer effectively limiting the number of messages that can match my alerts and generate emails.  The free tier also caps searchable logs at 48 hours and archives for 7 days, but I don't use those features much.

Unfortunately, I'm on a trajectory that will exceed that bar as you can see in the image that follows.

![Log Data Transfer Limit](https://i.imgur.com/KTZpbFX.png)

A deeper dive in to the detailed account usage by host shows that the majority of data comes from one host in a few bursts.  Papertrail recommends setting up log filters to discard the unnecessary log messages so that they don't count against my log data transfer quota.

But the question remains: What's generating all the log noise?  What to filter?

## JSON and jq to the Rescue

With a little bit of JSON and `jq` magic we can find this.  Grab the [`journalctl-sort-byprogram-frequency.jq` gist](https://gist.github.com/kylemanna/c6fc87b62ff404d41f6970a1927c4cb5) I made and give it a run:

    journalctl -o json --since "1 month ago" | jq -s -f systemd-journalctl-sort-by-program-frequency.jq

If all goes well you should be presented with an array of JSON objects sorted by most common offender last, for example:

    [
      {
        "name": "dbus",
        "length": 62
      },
      {
        "name": "mandb",
        "length": 67
      },
      {
        "name": "evince",
        "length": 74
      },
      {
        "name": "backup-borg.sh",
        "length": 104
      },
      {
        "name": "smartd",
        "length": 105
      },
      {
        "name": "gnome-shell",
        "length": 108
      },
      {
        "name": "org.gnome.Nautilus",
        "length": 111
      },
      {
        "name": "tracker-extract",
        "length": 206
      },
      {
        "name": "dbus-daemon",
        "length": 226
      },
      {
        "name": "systemd",
        "length": 368
      },
      {
        "name": "chromium.desktop",
        "length": 614
      },
      {
        "name": "backup-workstation",
        "length": 4133
      },
      {
        "name": "tracker-miner-f",
        "length": 5767
      }
    ]

Armed with this information, head back to [Papertrail](https://papertrailapp.com/?thank=384510) and setup your filters to drop the noise from `tracker-miner-f`, `chromium.desktop` and friends.

Or if you are so brave, attempt to fix the broken programs spewing all the noise.  Fair chance it's an upstream problem and it just spews cruft.  Also a fair chance the service is mis-configured and it's your fault.

Happy logging!
