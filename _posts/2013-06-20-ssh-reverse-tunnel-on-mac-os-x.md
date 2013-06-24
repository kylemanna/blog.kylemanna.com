---
layout: post
title: "SSH Reverse Tunnel on Mac OS X"
tagline: "phone home"
category: osx
tags: [ mac, osx, ssh ]
---
{% include JB/setup %}

Phone Home
----------

I want to always be able to *securely* connect to my Mac Book Pro anywhere in the world.  The following guide will enable me to connect to the laptop if I leave it at home, leave it at work, or in the unfortunate event that someone steals it and the thief defeats File Vault full disk encryption.  This phone home technique will work as long as the laptop can create an outgoing ssh connection.  It will work behind NAT routers, but probably not behind strong corporate firewalls that only allow web proxy traffic out (something like corkscrew could help with this if you need it).

A lot of other people have written guides about how to do this and have done it wrong.  For example, people play tricks to avoid executing arbitrary commands by forcing ssh to execute something like /usr/bin/false.  If you don't to execute, don't execute anything.  Don't pretend not allocating a pty is secure, it's not, just prevents the obvious shell logins.  Furthermore, use the Mac OS X launchd correctly to create and maintain connections automatically, don't fork the ssh client, rely on the launchd KeepAlive feature.

In addition to the obvious purpose of connecting to a remote laptop that moves around alot, I've used this technique to circumvent poorly configured firewalls and to bring ad-hoc *servers* in other countries online before jumping on a transpacific flight with only 30 minutes to implement a "vpn".

Fun stuff.

Setup The Server
----------------

First step is to setup an <code>authorized_keys</code> file to allow logins for a private key, run the following on the client machine (Mac OS X laptop in my case).  If Elliptic Curve DSA (ECSDA) is available and supported on both ends, it can be used by adding "-t ecdsa" to the ssh-keygen command. Example default dsa key generation:

	client $ ssh-keygen -f ~/.ssh/servername-home-fwd
	Generating public/private rsa key pair.
	Enter passphrase (empty for no passphrase):
	Enter same passphrase again:
	Your identification has been saved in /Users/user/.ssh/servername-home-fwd.
	Your public key has been saved in /Users/user/.ssh/servername-home-fwd.pub.
	The key fingerprint is:
	3b:c7:7f:77:49:5d:5f:35:1d:82:ad:20:c8:7d:1e:d2 user@client
	The key's randomart image is:
	+--[ RSA 2048]----+
	|    . o .   o. .o|
	|     o + E . ...o|
	|        = o .   o|
	|         . .    o|
	|        S       =|
	|         o     .o|
	|        o o   . .|
	|         o .  ..o|
	|            .. ..|
	+-----------------+

Now a private key has been generated, read the public key on the client and copy it:

	client $ cat ~/.ssh/servername-home-fwd.pub

On the server paste the private key on it's own line in <code>~/.ssh/authorized_keys</code> or use <code>ssh-copy-id</code> for easy installation if available. Prefix the public key with <code>command="",no-pty</code> to prevent any commands from being executed using this private key and to prevent wasting resources for a pty (not a security feature).  Optionally add a comment to the end so you can keep track of the purpose of this installed public key.  The result should look something like the following:

	server $ cat ~/.ssh/authorized_keys
	command="",no-pty ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDUWUrEMfnP65pGSwdLFP323K7AG8Ah5JC0ArC660z7V0i3wSBf1lXnN3coc/ndw7C7NQw+wLTNp7FjkxheyNiMhf65pZI41HR+JJleQsAwCCpFwftKutfknpvai6FRkfE173iXGAU5YFGmlHBo3oAiSn09ZOAXieZ0+Sr0ZEAF5gJLLG4E94JUdEtCXcLYPWu0YX//k+PVvaK1/IjJ6gJGbzT+KA5Gv4VZecL+UC7VvgtcO6UBVNHo4eQBPdhiT1Asg71e3io2y+AwGg0J2smBcuhmrf3ud/BFNgHFjF3a7ilF2Hh7AYV16rRJrOazH83IBzgiBysiakF3OSHQXozV client@server:phone-home

Now you've allowed any remote machine to login to the user machine on the server with the private key generated above (~/.ssh/servername-home-fwd).  The login won't be able to run *any* commands and won't be able to allocate a pty (which probably is pointless after no command execution, better safe then sorry).

Additionally, if it's possible to modify the sshd_config file on the server, it should be modified to send ssh alive packets (similar to TCP keep alive) packets to the client.  Root access on the server is typically necessary for this.  On an Ubuntu server this can be accomplished with:

	server $ echo "ClientAliveInterval 60" | sudo tee -a /etc/ssh/sshd_config
	server $ sudo restart ssh
	ssh start/running, process 6446

The above modification will ping the client every 60 seconds the connection is idle as defined the <code>ClientAliveInterval</code> which is disabled by default.  If <code>ClientAliveCountMax</code> (defaults to 3) number of pings go unanswered, the server will drop the connection.  This is critical to detecting the remote client has disappeared and freeing up the port defined below for a reconnect from the client when it comes back online.  It isn't strictly necessary as the server will drop the connection after a while on its own, but significantly speeds up reconnects.


