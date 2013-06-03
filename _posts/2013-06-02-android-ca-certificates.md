---
layout: post
title: "Android CA Certificates"
tagline: "where to put it"
category: android
tags: [linux, android, openssl, certificates]
---
{% include JB/setup %}

Use Case
--------

Developing Android applications sometimes requires debugging requests to and from servers.  The easiest way to do this is with a something that can sniff wireless traffic like tcpdump or wireshark.  However, this doesn't work when the communication is with HTTPS / SSL servers.

Man in the Middle Proxy (mitmproxy)
-----------------------------------

Luckily, there exists a tool called [mitmproxy](http://mitmproxy.org/).  Mitmproxy works by intercepting SSL connections, generating certificates, and then proxying the original requests.  In order to communicate using SSL, the Android client needs to be able to authenticate the certificate chain back to a root certificate it trusts.  To accomplish this, mitmproxy generates certificates on the fly for the site requested.  Fortunately, for security reasons, it's impossible for mitmproxy to ever generate a trusted certificate, so instead it generates its own root certificate authority (root CA).  The user needs to install this root CA certificate on the clients under test to complete the certificate chain.

In my case, I was running mitmproxy on a gateway Linux router and transparently relaying http and https traffic through it for debugging.  Mitmproxy's website has a lot of documentation on how to set this up.  All clients (in my case Android clients and my laptop) were relayed through the server.  Both of these devices had the root CA certificate installed.

Installing a root CA certificate on Android
-------------------------------------------

Android stores all of the trusted root CA certificates under <code>/system/etc/security/cacerts/</code>.  Inspecting this directory will reveal all the root CA certificates names are hashed, but the hashing method isn't immediately obvious.  To properly install the certificate, all that needs to happen is to hash the root CA certificate mitmproxy generated and install it in the right spot.

This can be accomplished with the following shell script:

	#!/bin/bash
	CERT=$HOME/.mitmproxy/mitmproxy-ca-cert.cer
	#CERT=$1
	NAME=$(openssl x509 -in $CERT -subject_hash_old -noout)
	cp ${CERT} ${OUT}/system/etc/security/cacerts/${NAME}.0


It may be necessary to remount the /system file system as read-write as it's normally read-only.  This can easily be achieved as long as the user has root access to the board.  Furthermore, to write to this directory, root access is likely needed as well.

That's it, https server &lt;-&gt; client traffic can now be easily debugged, modified, and recorded.

Mac OS X
--------

The same can be done with Mac OS X, users need to install the certificate in the user's keychain.  Ensure that the mitmproxy root CA certificate is marked as "trusted" after it's installed in to the keychain.

Web browsers should show mitmproxy as the certificate issuer when loading https websites.
