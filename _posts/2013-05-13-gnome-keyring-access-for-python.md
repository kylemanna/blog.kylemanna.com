---
layout: post
title: "GNOME Keyring Access for Python"
tagline: "keepin' it secure"
category: security
tags: [linux, gnome-keyring, security, python]
---
{% include JB/setup %}

Overview
--------

Occasionally in scripts I need to securely store and then access user names and passwords to remote servers.  Less security concerned people might just hard code the clear-text values, but this doesn't sit well with me.  In some projects I've used OpenSSL or GPG to encrypt and decrypt files in some random format I made up on the spot.  OpenSSL wasn't a good idea because I would have to enter a password interactively to decrypt my other passwords.  GPG worked quite a bit better with gpg-agent (or in my case gnome-keyring which implements an gpg-agent) as the secrets to the keys could be cached in memory.


Revisit GNOME Keyring
---------------------

I stumbled on a [blog post](http://www.rittau.org/blog/20070726-01) where some someone had put together a very simple python module to interface to gnome-keyring called [Keyring](http://www.rittau.org/gnome/python/keyring.py).

The code is so simple and easy to use it's awesome.  I'm going to use this in place of other more hacky solutions (read GPG or OpenSSL described above).


What's GNOME Keyring?
---------------------

For those who don't know, GNOME Keyring is an integral part of all GNOME desktops (read: Ubuntu for those of you brain washed by Ubuntu Unity).  When you login, your keyring is unlocked.  When you logout it's locked.  This happens seamlessly in the background.  It may not be as secure as something more explicit, because any compromised processes running as my user or root can access it. Nevertheless, it's so convenient it's almost stupid to not use it for most semi-secure applications.

In addition to implementing it's own keyring for secret storage, it also implements a [broken GPG agent](/linux/2013/05/06/Ubuntu-13.04-gpg-issues/) and integrates with [ssh-agent](http://en.wikipedia.org/wiki/Ssh-agent).

Checkout [GNOME Keyring](https://live.gnome.org/GnomeKeyring) if you want to learn more.


Keyring Gist
------------

<script src="https://gist.github.com/kylemanna/5574193.js"></script>
