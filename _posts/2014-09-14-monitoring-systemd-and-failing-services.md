---
layout: post
title: "Monitoring systemd and failing services"
tagline: "Feedback is good"
category: linux
tags: [linux, systemd, email, monitor]
---
{% include JB/setup %}

## No Emails on Failed Tasks?

I've been slowly working to conver my cron jobs on my workstation to run as systemd timers.  For the most part it has been going awesome, systemd is so powerful and many things are no long relevant (i.e. cron script collisions and file locks).

On the negative side, cron used to send me emails when tasks would fail and return a non-zero status code.  This was critical for things like backups that I don't want to silently fail forever.  What can systemd do about this? Not much by default it seems.


## OnFailure

At first I discovered the `OnFailure` option for unit section of systemd service files.  It would start up a service on a failure, but unfortuntately doesn't convey much state to the failure service.  I used an instance name to pass on to the failure service.

The major downside is that this would need to be configured for every service I want to monitor.  I lost interest, mostly.  I dumped what I had on github, people can find it @ [kylemanna/systemd-utils/onfailure](https://github.com/kylemanna/systemd-utils/tree/master/onfailure).


## Manual Parsing journalctl

At first this seems hacky due to the absurd about of string parsing, but until I find something better, this will work for now.  I wrote a service called `failure-monitor` and it's also on github @ [kylemanna/systemd-utils/failure-monitor](https://github.com/kylemanna/systemd-utils/tree/master/failure-monitor).

The service consists of two parts: a python file that does the work and a systemd service file to run the python script.  The python script fires up and follows the journalctl log file looking for "entered failed state".  When the magic string is encountered it parses some things and sends an email.  Simple as that.  Service startup is managed by systemd and works as most systemd services.  The instance name is used as a hacky way to provide the destination email address in a configurable manner.

The service makes alot of naive assumptions like there is a local mail server running (postfix in my case) and it just works.

Hopefully other people can chime in and help improve these services.  Maybe systemd will get a active response system for failure. It currently has a method to upload logfiles to servers, but that seems overkill for my workstation.
