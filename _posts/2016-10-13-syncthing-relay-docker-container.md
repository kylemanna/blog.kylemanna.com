---
title: "Syncthing Relay Docker Container"
excerpt: "The easiest way to setup and run a Syncthing Relay using Docker and systemd."
category: sharing
tags: [linux, docker, syncthing, systemd, relay, sharing]
header:
  image: https://i.imgur.com/eGEW5JC.png
  overlay_color: "#000"
  overlay_filter: "0.5"
  overlay_image: http://i.imgur.com/kc3cqYy.jpg
---

## What's a Syncthing Relay?

A [Syncthing Relay server](https://docs.syncthing.net/users/strelaysrv.html) helps to relay data between Syncthing nodes that couldn't otherwise talk directly.  To quote the [Syncthing docs](https://docs.syncthing.net/users/relaying.html):

> Syncthing can bounce traffic via a relay when it’s not possible to establish a direct connection between two devices. There are a number of public relays available for this purpose. The advantage is that it makes a connection possible where it would otherwise not be; the downside is that the transfer rate is much lower than a direct connection would allow.

If you have a server on the Internet with spare bandwidth (100GB+/mo) and want to host a public relay, then read on!

## Traditional Methods

The traditional way to hose the Syncthing Relay is to build the binary with a Go compiler and run it locally.  If you're lucky, there is a pre-built binary available or a package for your Linux distribution.  This works fine for most people, but I like to keep services contained as they are easier to update and are somewhat isolated from my primary operating system.

Docker helps to do just that.  The Syncthing Relay server is very simple and has no persistent state that needs to be maintained across service starts or upgrades.

## Testing the Docker Image

Run the Docker container manually to check for firewall or network problems by running the following:

    docker run --rm -p 22067:22067 -p 22070:22070 kylemanna/syncthing-relay

You should see something like this in your console:

    ❯❯❯ docker run --rm -p 22067:22067 -p 22070:22070 kylemanna/syncthing-relay
    Started Syncthing Relay Docker Container.
    2016/10/14 01:25:24 main.go:123: strelaysrv v0.14.8+13-g05c37e5 (go1.7.1 linux-amd64) jenkins@build.syncthing.net 2016-10-12 20:55:38 UTC
    2016/10/14 01:25:24 main.go:129: Connection limit 52428
    2016/10/14 01:25:24 main.go:142: Failed to load keypair. Generating one, this might take a while...
    2016/10/14 01:25:29 main.go:218: URI: relay://0.0.0.0:22067/?id=...&pingInterval=1m0s&networkTimeout=2m0s&sessionLimitBps=0&globalLimitBps=0&statusAddr=:22070&providedBy=
    2016/10/14 01:25:29 main.go:221: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    2016/10/14 01:25:29 main.go:222: !!  Joining default relay pools, this relay will be available for public use. !!
    2016/10/14 01:25:29 main.go:223: !!      Use the -pools="" command line option to make the relay private.      !!
    2016/10/14 01:25:29 main.go:224: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    2016/10/14 01:25:30 pool.go:55: Joined https://relays.syncthing.net/endpoint rejoining in 48m0s

You should see something similar on your machine and verify that the IP address of your server shows up on the [Syncthing Relay status page](http://relays.syncthing.net/).

Something went wrong if the last line doesn't say "Joined ..." and the [Syncthing Relay status page](http://relays.syncthing.net/) doesn't list your server as well. The most likely cause is you may have a problem with a firewall.  Ports `22067/tcp` and `22070/tcp` need to be forwarded.  Docker should forward these on the local machine, but if there is an upstream firewall or NAT router, you'll need to pass the traffic through.

I received the following error before I properly configured my firewall:

    2016/10/14 01:25:30 pool.go:55: Failed to join https://relays.syncthing.net/endpoint due to an internal server error: test failed

Hit `CTRL-C` to stop the Docker container.

## Automate the Docker Container

The command above ran in the current terminal, but we can do better by handing over the reigns to [systemd](https://www.freedesktop.org/wiki/Software/systemd/) service manager.  Systemd will pull updates for the [kylemanna/syncthing-relay](https://hub.docker.com/r/kylemanna/syncthing-relay/) image and start the container at boot time.  Each time waiting for the network and Docker daemon to start-up.  Should the Syncthing Relay service exit, systemd will wait 10 seconds and restart it.

All that's needed to is to install a [systemd service file](https://www.freedesktop.org/software/systemd/man/systemd.service.html) that instructs systemd how to operate.

### First — Install the Systemd Service File

    cd /etc/systemd/system
    sudo curl -O https://raw.githubusercontent.com/kylemanna/docker-syncthing-relay/master/init/docker-syncthing-relay.service
    sudo systemctl daemon-reload

### Second — Start the Service and Verify Operation

    sudo systemctl start docker-syncthing-relay.service
    sudo systemctl status docker-syncthing-relay.service

You should see similar output to the testing section above.

### Third — Enable the Service

    sudo systemctl enable docker-syncthing-relay.service

Systemd will now automatically start the Syncthing Docker container at boot time.

## Learn More

Upstream Links:

* [GitHub Source Repository](https://github.com/kylemanna/docker-syncthing-relay)
* [Docker Hub Image Repository](https://hub.docker.com/r/kylemanna/syncthing-relay/)
