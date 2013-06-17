---
layout: post
title: "Leveraging Upstart for User Jobs"
tagline: "not quite systemd, but almost as good"
category: linux
tags: [linux, ubuntu, upstart, imapfilter, spam]
---
{% include JB/setup %}

Ubuntu and Upstart
------------------

A while back Ubuntu switched from the classic bash script disaster know as SysV to upstart.  I won't even get started on how terrible SysV was, but it was pretty bad as it was all shell scripts, no dependencies, no events, no parallelization, no integrated process monitoring, cgroups, etc. 

I've used systemd before both in Fedora and embedded systems based around openembedded and loved it.  It seems more natural and powerful then upstart.  Upstart is what I have in Ubuntu (at least until I switch back to Fedora). So that's what I'll use today.

Bottom line is upstart is better then most init/process managers, with the exception of systemd.  Specifically I'm talking about the ghetto shell or scripted process manager you wrote because you didn't know any better...  Ahem, I mean what I wrote.

Additionally upstart will respawn daemons that die and manages logging stdout and stderr to some place useful (<code>~/.cache/upstart</code> for user session), manage stdout/stderr for logging, support for asynchronous events, etc.


Fixing My Mess
--------------

A while back I wrote a [blog post about imapfilter](/linux/2013/06/09/use-imapfilter-to-filter-spam-part2).  In that post I complained that imapfilter's daemon mode is useless as it terminates and exits when it encounters IMAP server errors.  After that my email is no longer filtered and I'm upset.  I then wrote a simple and quick python wrapper to babysit imapfilter.  Everything worked pretty well, but it all still felt wrong.

Today I got annoyed with the wrapper and autostart stuff so I removed it and re-implemented it upstart.  Now upstart handles starting imapfilter in the first place and respawning it when it dies.  Two birds, one stone.


Enabling Upstart User Sessions
------------------------------

First we need to enable upstart user sessions so that upstart fires up for my user when I login to the desktop.  I found a [blog post about Ubuntu user sessions](http://ifdeflinux.blogspot.com/2013/04/upstart-user-sessions-in-ubuntu-raring.html) that was very helpful.  In a nutshell you need to do the following and then re-login to Ubuntu:

	sudo sed -i 's/^#ubuntu/ubuntu/' /etc/upstart-xsessions


Setting up imapfilter
---------------------

Place the following in <code>~/.config/upstart/imapfilter.conf</code>:

	description "imapfilter"
	author "Kyle Manna <kyle@kylemanna.com>"

	# Start after keyring registers on dbus
	start on started dbus 
	#stop on desktop-end

	# Automatically restart process if crashed
	respawn

	# Log this job's stdout to ~/.cache/upstart/<name>.log
	# default is console log
	#console log

	# Start in foreground mode so it can be properly managed
	exec imapfilter -v

Now upstart will take of the rest.  It will setup the DBUS_SESSION_BUS_ADDRESS environment variable that the imapfilter python and lua scripts need set for accessing the user's key chain.  All magic, to start that magic run the following:

	start imapfilter

Imapfilter is now stated and all it's output will be in <code>~/.cache/upstart/imapfilter.log</code>.  An easy way to monitor it for debugging is <code>tail -f ~/.cache/upstart/imapfilter.log</code>.  Double check that upstart thinks imapfilter is running with:

	$ initctl status imapfilter
	imapfilter start/running, process 3459

And since the <code>start on started dbus</code> is in the job config file, the imapfilter task will be auto started every time the user logs in to the Ubuntu desktop session.  Logging in to the desktop session.  Set it and forget it.

Doing More
----------

Upstart user session jobs:

	$ initctl list
	xsession-init stop/waiting
	imapfilter start/running, process 3459
	dbus start/running, process 3458
	gnome-session start/running, process 3482
	ssh-agent start/running
	logrotate stop/waiting
	im-config start/running
	upstart-file-bridge start/running, process 3468
	gnome-settings-daemon start/running, process 3481
	re-exec stop/waiting
	upstart-event-bridge start/running, process 3463


Upstart user session global environment:

	$ initctl list-env
	DBUS_SESSION_BUS_ADDRESS=unix:abstract=/tmp/dbus-vGmn0j3MRp
	GNOME_DESKTOP_SESSION_ID=this-is-deprecated
	INSTANCE=
	JOB=dbus
	PATH=/home/nitro/bin:/usr/lib/lightdm/lightdm:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
	SESSIONTYPE=gnome-session
	SESSION=ubuntu
	SSH_AGENT_PID=3460
	SSH_AUTH_SOCK=/tmp/ssh-ZlMOWJzORL00/agent.3457
	UPSTART_EVENTS=started xsession


Documentation
-------------

* [Upstart Cookbook](http://upstart.ubuntu.com/cookbook/)
* [Upstart User Sessions in Ubuntu Raring](http://ifdeflinux.blogspot.com/2013/04/upstart-user-sessions-in-ubuntu-raring.html)
