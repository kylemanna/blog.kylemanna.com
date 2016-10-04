---
title: "Logging All the Things with Rsyslog and Papertrail"
excerpt: "How to setup rsyslog to log all things (including systemd journald) to a remote endpoint in the Papertrail cloud using a secure TLS connection."
category: linux
tags: [linux, cloud, logging, systemd, rsyslog, papertrail]
header:
  image: https://i.imgur.com/eGEW5JC.png
  overlay_color: "#000"
  overlay_filter: "0.5"
  overlay_image: https://i.imgur.com/eGEW5JC.png
---

## Keeping Track of Problems

While wrestling around with setting up failure event tracking for a new server using systemd and my [onfailure hack](/linux/monitoring-systemd-and-failing-services/) I was reminded of [Papertrail](https://papertrailapp.com/?thank=384510).  On a past project we used Papertrail to aggregate logs until we out grew it and moved to the ELK stack.

In the interest of keeping things simple I figured I could just funnel all my logs from Arch Linux, Ubuntu and Raspbian (aka Debian) cloud servers and real boxes to the Papertrail cloud and setup alerts using their free service tier.

Before committing to that, I poked around a bit to determine if Papertrail was still the best option.

## Cloud Logging Services

High level requirements:

1. Record events from syslog and journalctl
2. Use an encrypted TLS transport
3. Ability to setup alerts and email me
4. Short term retention

### Papertrail

I had a good experience with [Papertrail](https://papertrailapp.com/?thank=384510) in the past.  Their support was quick and practical on a past paid servce.  The free service would cover my modest personal requirements.  Tailing the logs from their web UI is fast an efficient, log entries arrive to my browser in under a second.  The free service plan includes up to 48 hours of search and 7 day archive which seems like plenty for my needs.

Furthermore, the plans are reasonable at $7/mo for the next step on my personal project servers.  Other services have a much bigger first step.

The downsides are minor.  They don't seem to offer any structured logging, but I don't *really need* structured logging.  Also, their documentation and configuration guides for things like rsyslog are out of date by at least 1 major release, but I can bridge the gap.

### Elasticsearch + Logstash + Kibana

I've used [Elasticsearch](https://www.elastic.co/products/elasticsearch) with [Logstash](https://www.elastic.co/products/logstash) and [Kibana](https://www.elastic.co/products/kibana), aka the ELK stack, in the past and I know this will be overkill.  Way overkill.  I want to make my logging situation simpler, not add more work by adding more servers.  Not even viable unless I had a real project.

Maybe another day when I'm looking for more power and have too much free time on my hands.

### Loggly

I stumbled on [Loggly](https://www.loggly.com/) while wrestling with rsyslog and syslog-ng (more on this later). Their free plan doesn't have live log tailing or email alerts.  Practically useless for me, and the next step up for monthly plans blows the budget at $50/mo.  Not practical for minor personal projects.

They do appear to have many more features then Papertrail and their configuration documentation seems more elaborate and up to date.

### Everyone Else

I didn't dig too deep since the major providers like Amazon CloudFront and Google StackDriver.  These seemed overkill for what I need, and make even less sense to me unless I'm using their other cloud services.

## Logging Clients

The task started simple enough: Take journald entries, and feed them to the cloud.  Simple as that on Arch.  But my Raspbian and Ubuntu servers still run a hacked up mess up journald + rsyslog because... legacy.  So, this got more complicated.

### Syslog-ng

Seemed like a nice modern choice at first.  But, Papertrail will drop idle connections after 15 minutes, so it needed a [patch](https://github.com/balabit/syslog-ng/pull/1214) to fix borken TCP keep-alive support.  I started running around building packages with patches for Raspbian and Ubuntu, but gave-up when I learned that they were already running rsyslog.

Which leads too....

### Rsyslog

Available on Arch Linux, default install on Debian Jessie (aka v8) based distros like Raspbian and Ubuntu.  How about KeepAlive?  Available, but [docs are wrong](https://github.com/rsyslog/rsyslog-doc/pull/259).  This is a trap intentionally planted here to trick up young players.  Maybe.

The `rsyslog-gnutls` package on Debian based distros adds the required TLS support.  Good.  Only complaint is that it seems to hang upon SIGTERM.  Seemed fine with the UDP transport, but the TCP+TLS transport seems broken.  I'm not digging in to this, I feel like I'll setup my own ELK cluster before I "fix" unstructured syslog puke.

Right now I'm learning to tolerate the restart hang, shouldn't be a problem in normal operation, and maybe someday someone will fix it.  Systemd pulls out SIGKILL to dispense justice to poorly written daemons and keeps reality in check.

### Remote_syslog

I looked at Papertrail's [remote_syslog](https://github.com/papertrail/remote_syslog) daemon.  After I learned it just read and tailed flat files I ran away.  Thought about adding [sd-journal(3)](https://www.freedesktop.org/software/systemd/man/sd-journal.html) support, but decided this was still a bad idea.

### Perfect World

In a perfect world Papertrail and friends would add a [systemd-journal-gateway](https://www.freedesktop.org/software/systemd/man/systemd-journal-gatewayd.service.html) and I could just upload structured journald data.  This is a project for another day, month, or year.  Hopefully someone will beat me to it.

## Configuration

Enough will all the babbling about what service and why in the end it was Papertrail + rsyslog.  Configuration is reasonably simple.

### Step 1 - Create a Papertrail account

Create an account, record your remote syslog server's hostname and port number.  Ensure TCP + TLS support is enabled.

### Step 2 - Install a recent version of rsyslog

A recent version of rsyslog with Keep-Alive support is needed to avoid dropped connection, I used 8.21.0 without issue.  I had to build newer packages on Raspbian myself and used the Ubuntu PPA for v8-stable.

### Step 3 - Configure rsyslog

This is where the headache begins and differs by distro.

Install the certificate bundle:

    sudo curl -o /etc/papertrail-bundle.pem https://papertrailapp.com/tools/papertrail-bundle.pem

The current MD5 checksum according to the [Papertrail docs](http://help.papertrailapp.com/kb/configuration/encrypting-remote-syslog-with-tls-ssl/) is `ba3b40a34ec33ac0869fa5b17a0c80fc`.

#### Debian

On Debian based distributions it's probably as simple as adding a file at `/etc/rsyslog.d/10-papertrail.conf`:

    $DefaultNetstreamDriverCAFile /etc/papertrail-bundle.pem # trust these CAs

    action(type="omfwd" Target="logsXX.papertrailapp.com" Port="12345" Protocol="tcp"
           KeepAlive="on" KeepAlive.Time="600"
           StreamDriver="gtls" StreamDriverMode="1" StreamDriverAuthMode="x509/name"
           StreamDriverPermittedPeers="*.papertrailapp.com")

Update the `Target` and `Port` as appropriate, restart rsyslog and hopefully everything works:

    sudo systemctl restart rsyslog

#### Arch Linux

On Arch Linux we have more work to do because journald doesn't feed syslog by default.

First, blow away the default config with this short config at `/etc/rsyslog.conf`:

    $ModLoad imuxsock   # provides support for local system logging

    $DefaultNetstreamDriverCAFile /etc/papertrail-bundle.pem # trust these CAs

    action(type="omfwd" Target="logsXX.papertrailapp.com" Port="12345" Protocol="tcp"
           KeepAlive="on" KeepAlive.Time="600"
           StreamDriver="gtls" StreamDriverMode="1" StreamDriverAuthMode="x509/name"
           StreamDriverPermittedPeers="*.papertrailapp.com")

Update the `Target` and `Port` as appropriate.

Next, edit `/etc/systemd/journald.conf` and append `ForwardToSyslog=yes`

    echo 'ForwardToSyslog=yes' | sudo tee /etc/systemd/journald.conf

Restart and enable rsyslog and hopefully everything works.

    sudo systemctl enable rsyslog
    sudo systemctl restart rsyslog

### Step 4 - Test

Most distros should have the `logger` utility, generate log events and they should show up on your Papertrail stream in a second or two.

    logger Hello World @ $(date)


### Step 5 - Set-up Alerts

Using the Papertrail web app you can easily create email notifications when certain things go wrong.  For example, I have an alert for `systemd Failed to start` to notify me of failed system services.

## Conclusion

Papertrail is cloud logging that offers email alerts, tail view and a grep like search.  Nothing less and nothing more.  Rsyslog is a logging daemon that can be re-purposed to shuttle your syslog or journald log events to the Papertrail cloud with TLS support.  Keep-alive support was added to the rsyslog config to remove extraneous reconnect log events as Papertrail drops connections that idle for 15 minutes.

Let me know how it goes!  Look me up on [Twitter](https://twitter.com/2bluesc) or whatever social media service you fancy.
