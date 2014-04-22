---
layout: post
title: "Two Factor (2FA) SSH Authentication Using YubiKey"
tagline: "Keeping the baddies out"
category: 
tags: [ssh, yubikey, yubico, 2fa, security, linux, arch]
---
{% include JB/setup %}

The Yubikey works by taking an AES-128 encrypted message and sending it Yubico's authentication server.  If the AES private key is stored on Yubico's server and the contents of the encrypted message are validated (counter, serial no, etc) then a verified result is returned, else fail.

The Linux PAM module will use the result to allow access to the machine in addition to a user's regular password.

A user would use the 2FA (two factor authentication) system by sshing in to a remote machine, typing their password followed immediately by the YubiKey's encrypted message (modhex encoded).  If everything checks out the user is permitted access and the rest of the session continues as normal.

These are my brief notes on my YubiKey authentication setup on Arch Linux.

Prerequisites
=============

* A physical YubiKey, I have the YuibKey Standard.  Thinking about a Neo.
  * YubiKey is configured for Yubico OTP which is the default for slot 1 (aka short press).
  * The Yubikey needs to have its Yubico OTP AES key uploaded to YubiCo's authentication server.
  * Test all of this [Yubico's Demo Site](http://demo.yubico.com/?tab=one-factor)
  * YubiKey public ID, available from the demo site or by reading the first 12 characters of short press (ie run <code>head -c 12</code> in the console and then press the YubiKey).
* Necessary libraries and dependencies installed, for Arch users it's as simple as:

      yaourt yubico-pam-git


System Modifications
====================

These steps were run on an Arch Linux machine and are likely slightly different for every other distro.

1. Modify <code>/etc/pam.d/system-remote-login</code> to match the following, note the addition of the pam_yubico.so line:

       #%PAM-1.0

       auth      required  pam_yubico.so id=1
       auth      include   system-login
       account   include   system-login
       password  include   system-login
       session   include   system-login

2. Create a <code>~/.yubico/authorized_yubikeys</code> file for each user with the following format:

       <username>:<yubikey id from pre-reqs>

3. Attempt to ssh in to the local box <code>ssh user@localhost</code> and type the user's password followed by a short YubiKey press.  The system should login.
4. Whenever configuring PAM, verify that security isn't broken.  Try typing no password, wrong password, with/without YubiKey, with/without authorized_yubikeys file, with invalid entry in authorized_yubikeys file.  Also be cautious of ssh multiplexing (connection sharing) as it may skip authentication and re-use / multiplex an existing connection.  This could be misleading.


Debugging
=========

If the above steps don't work, turn on debugging:

1. Add <code>debug</code> option to the end of the pam_yubico.so line in <code>/etc/pam.d/system-remote-login</code>

2. Create the debug log file:

        sudo touch /var/run/pam-debug.log
        sudo chmod go+w /var/run/pam-debug.log

3. Tail the logs looking for clues while debugging:

        sudo journalctl -f -l
        tail -f /var/run/pam-debug.log

4. Disable debugging by removing the debug option and removing the log file.


Documentation
=============

* Man page: <code>man pam_yubico</code>
* Documentation: [yubico-pam wiki](https://github.com/Yubico/yubico-pam/wiki)


Security Implications
=====================

The security is at least as strong as the original password, the second factor could be bypassed in the following cases:

* The AES private key of the Yubikey is compromised.  Could be compromised by a very sophisticated via [side-channel attack](http://youtu.be/_c1cx8F4-SM?t=36m30s) or if the key was regenerated or submitted to Yubico insecurely using YubiKey Personalization app.
* An adversary installs a trusted CA on the target machine and performs a man-in-the-middle attack when the pam_yubico attempts to contact Yubico.
* An adversary could modify <code>~/.yubico/authorized_yubikeys</code>.
* If the PAM files were incorrectly modified all security could be compromised (test!!!).
