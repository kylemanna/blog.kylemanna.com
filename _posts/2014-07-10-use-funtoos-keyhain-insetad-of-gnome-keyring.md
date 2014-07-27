---
layout: post
title: "Use Funtoo's Keychain Instead of GNOME Keyring"
tagline: "because of missing features"
category: linux
tags: [linux, ssh, ssh-agent, keys, keyring, arch]
---
{% include JB/setup %}

## Why Disable GNOME Keyring?

Quite simply, GNOME Keyring still doesn't have have support for `ed25519` keys that I want to use it.

Also, I'm a bit paranoid and don't want things to *help* manage my keys without being explicit.  I don't trust GNOME keyring to not try and help me and cache some passphrase behind my back unless I'm really careful.  Furthermore, it may get updated in the future to me more *user friendly*.

## What Starts GNOME Keyring?

A few minutes ago I would have said I explicitly start GNOME keyring via `.xinitrc`.  That's the way I set it up a while ago when I setup my Arch configuration with Cinnamon.  However, these days it's started by `/etc/xdg/autostart/gnome-keyring-ssh.desktop` and there doesn't appear to be an easy way to disable it (i.e. configuration panel setting).

This was certainly a surprise when I couldn't understand why my `eval %(ssh-agent)` line in my `.xinitrc` file wasn't working correctly, yet was starting an agent.  The autostart desktop file was overriding my `SSH_AUTH_SOCK` environment variable.

## How Can GNOME Keyring Be Disabled?

According to [Desktop Application Autostart Specification](http://standards.freedesktop.org/autostart-spec/autostart-spec-latest.html), the autostart file can be overridden.  A file with the same name must be found in a more *important* directory.

## Alternative: Keychain

[Keychain](http://www.funtoo.org/Keychain) is a tool to manage your ssh and gpg agents for you.  The intent is to have long running agents that transcend X sessions (read: crashes).  It easily pulls in the relevant environmental variables to your shell init scripts.

I first started using it back in my Gentoo days and abandoned it to give GNOME Keyring a chance.

## Setup Funtoo on Arch

1. Install `keychain`:

        pacman -S keychain

2. Disable GNOME Keyring's laggy GPG and SSH agent implementations, you'll need to exit your running X session for these to happen. Luckily `keychain` takes care of all the agent management for us.

        cat << EOF > ~/.config/autostart/gnome-keyring-ssh.desktop
        [Desktop Entry]
        Type=Application
        Name=SSH Key Agent (keychain)
        Exec=keychain --quiet --agents ssh

        cat << EOF > ~/.config/autostart/gnome-keyring-gpg.desktop
        [Desktop Entry]
        Type=Application
        Name=GPG Key Agent (keychain)
        Exec=keychain --quiet --agents gpg

3. Tell your shell to pick-up the `keychain` managed environment by adding `eval $(keychain --eval --quiet)` to your `.bashrc` or appropriate.

        echo 'eval $(keychain --eval --quiet)' >> ~/.bashrc

4. Add your key when you want to use it

        keychain ~/.ssh/id_ed25519

5. Continue on with life.
