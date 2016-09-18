---
title: "Time Warner Cable aka RoadRunner TLS and SSL Mail Fail"
tagline: "ain't nobody got time for that"
category: security
tags: [twc, roadrunner, cable]
---

The Parents
-----------

I traveled home to visit the parents for the holidays.  As usual I'm confronted with the onslaught of technical problems, one of which was email via Time Warner Cable.  As usual I encourage them to use the Gmail account I setup years ago, the response is always "I don't know my password" followed by resetting the password.  The cycle repeats, and I did it again.  This time I went one step further to use Gmail's POP3 (what is this the 90s?) fetching option to retrieve all the email from the other account so that maybe this year there's a chance at burying TWC which is bad enough for that reason.

What I discovered on accident is that TWC has ***no support for encrypted*** POP3 retrival.  I'm going to say that again: no SSL server running on port 995, no STLS/STARTTLS command, nothing.  IMAP support appears to be just as disappointing.  Everything is sent in the clear.  Sigh, and people wonder how identies stolen.

Command Line Action
-------------------

Dreamhost's properly configured mailservers testing POP3+STLS and then IMAP+STARTTLS:

	$ echo STLS | nc sub5.mail.dreamhost.com 110
	+OK Dovecot ready.
	+OK Begin TLS negotiation now.

	$ echo 0 STARTTLS | nc sub5.mail.dreamhost.com 143
	* OK [CAPABILITY IMAP4rev1 LITERAL+ SASL-IR LOGIN-REFERRALS ID ENABLE STARTTLS AUTH=PLAIN AUTH=LOGIN] Dovecot ready.
	0 OK Begin TLS negotiation now.

Works as expected.  How about [Time Warner Cable's mailservers](http://www.timewarnercable.com/en/residential-home/support/faqs/faqs-internet/e-mailacco/incoming-outgoing-server-addresses.html):

	$ echo STLS | nc pop-server.wi.rr.com 110
	+OK InterMail POP3 server ready.
	-ERR not authorized to use STLS command

	$ echo 0 STARTTLS | nc pop-server.wi.rr.com 143
	* OK IMAP4 server (InterMail vM.8.04.01.13 201-2343-100-167-20131028) ready Tue, 31 Dec 2013 07:11:32 +0000 (UTC)
	0 NO Not authorized to use STARTTLS command

Nope, no love at all.  What about SSL on ports 993/995 on my mail server (which has a screwy cert, but encrypted nonetheless)?

	$ openssl s_client -connect sub5.mail.dreamhost.com:995 -quiet
	depth=3 C = SE, O = AddTrust AB, OU = AddTrust External TTP Network, CN = AddTrust External CA Root
	verify error:num=19:self signed certificate in certificate chain
	verify return:0
	+OK Dovecot ready.

	$ openssl s_client -connect sub5.mail.dreamhost.com:993 -quiet
	depth=3 C = SE, O = AddTrust AB, OU = AddTrust External TTP Network, CN = AddTrust External CA Root
	verify error:num=19:self signed certificate in certificate chain
	verify return:0
	* OK [CAPABILITY IMAP4rev1 LITERAL+ SASL-IR LOGIN-REFERRALS ID ENABLE AUTH=PLAIN AUTH=LOGIN] Dovecot ready.

Everything works as expected including the annoying certificate warning.

And enter TWC on 993/995 for &lt;user&gt;@&lt;state&gt;.rr.com:

	$ openssl s_client -connect pop-server.wi.rr.com:995 -quiet
	<timeout>
	$ openssl s_client -connect pop-server.wi.rr.com:993 -quiet
	<timeout>


What's this? If you have a &lt;user&gt;@twc.com email address you can use a different mailserver that has SSL support?

	$ openssl s_client -connect mail.twc.com:993 -quiet
	depth=2 C = US, O = "VeriSign, Inc.", OU = VeriSign Trust Network, OU = "(c) 2006 VeriSign, Inc. - For authorized use only", CN = VeriSign Class 3 Public Primary Certification Authority - G5
	verify error:num=19:self signed certificate in certificate chain
	verify return:0
	* OK IMAP4 server (InterMail vM.8.04.01.13 201-2343-100-167-20131028) ready Tue, 31 Dec 2013 07:18:12 +0000 (UTC)

	$ openssl s_client -connect mail.twc.com:995 -quiet
	depth=2 C = US, O = "VeriSign, Inc.", OU = VeriSign Trust Network, OU = "(c) 2006 VeriSign, Inc. - For authorized use only", CN = VeriSign Class 3 Public Primary Certification Authority - G5
	verify error:num=19:self signed certificate in certificate chain
	verify return:0
	+OK InterMail SPOP3 server ready.

Sigh, TWC doesn't care about their *.rr.com users, but the *@twc.com users might have a chance?


What does this mean?
--------------------

This means that when my parents connect to some random WiFi access point and check their email, there's a fair chance someone can sniff the login and steal the password.

Oh yeah and MITM attacks.  I don't keep any of my personal stuff on Gmail, but it's way easier for my parents to not lose their email with it.  The NSA alreayd has access to both TWC and Gmail, so at least with Gmail we can keep the script kiddies running aircrack-ng out.

ISPs should ***force*** users to use secure communication protocols.  Apparently TWC doesn't care.  They probably think that "ain't nobody got time for that".
