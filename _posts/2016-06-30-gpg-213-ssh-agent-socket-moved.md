---
layout: post
title: "GPG 2.1.3 SSH Agent Socket Moved"
description: ""
category: linux
tags: [gpg, linux]
---
{% include JB/setup %}

## Why'd my gnupg ssh agent break?

Apparently gnupg-2.1.3 changed the default `ssh-agent` socket from `$HOME/gnupg/S.gpg-agent.ssh` to `$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh` where `XDG_RUNTIME_DIR=/run/user/1000`.  After realizing this (which doesn't appear in the gpg-agent man page) I was on my way with an update to `$SSH_AUTH_SOCK` to reflect the new path.

My Arch Linux system upgraded to gnupg-2.1.3 when this happened.  I quickly poked around the repository and [this commit](https://git.gnupg.org/cgi-bin/gitweb.cgi?p=gnupg.git;a=commit;h=aab8a0b05292b0d06e3001a0b289224cb7156dbd) seems related.

Turns out I'm not crazy, it did silently move.

