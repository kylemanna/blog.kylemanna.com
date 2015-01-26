---
layout: post
title: "KeePassX + YubiKey Fork Time?"
tagline: ""
category: 
tags: []
---
{% include JB/setup %}

## KeePassX + YubiKey support

Almost a year ago I added YubiKey support to KeePassX.  It worked by leveraging the HMAC-SHA1 feature of Yubico's YubiKey to generate an encryption key to secure a KeePassX database.  Awesome, coded it, sent a [pull request on Github](https://github.com/keepassx/keepassx/pull/52).  People tested it, people reported bugs, I fixed them, and the love continue.  Kind of.  Except the lead developer for KeePassX has never said anything in the thread despite my request for input... several times.

That was all last year.  This year, nothing has changed.

## Time to Fork?

Perhaps it's time to fork it and maintain it myself?  It appears that I have at least a small set of users interested.  Perhaps this will happen when KeePassX exits "alpha" stage and approaches a release candidate for 2.0.  Or, maybe someone will report a bug worth updating (and more importantly, testing) my branch.

Stay tuned on Github [kylemanna/keepassx](https://github.com/kylemanna/keepassx) and show your support. :)
