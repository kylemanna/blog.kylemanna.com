---
layout: post
title: "GPG Breakage on v2.1"
tagline: ""
category: 
tags: []
---
{% include JB/setup %}

## GPG for Backups

I had run a normal `gpg-agent` as people expect for things like `mutt` and handling special files and I ran another `gpg-agent` that didn't use the standard socket and cached my backup key's passphrase so that the backups run without user intervention.  Seemed like a good compromise where my backup keys were more accessible then my other gpg keys.  What else could you do if it's going to run daily via systemd-timers?

## GnuPG 2.1 Kills GPG_AGENT_INFO

The [release notes](https://www.gnupg.org/faq/whats-new-in-2.1.html) say:

    The classic way to run gpg-agent on Unix systems is by launching it at login time and use an environment variable (GPG_AGENT_INFO) to tell the other GnuPG modules how to connect to the agent. However, correctly managing the start up and this environment variable is cumbersome so that that an easier method is required. Since GnuPG 2.0.16 the --use-standard-socket option already allowed to start the agent on the fly; however the environment variable was still required.

    With GnuPG 2.1 the need of GPG_AGENT_INFO has been completely removed and the variable is ignored. Instead a fixed Unix domain socket named S.gpg-agent in the GnuPG home directory (by default ~/.gnupg) is used. The agent is also started on demand by all tools requiring services from the agent.

And that broke my GPG encrypted backup setup.

Man page:

       --use-standard-socket

       --no-use-standard-socket
              Since  GnuPG  2.1  the  standard  socket  is  always used.  These options have no more
              effect.


## The Fix

### Take 1

Use `GNUPGHOME` if you need a separate home for GnuPG, you'll need to copy your keys over.  I started with this approach and it worked fine, but felt clumsy.

### Take 2

Use `allow-preset-passphrase` to cache my backup encryption key passphrase.  I'll need to unlock it once per boot, but at least the passphrase never hits the hard drive.  Allow the passphrase to remain for 100 days, which should be reasonable as I end up rebooting for new kernels and what not.

1. Launch `gpg-agent` manually using [systemd unit file](https://github.com/kylemanna/systemd-utils/blob/master/units/gpg-agent.service) (Gotta love systemd on Arch) so that our custom arguments take affect.  If GnuPG autostarts itself, I'll miss these two critical arguments and it doesn't appear that I can store them in a config file:

        [Unit]
        Description=GPG private key agent
        IgnoreOnIsolate=true

        [Service]
        Type=forking
        # Start GPG manually so that precise arguments can be passed.  Would be nice if
        # gpgconf added support for allow-preset-password
        ExecStart=/usr/bin/gpg-agent --daemon --allow-preset-passphrase --max-cache-ttl 8640000
        Restart=on-abort

        [Install]
        WantedBy=default.target

2. Start the systemd service and kill any old `gpg-agent`s:

        killall gpg-agent
        systemctl --user start gpg-agent

3. Determine the key grip:

        $ gpg --with-keygrip -k backup@local
        pub   rsa4096/80A52AF1 2014-12-18
              Keygrip = 7EB315BA6F5691BF448BCE9075B4C09D9EE150AD
        uid       [ultimate] Backup <backup@local>
        sub   rsa4096/A0EB95D4 2014-12-18
              Keygrip = 33B64BFB62BBC97A516C00AC5D10DC1C4BF1438A

4. Add the key manually with a simple script every time I reboot.  There won't be a prompt, it will just read your key from stdin:

        /usr/lib/gnupg/gpg-preset-passphrase -v --preset 7EB315BA6F5691BF448BCE9075B4C09D9EE150AD

5. Test it by signing a quick message, it shouldn't prompt you for the password:

        $ echo test | gpg -a -s -u 80A52AF1
        -----BEGIN PGP MESSAGE-----
        Version: GnuPG v2

        [...]
        -----END PGP MESSAGE-----
