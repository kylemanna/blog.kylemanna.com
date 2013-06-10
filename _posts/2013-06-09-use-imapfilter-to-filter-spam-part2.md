---
layout: post
title: "Use imapfilter to filter SPAM - part 2"
tagline: "howto"
category: linux
tags: [spam, spamassassin, imapfilter, imap]
---
{% include JB/setup %}

Issues with imapfilter
----------------------

* No built-in support for feeding messages to a filtering service like spamassassin.
* No mechanism for storing user name and password in a secure key chain.
* Doesn't gracefully handle server errors when in daemon mode.


Prerequisites 
-------------

* Spamassassin's spamd is setup and working.  Using spamc for mail filtering is significantly faster then invoking the standalone spamassassin client.  Users are welcome to attempt to replace <code>spamc</code> with <code>spamassassin</code>, in most cases it should work, but I haven't tested it.
* A Linux distribution with [GNOME Key Ring](/security/2013/05/13/gnome-keyring-access-for-python) setup and working on user login.  Additionally the DBUS session needs to be exported so that other processes can use it.  I added the following to the end of my <code>.bashrc</code>:


      DBUS_SESSION=$HOME/.dbus-session
      if [ "$DISPLAY" = ":0.0" -a -n "$DBUS_SESSION_BUS_ADDRESS" ]; then
              if [ ! -r "$DBUS_SESSION" -o "$DBUS_SESSION_BUS_ADDRESS" != "$(cat $DBUS_SESSION)" ]; then
                      echo "$DBUS_SESSION_BUS_ADDRESS" > $DBUS_SESSION
              fi
      fi
* An IMAPv4 server that supports the IDLE command.
* A server side filter that delivers all new email to an "*Unfiltered*" folder for processing.


Expected Operation
------------------

The whole thing should happen approximately like this:

1. The python wrapper.py script is run.
2. Python daemonize itself and the parent returns immediately.
3. The python child directly calls imapfilter.
4. Imapfilter starts up, starts executing the code in config.lua.
5. Config.lua tells python to invoke wrapper.py for access to the key ring.
6. Wrapper.py talks to GNOME key ring over DBUS for the user name and password.
7. Config.lua sets up the account table and enters the forever loop.
8. Forever loop does the following after connecting to the server:

   1. Checks the "*Unfiltered*" folder for unread messages.  If it finds them it does the following:

       1. Downloads the messages in chunks of up to 32.
       2. Forks up to 10 processes in parallel that pipe the messages to spamassassin using spamc.
       3. Scans the result for the "*X-Spam-Flag: Yes*" flag.  If the spam flag is found, the message is moved to the Spam folder.  Otherwise the message is moved to the "*INBOX*" where my mail clients expect it.
       4. The original message in the "*Unfiltered*" folder is now marked as read so it isn't processed again.

    2. Check the "*Unfiltered*" folder for messages older then 14 days and delete them.
    3. Check the "*Spam*" folder for messages older then 60 days and delete them.
    4. Check the "*Spam/False Positives*" folder for messages and feed them sa-learn for Bayesian HAM learning.
    5. Check the "*Spam/False Negatives*" folder for messages and feed them sa-learn for Bayesian SPAM learning.

9. When imapfilter exits due to a server error, the python wrapper waits 30 seconds and starts it again.  Back to step 4.


Setting up imapfilter
---------------------

1. Install imapfilter, for Ubuntu (13.04 for this writing) it's as simple as:

       $ sudo apt-get install imapfilter

2. Next the imapfilter code needs to be setup, I have a repo setup with most of the tools needed:

       $ git clone https://github.com/kylemanna/imapfilter-tools.git ~/.imapfilter

3. Clone the Lua library that handles piping data to spamassassin:

       $ git clone https://github.com/kylemanna/lua-popen3.git ~/.imapfilter/lua-popen3

4. Setup your key ring:

       $ cd ~/.imapfilter
       $ ./wrapper.py keyring set my.mail-server.com
       Username: <your username>
       Password: <your password>

   You can verify your key ring configure by launching the GNOME key ring utility.

5. Copy accounts.lua.sample to accounts.lua and set the server name in accounts.lua:

       $ cd ~/.imapfilter
       $ cp accounts.lua.sample accounts.lua
       $ vim accounts.lua


Test It
-------

Running <code>~/.imapfilter/wrapper.py</code> should launch the python script.  The python script will fork itself and then launch imapfilter.  Watch <code>~/.imapfilter/imapfilter.log</code> for errors.  At first there may be server or authentication issues, so be ready for them.

Fix the problem.  No telling what could go wrong.


Autostart
---------

After all the bugs are worked out with the wrapper, GNOME session can autostart the wrapper.  To setup the autostart, create a file under <code>~/.config/autostart/imapfilter.desktop</code> with the following:

    [Desktop Entry]
    Type=Application
    Exec=/home/<user>/.imapfilter/wrapper.py
    Hidden=false
    NoDisplay=false
    X-GNOME-Autostart-enabled=true
    Name[en_US]=imapfilter
    Name=imapfilter
    Comment[en_US]=Start up imapfilter
    Comment=Start up imapfilter

I'm not sure if the autostart desktop file allow variables like <code>$HOME</code> or shell expansions like <code>~</code>.  I specified the absolute path, so make sure you replace <code>&lt;user&gt;</code> on the Exec line.


Other Things?
-------------

I'm sure I forgot a few steps while writing this.  I'll try to update it later if I think of it or if people post comments with issues.
