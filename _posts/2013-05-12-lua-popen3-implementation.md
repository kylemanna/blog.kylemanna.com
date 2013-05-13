---
layout: post
title: "Lua popen3() Implementation"
tagline: "how does this not exist?"
category: programming
tags: [lua, linux]
---
{% include JB/setup %}

Background
----------

I start playing around with [imapfilter](https://github.com/lefcha/imapfilter) this weekend which uses lua for scripting and wanted to basically pipe an email to spamassassin and get the result back.  Incredibly simple request I thought.  In shell code it would be as simple as:

	spamc < ./msg1.txt > msg1.processed.txt

Where <code>msg1.txt</code> is fed to <code>spamc</code> on stdin and then the output from stdout is written to <code>msg1.processed.txt</code>.  The message can then be placed in my inbox and handled appropriately.

Lua + POSIX popen()?
--------------------

POSIX defines [popen](http://pubs.opengroup.org/onlinepubs/009696899/functions/popen.html) for one pipe, doesn't tell you the return status of the command you execute and you must pass the command as a string.  Passing the entire command is very annoying if ever want to pass multiple string arguments as now you need to escape them, and becareful doing that as you can code a security hole in the blink of an eye.

Not surprisingly, lua has a simple implementation of the [POSIX popen](http://www.lua.org/manual/5.2/manual.html#pdf-io.popen).  Unfortunately all you can do is write to the pipe for read from the pipe.  That means I can only do <code>spamc &lt; ./msg1.txt</code> or <code>spamc &gt; msg1.processed.txt</code>.  This accomplishes nothing productive.

Lua extensions or luarocks?
---------------------------

Maybe I can find something from the Lua extension site: [luarocks](http://luarocks.org/).  Yes! In fact I can, it's called [Lua Process Call (lpc)](https://github.com/LuaDist/lpc).  I played with this on Lua 5.1 and it works, stdin, stdout, and stderr just worked.  So I should be happy right? No...

The luarocks package on Ubuntu 13.04 was built against Lua 5.1, and after running <code>luarocks install lpc</code> I have a shared object that only works with Lua 5.1.  Sigh, imapfilter uses Lua 5.2.  I started re-building luarocks with Lua 5.2 support, and got that working after a while.  Then I ran in to problems building lpc against Lua 5.2 as a number of ABI changes breaks it.  At this point I could start learning alot more Lua then I car to learn, fork the github repo and fix... but that's way to painful.  Perhaps there is a better way.

Native Lua Implementation?
--------------------------

I started looking closer at the [Lua POSIX module](https://github.com/luaposix/luaposix) included with Ubuntu (package name lua-posix) and realized there isn't any reason I can't just implement it in native Lua leveraging the POSIX module.  With a little bit of work, and learning more Lua I did just that.  Example code is on Github and will hopefully help others:

<script src="https://gist.github.com/kylemanna/5564520.js"></script>

This implementation provides access to stdin, stdout, and stderr.  Additionally it cleans-up its zombie processes with wait() and returns the status code of the forked process.  What more could you want?  I can't think of much missing from this.  If there are any people with more Lua-foo that I have (which is next to none... or should I say nil?), please feel free to comment on ways to improve this.

Additionally a simple wrapper provides a clean and easy way to access simple commands <code>pipe_simple()</code> while still allowing users to access <code>popen3()</code> to handle the pipes as needed.

Next Steps
----------

Stay tuned for an upcoming entry with imapfilter!