Test the Server Setup from the Client
-------------------------------------

Verify that the server is correctly setup by running the ssh command manually.  This is important for two reasons:
1. The first time the ssh client connects to the server, it by default needs the user to manually accept the host's ssh key.  This will never succeed in the automated launchd task described below and must be done ahead of time.
2. Verify nothing is broken.

To test the configuration, run the following:

	client $ ssh -NT -R 12345:localhost:22 remoteuser@servername

The result should be that the command blocks and appears to hang.  At the same time, verify that port 12345 is now listening on the server.  If port 22 on the client is in fact the ssh server this can be quickly tested by reading some data over the connection such as the SSH server's version using netcat:

	server $ netcat localhost 16768
	SSH-2.0-OpenSSH_5.9

After testing is complete, use CTRL-c to break both the ssh and netcat command.  If something didn't work, double check the steps above for errors before proceeding.


Setup The Client on OS X
------------------------

Apple uses launchd to launch system services.  The purpose of launchd is very similar to [Ubuntu's upststart](http://upstart.ubuntu.com/) and [Freedesktop's systemd](http://en.wikipedia.org/wiki/Systemd) in that it's goal is to start services and manage them.

In a nuthsell the primary features needed for this phone home script are:
1. Run at start-up without user intervention
2. Run as another user
3. Restart a process when it dies

First, we need to setup a plist file for OS X, create the following file and modify it as necessary for items such as the user and host name, place the following @ /Library/LaunchDaemons/server.name.client.name.home.plist

	<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">
	   <dict>
	   <key>Label</key>
	   <string>server.name.client.name.home</string>
	   <key>ProgramArguments</key>
	   <array>
		  <string>ssh</string>
		  <string>-NTC</string>
		  <string>-o ServerAliveInterval=60</string>
		  <string>-o ExitOnForwardFailure=yes</string>
		  <string>-i</string>
		  <string>/Users/<username>/.ssh/servername-home-fwd</string>
		  <string>-R 12345:localhost:22</string>
		  <string>remoteuser@servername</string>
	   </array>
	   <key>UserName</key>
	   <string>user</string>
	   <key>RunAtLoad</key>
	   <true/>
	   <key>KeepAlive</key>
	   <true/>
	</dict>
	</plist>

This will switch to <code>Username</code> *user* on the Mac OS X client and then attempt to run the ssh command described by <code>ProgramArguments</code>.  SSH command description:

* <code>-N</code> - Don't run a remote command.  Attempting to run a remote command will fail due to the restrictions imposed by the authorized_keys file.
* <code>-T</code> - Disable pty allocation.  There is no need for this when only port-forwarding is desired.
* <code>-C</code> - Request compression.  This is optional, typically my processors out pace my network speed, especially when on 4G/LTE networks.  This is optional.
* <code>-o ServerAliveInterval=60</code> - The client will attempt to send pings to the server ever 60 seconds.  After 3 failed pings (Default <code>ServerAliveCountMax</code> is 3), the client will drop the connection and ssh with return.
* <code>-o ExitOnForwardFailure=yes</code> - If port forwarding fails to get setup due to something like another process (or old ssh process) being bound to the hardcoded port, fail and return.
* <code>-i /Users/&lt;username&gt;/.ssh/servername-home-fwd</code> - Use the specified ssh private key (generated above) for this connection.  This must be the the private key for the public key in the authorized_keys file on the server.
* <code>-R 12345:localhost:22</code> - Remotely forward the localhost port 22 (sshd) to the server's port 12345.  This allows the server to connect to the client's ssh port.
* <code>remoteuser@servername</code> - Connect to ssh servername with user remoteuser.

When the ssh tunnel dies due to a change in network connection or fails to setup the initial port forwarding as requested, the launchd manager will restart it in 10 seconds due to the <code>KeepAlive</code> key.  The default restart time is 10 seconds and should work just fine for this task.

The <code>RunAtLoad</code> does as the name suggests and runs this launchd task at load and boot time.

If all goes according to plan, the launchd plist can be loaded and it will connect to the server:

	sudo launchctl load /Library/LaunchDaemons/server.name.client.name.home.plist

Launchd will start up ssh as directed by the plist and connect to the remote server.  The netcat command described above can be run on the remote server to verify it's working.  If it's not working, check the logs on the client and server under /var/log for hints as to what went wrong.  After modifying the plist file, be sure to unload it and then reload it by changing "load" to "unload" in the command described above followed again by "load."

If it is working, your Mac OS X will automagically open a reverse tunnel to the server described above.  You can then login to the client Mac OS X machine by using <code>ssh -p12345 user@localhost</code> on the server.  Note that the host will always be localhost due to port forwarding, and the user is the user on the Mac OS X client.


Doing Event More
----------------

I'm looking only to ssh back in to my laptop, but with a few modifications to the launchd plist, it's possible to use this to setup ssh vpn tunnels using tun interfaces.  Refer to the ssh man page for the the "-w" option.  You'll need to setup routes and what not to fully use it.  Things get complicated quick and many times OpenVPN is a better solution.

Other uses? Let me know!
