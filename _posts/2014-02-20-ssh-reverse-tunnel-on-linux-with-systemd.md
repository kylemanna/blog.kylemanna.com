---
layout: post
title: "SSH Reverse Tunnel on Linux with systemd"
tagline: "phone home"
category: linux
tags: [ linux, archlinux, systemd, ssh ]
---
{% include JB/setup %}

Phone Home
----------

This aims to do all the same things my [SSH Reverse Tunnel on Mac OS X](/osx/2013/06/20/ssh-reverse-tunnel-on-mac-os-x/) blog, except this is for Linux systems running systemd.  Systemd as a process monitor makes an awesome way to implement the phone home ssh service.

I'm going to skip most of the details and justification for doing this and instead defer interested readers to my [previous blog entry](/osx/2013/06/20/ssh-reverse-tunnel-on-mac-os-x/).


Setup the Server
----------------

All the steps are the same, except nowadays I'd recommend generating a [ECDSA](https://en.wikipedia.org/wiki/Elliptic_Curve_DSA) key.  By default my Arch Linux systems makes a ECDSA key with a 256-bit length.  This is very similar to the ECDSA algorithm used for things like Bitcoin, but this uses the NIST P-256 curve (Bitcoin uses secp256k1).

    client $ ssh-keygen -f ~/.ssh/servername-home-fwd -t ecdsa

As my previous blog instructs, copy the key over to the server and install it in the <code>authorized_keys</code> file.

Astute readers will note the shorter length of the ECDSA public key.  Depsite the shorter length, a 256-bit ECDSA key is believed to be stronger then the standard RSA 2048 key ssh-keygen would use by default (see [keylength.com](http://www.keylength.com) for more details).


Setup the Client
----------------

Now to setup the client running systemd (Arch Linux in my case), is approximately the same, except that systemd is used instead of launchd on Mac OS X.

To do this, a system service file is necessary, as opposed to a systemd user service running in the user's session.  The system file can be enabled by the system at boot.  Typically system files run as root, so it's necessary to specify the user tag to avoid running the ssh client as root.

Create the systemd unit file @ <code>/etc/systemd/system/phone-home.service</code>:

    [Unit]
    Description=Phone Home Reverse SSH Service
    ConditionPathExists=|/usr/bin
    After=network.target

    [Service]
    User=localuser
    ExecStart=/usr/bin/ssh -NTC -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -o StrictHostKeyChecking=no -i %h/.ssh/servername-home-key -R 12345:localhost:22 remoteuser@servername

    # Restart every >2 seconds to avoid StartLimitInterval failure
    RestartSec=3
    Restart=always

    [Install]
    WantedBy=multi-user.target

The <code>local user</code> is the user that the ssh client will run as, *not* root.  The ssh client will login to <code>servername</code> as user <code>remoteuser</code> using key <code>servername-home-key</code> and forwards the client's local port <code>22</code> to the remote server's port <code>12345</code>.

After that file is modified, start the service:

    client $ sudo systemctl restart phone-home.service

Check to see if it started:

    client $ sudo systemctl status -l phone-home.service
    phone-home.service - Phone Home Reverse SSH Service
       Loaded: loaded (/etc/systemd/system/phone-home.service; enabled)
       Active: active (running) since Thu 2014-02-20 20:40:32 PST; 4min 45s ago
     Main PID: 2559 (ssh)
       CGroup: /system.slice/phone-home.service
               └─2559 /usr/bin/ssh -NTC -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -o StrictHostKeyChecking=no -i /home/user/.ssh/core-home-fwd -R 12345:localhost:22 remoteuser@servername

    Feb 20 20:40:32 recon systemd[1]: Started Phone Home Reverse SSH Service.

Finally, enable it to start at boot:

    client $ sudo systemctl enable phone-home.service
    ln -s '/etc/systemd/system/phone-home.service' '/etc/systemd/system/multi-user.target.wants/phone-home.service'

Profit.


Next Steps
----------

Unfortunately there isn't an easy way to hook in to the network state and only start this service when the network is up.  Perhaps this will be easier to fix in the future as systemd evolves with Linux distributions.  Ideally it would be nice to say "start this if there is a default route that likely leads to the Internet".

Instead, the current implementation is a service that will attempt to connect to a remote server every 2 minutes and fail, not the end of the world but not perfect -- yet.
