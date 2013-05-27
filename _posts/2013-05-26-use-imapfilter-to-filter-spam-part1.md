---
layout: post
title: "Use imapfilter to filter SPAM - part 1"
tagline: "do more then just move messages"
category: linux
tags: [spam, spamassassin, imapfilter, imap]
---
{% include JB/setup %}


Use Case
--------

I use IMAP4 for work and for my personal email, and so does the better part of the world that isn't using either MS Exchange or some website.  I get a lot of SPAM (who doesn't?) and I don't want to.  My webhost's (Dreamhost) SPAM filtering service misses often and I get SPAM in my inbox regularly.

I have no longer have a desire to run my own mail server on my co-located server or VPS, I don't want the hassle.  For a long time I've been running Thunderbird almost 24/7 on my workstation to sort my junk mail, but it typically lags behind my Android phone.  Typically I'll get an alert about new email, and there will be a race condition between checking the message and my workstation moving the SPAM message to my Junk folder.  I'd prefer my Android phone never saw the message.

Possible solutions:
* Run my own mail server and filter it with spamassassin and maildrop, like the old days. Not a good solution because I don't want to babysit a server.
* Use Thunderbird to sort my Junk mail.  Thunderbird is too slow and not that accurate.
* Switch web hosts or find a dedicated mail service to host my email.  I don't have much against Dreamhost and don't feel like spending more money for another service.  I also don't like to leave my private email on remote hosts for long, so forget Gmail.
* Run something on my Linux workstation to do the heavy lifting behind the scenes.


Enter IMAP Filter
-----------------

I scoured the web and found some other people attempting to do similar things, but nothing that really made sense.  All I want is a daemon that would connect to my IMAP server, watch for new messages, run the messages through spamassassin, and put it in my Inbox or in the SPAM folder.

I stumbled on [imapfilter](https://github.com/lefcha/imapfilter).  The goal of imapfilter is to securely connects to remote IMAP server, and move messages around by detecting properties of the message.  It almost does exactly what I want, with one big exception: it doesn't [directly] have support for filtering a remote message through an external program such as spamassassin.

Fortunately, the developer of imapfilter is using Lua for all the actual scripting to move messages rather then re-inventing the wheel with a proprietary format.  With a little bit of work I figured I could learn enough Lua to fetch a message, run it through spamassassin, check the X-Spam-Status header in the returned message and put it in the appropriate folder.

And so my adventure started.


Security
--------

The config.lua example sorting scripts included with imapfilter have a method to store my password securely in an encrypted file using OpenSSL.  This requires the user to manually enter the pass phrase to decrypt the file containing the real password.  That's not very useful beyond demonstration of using an external program to get the real password, why not just ask the user for the real password?

I wanted something that would happen automatically without user intervention.  After all this script was going to handle all my incoming mail before I see it, so it needs to alway be running.

I then wrote some code to use gpg and my gpg-agent embedded in GNOME Keyring.  That way imapfilter + config.lua could invoke gpg which would then invoke the gpg-agent to decrypt the file in an automated fashion.  This worked, but was still too clumsy, so I tried again.

I wanted my passwords to be stored in GNOME Keyring as it's a handy interface to a number of other security mechanisms.  I then learned about a simple python script that would talk to the GNOME Keyring over D-Bus to request the user name and password.  With that I could store my passwords in a fairly secure manner for now.


Goals
-----

* Configure my webhost to deliver all my new messages to an "Unfiltered" folder for processing.
* Use imapfilter to connect to my IMAP4 mail server and manipulate messages.
  * Read messages from "Unfiltered".
  * Pass messages to spamassassin.
  * Read the result from spamassassin and deliver ham to my "Inbox" and spam to the "Spam" folder.
  * Mark the messages in the "Unfiltered" folder as read and eventually clean them up after *x* days.
  * Delete messages in the "Spam" folder after *y* days.
* Configure Lua to invoke a [simple python script](/security/2013/05/13/gnome-keyring-access-for-python) to query GNOME Keyring for network credentials.
* Write a simple [Lua 5.2 popen3()](/programming/2013/05/12/lua-popen3-implementation) like wrapper to fork a process and write stdin and read stdout and stderr.
* Ensure that I can parallelize the messages that are filtered through spamassassin / spamd as it often takes 4+ seconds to process a message due to slow network tests.
* Provide a mechanism to teach spamassassin's Bayesian filter what's spam and what's ham so that I have very accurate SPAM classifier.

Stay Tuned
----------

Stay tuned for a full how-to in part 2.
