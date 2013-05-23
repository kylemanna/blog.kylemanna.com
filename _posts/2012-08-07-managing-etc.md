---
layout: post
title: "Managing /etc with etckeeper"
tagline: "keeping etsy clean"
category: linux
tags: [linux, etc, etckeeper, git]
---
{% include JB/setup %}

## Background on /etc and version control

I manage a number of Linux machines ranginge from servers to laptops. I have little interest in babysitting /etc and all the excitement that happens there. I try to avoid modifing files in /etc so that future upgrades are slightly more seemless. However, somethings absolutely need to be modified.


A long time ago I started using svn for watching all the files under /etc. Some issues with the filesystem caused files to get corrupted. The corrupted files were quickly restored from the local svn repository. Another machine had a site it hosted compromised. Having things under version control enabled me to quickly validate the contents of /etc. Lessons learned that payback dividends. 

Fast forward several years and Linus Torvalds created git, and invevitably I fell in love with git. With git we can do all of the same things, just easier. Git is a distributed version control system so that makes setting up the repository and pushing it to remove machines for back-up are also much easier. 

I have since learned that [Joey Hess](http://joeyh.name/) of [git annex](http://git-annex.branchable.com/) fame created [etckeeper](http://joeyh.name/code/etckeeper/), which makes all this even easier.

## Setup etckeeper on Ubuntu 12.04:


1. Install etckeeper on a Debian based distribution:

		$ sudo apt-get install etckeeper

2. Edit /etc/etckeeper/etckeeper.conf, commented out the VCS="bzr" line and uncomment the VCS="git" line. One-liner:

		$ sed -e 's:^\(VCS\s*=.*bzr\):#\1:' -e 's:^#\(VCS\s*=.*git\):\1:' -i /etc/etckeeper/etckeeper.conf

3. Initialize the repository:

		$ cd /etc
		$ sudo etckeeper init

4. Ensure the the /etc/.git directory has safe permissions, should only be readable by root. **Should this change, anyone who can read the git repoository can read all the the /etc files stored in the repository as objects.**:

		$ ls -ld /etc/.git
		drwx------ 1 root root 108 Aug  7 22:27 /etc/.git

5. Create the initial commit:

		$ sudo etckeeper commit "Initial commit"

## Tour of etckeeper

* Etckeeper sets up gitignore for you:

		$ cat /etc/.gitignore

* View the git log:

		$ cd /etc
		$ sudo git log
		commit 1726dc3a2330216548b7adc99cce402cc39a5a9c
		Author: nitro <nitro@core>
		Date:   Tue Aug 21 17:44:47 2012 -0500

			committing changes in /etc after apt run

			Package changes:
			+lftp 4.3.3-1

		 lftp.conf |   94 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		 1 file changed, 94 insertions(+)

		commit af34fb96471751709ef3b2abb18cedb058ff31fa
		Author: nitro <nitro@core>
		Date:   Tue Aug 14 21:00:58 2012 -0500

			committing changes in /etc after apt run

			Package changes:
			-base-files 6.5ubuntu6
			+base-files 6.5ubuntu6.2
			-fonts-opensymbol 2:102.2+LibO3.5.4-0ubuntu1
			+fonts-opensymbol 2:102.2+LibO3.5.4-0ubuntu1.1
			-gir1.2-launchpad-integration-3.0 0.1.56
			+gir1.2-launchpad-integration-3.0 0.1.56.1
			-google-chrome-stable 21.0.1180.75-r150248
			+google-chrome-stable 21.0.1180.77-r150576
			-launchpad-integration 0.1.56
			+launchpad-integration 0.1.56.1
			-libbonobo2-0 2.32.1-0ubuntu1
			-libbonobo2-common 2.32.1-0ubuntu1
			-libbonoboui2-0 2.24.5-0ubuntu1
			-libbonoboui2-common 2.24.5-0ubuntu1
			+libbonobo2-0 2.32.1-0ubuntu1.1
			+libbonobo2-common 2.32.1-0ubuntu1.1
			+libbonoboui2-0 2.24.5-0ubuntu1.1
			+libbonoboui2-common 2.24.5-0ubuntu1.1
			-liblaunchpad-integration-3.0-1 0.1.56
			-liblaunchpad-integration-common 0.1.56
			-liblaunchpad-integration1 0.1.56
			+liblaunchpad-integration-3.0-1 0.1.56.1
			+liblaunchpad-integration-common 0.1.56.1
			+liblaunchpad-integration1 0.1.56.1
			-libnspr4 4.8.9-1ubuntu2
			-libnspr4-0d 4.8.9-1ubuntu2
			+libnspr4 4.8.9-1ubuntu2.1
			+libnspr4-0d 4.8.9-1ubuntu2.1
			-libreoffice-base-core 1:3.5.4-0ubuntu1
			-libreoffice-calc 1:3.5.4-0ubuntu1
			-libreoffice-common 1:3.5.4-0ubuntu1
			-libreoffice-core 1:3.5.4-0ubuntu1
			-libreoffice-draw 1:3.5.4-0ubuntu1
			-libreoffice-emailmerge 1:3.5.4-0ubuntu1
			-libreoffice-gnome 1:3.5.4-0ubuntu1
			-libreoffice-gtk 1:3.5.4-0ubuntu1
			-libreoffice-help-en-us 1:3.5.4-0ubuntu1
			-libreoffice-impress 1:3.5.4-0ubuntu1
			-libreoffice-math 1:3.5.4-0ubuntu1
			-libreoffice-style-human 1:3.5.4-0ubuntu1
			-libreoffice-style-tango 1:3.5.4-0ubuntu1
			-libreoffice-writer 1:3.5.4-0ubuntu1
			+libreoffice-base-core 1:3.5.4-0ubuntu1.1
			+libreoffice-calc 1:3.5.4-0ubuntu1.1
			+libreoffice-common 1:3.5.4-0ubuntu1.1
			+libreoffice-core 1:3.5.4-0ubuntu1.1
			+libreoffice-draw 1:3.5.4-0ubuntu1.1
			+libreoffice-emailmerge 1:3.5.4-0ubuntu1.1
			+libreoffice-gnome 1:3.5.4-0ubuntu1.1
			+libreoffice-gtk 1:3.5.4-0ubuntu1.1
			+libreoffice-help-en-us 1:3.5.4-0ubuntu1.1
			+libreoffice-impress 1:3.5.4-0ubuntu1.1
			+libreoffice-math 1:3.5.4-0ubuntu1.1
			+libreoffice-style-human 1:3.5.4-0ubuntu1.1
			+libreoffice-style-tango 1:3.5.4-0ubuntu1.1
			+libreoffice-writer 1:3.5.4-0ubuntu1.1
			-light-themes 0.1.9.1-0ubuntu1
			+light-themes 0.1.9.1-0ubuntu1.1
			-mdadm 3.2.3-2ubuntu1
			+mdadm 3.2.5-1ubuntu0.2
			-python-uno 1:3.5.4-0ubuntu1
			+python-uno 1:3.5.4-0ubuntu1.1
			-sessioninstaller 0.20+bzr128-0ubuntu1
			+sessioninstaller 0.20+bzr128-0ubuntu1.1
			-uno-libs3 3.5.4-0ubuntu1
			+uno-libs3 3.5.4-0ubuntu1.1
			-update-manager 1:0.156.14.6
			-update-manager-core 1:0.156.14.6
			-update-notifier 0.119ubuntu8.4
			-update-notifier-common 0.119ubuntu8.4
			+update-manager 1:0.156.14.9
			+update-manager-core 1:0.156.14.9
			+update-notifier 0.119ubuntu8.5
			+update-notifier-common 0.119ubuntu8.5
			-ure 3.5.4-0ubuntu1
			+ure 3.5.4-0ubuntu1.1
			-xserver-common 2:1.11.4-0ubuntu10.6
			+xserver-common 2:1.11.4-0ubuntu10.7
			-xserver-xorg-core 2:1.11.4-0ubuntu10.6
			+xserver-xorg-core 2:1.11.4-0ubuntu10.7

		 bonobo-activation/bonobo-activation-config.xml |    1 +
		 issue                                          |    2 +-
		 issue.net                                      |    2 +-
		 lsb-release                                    |    2 +-
		 4 files changed, 4 insertions(+), 3 deletions(-)


## Shortcomings

When I managed my git repos myself, in the days before etckeeper, I would make a habit of specifying the author with commits.  Consequently, on shared servers administered by groups of people, I made a big deal out of everyone specifying the author when they modified files under /etc.  The result was a real traceable history, and no more initials and comments from co-workers and friends about who changed what and why as the git log provided all this.

It does appear to grab the `$SUDO_USER` environmental variable though, so that helps a little. However, on lightweight virtual machines without real users and multiple admins, it will always say the author is `root@hostname`.

I'm unaware of any ways to do this under etckeeper now.  Perhaps someday I'll get around to writing a patch to do it and submit it upstream.   
