---
layout: post
title: "Managing /etc with etckeeper"
description: ".."
tagline: "keeping etsy clean"
category: 
tags: []
---
{% include JB/setup %}

## Background on /etc and version control

I manage a number of Linux machines ranginge from servers to laptops. I have little interest in babysitting /etc and all the excitement that happens there. I try to avoid modifing files in /etc so that future upgrades are slightly more seemless. However, somethings absolutely need to be modified.


A long time ago I started using svn for watching all the files under /etc. Some issues with the filesystem caused files to get corrupted. The corrupted files were quickly restored from the local svn repository. Another machine had a site it hosted compromised. Having things under version control enabled me to quickly validate the contents of /etc. Lessons learned that payback dividends. 

Fast forward several years and Linus Torvalds created git, and invevitably I fell in love with git. With git we can do all of the same things, just easier. Git is a distributed version control system so that makes setting up the repository and pushing it to remove machines for back-up are also much easier. 

I have since learned that [Joey Hess](http://joeyh.name/) of [git annex](http://git-annex.branchable.com/) fame created [etckeeper](http://joeyh.name/code/etckeeper/), which makes all this even easier.

## Setup etckeeper on Ubuntu 12.04:


1. Install etckeeper on a Debian based distribution: {% highlight sh %}
$ sudo apt-get install etckeeper
{% endhighlight %}

2. Edit /etc/etckeeper/etckeeper.conf, commented out the VCS="bzr" line and uncomment the VCS="git" line.
3. Initialize the repository: {% highlight sh %}
$ cd /etc
$ sudo etckeeper init
{% endhighlight %}
4. Ensure the the /etc/.git directory has safe permissions, should only be readable by root. **Should this change, anyone who can read the git repoository can read all the the /etc files stored in the repository as objects.**: {% highlight sh %}
$ ls -ld /etc/.git
drwx------ 1 root root 108 Aug  7 22:27 /etc/.git
{% endhighlight %}
5. Create the initial commit: {% highlight sh %}
$ sudo etckeeper commit "Initial commit"
{% endhighlight %}

## Tour of etckeeper

* Etckeeper sets up gitignore for you: {% highlight sh %}
cat /etc/.gitignore
{% endhighlight %}
* View the git log: {% highlight sh %}
$ cd /etc
$ sudo git log
{% endhighlight %}
