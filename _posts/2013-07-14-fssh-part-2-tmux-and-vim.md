---
layout: post
title: "FSSH part 2: Tmux and Vim"
tagline: "sync it"
category: 
tags: [ linux, osx, tmux, bash, ssh, fssh ]
---
{% include JB/setup %}

FSSH Introduction
-----------------

The other day I [introduced fssh](/linux/2013/06/15/remote-ssh-copy-paste-buffers-using-fssh/), and initially the standalone command line tools worked great.  However, it came up short for tmux and vim.

This blog article is going to explain about how to leverage fssh + ui_copy and ui_paste for copying and pasting vim visual buffers and tmux buffers.

For example, this enables users to copy some code (or something) on a web page (ie Mac OS X or Linux + Chrome) and then paste it directly in to vim, unmolested.  Another example would be to copy several hundred lines of shell output (running in tmux) in to a Github Gist, by copying/pasting without having to worry about other adjacent tmux panes or other details.


My Public dot-files
-----------------

I started a public [Github repo for my dot-files](https://github.com/kylemanna/dot-files), in this repo are a few files that provide the functionality I'm going to talk about in the following sections:

* [bash_env.sh](https://github.com/kylemanna/dot-files/blob/master/.bash_env.sh) - Functions to aid in cross shell invocation environment caching.
* [vimrc](https://github.com/kylemanna/dot-files/blob/master/.vimrc) - Adds key bindings for ui_copy and ui_paste from fssh.
* [tmux.conf](https://github.com/kylemanna/dot-files/blob/master/.tmux.conf) - Adds key bindings for ui_copy and ui_paste from fssh.


Vim Usage
---------

Assuming fssh is setup according to my earlier blog post then copying the key bindings to your *.vimrc*.

To use the vim bindings for copying:

1. Start vim and open a file.
2. Enter visual mode (type v or shift-v from normal mode).
3. Highlight some text.
4. Type C-c (CTRL+c), and ui_copy will be invoked.
5. Paste the buffer in your host UI (i.e. Command+v on OS X)

To use the vim vindings for pasting:

1. Copy text in the host UI (i.e Command+c on OS X)
2. Open a file with vim
3. Type C-v (CTRL+v), and ui_paste will be invoked.

Simple as that.


Tmux Usage
----------

Tmux usage is very similar to the vim usage.

Copy:

1. Enter copy-mode by typing *tmux-prefix* + *{* (Tmux prefix is C-b by default, most people change it to C-a).
2. Highlight some text.
3. When highlighted text is selected, press *enter* to copy it to tmux's buffer.
4. To feed tmux's buffer to ui_copy, type *tmux-prefix* + C-c.
5. Paste the buffer in your host UI (i.e. Command+v on OS X)

Paste:

1. Copy text in the host UI (i.e Command+c on OS X)
2. Paste the buffer by typing *tmux-prefix* + C-v.

That's it.


Other Handy Utilties
--------------------

The *bash_env.sh* file has some other handy utilties like "tmux up" and "env-import" which are very handy.  Maybe I'll write about them another day.  In the meantime, people may find them useful.
