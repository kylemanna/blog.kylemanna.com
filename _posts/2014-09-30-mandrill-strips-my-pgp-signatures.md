---
title: "Mandrill Strips My PGP Signatures?"
tagline: "don't change my mail!"
category: linux
tags: [pgp, gpg, mutt, mail, gnupg, chicagovps, vps, mailjet, mandrill]
---

## ChicagoVPS Is Terrible

Over the years I've adventured from colo (to much work for what I was doing) to Dreamhost (to slow and restrictive) to cheap VPS and most recently to Digital Ocean.  My stuff is scattered all over as I slowly coalesce it to a sane solution.

This is a story about my mail server still hosted on ChicagoVPS,  which is the worst provider I've ever used (never mind the VPS being down for **days** after a hack with no feedback).  I don't expect *fanatical* service, but I expect a reply in a reasonable time frame (read: 10s of hours) and resolution shortly thereafter.  None of my issues were due to things I was doing and also affected all other users on the same host or network. I didn't expect special treatment.

I didn't get what I expected, so instead I did what any responsible person would do: opened a support ticket (a few), replied (too many times), asked for a resolution (such a demand), and finally took to the Internet to warn others.  I posted on [LowEndtalk forum about the blacklist](http://lowendtalk.com/discussion/33977/providers-subnet-is-in-a-spam-rbl-par-for-the-course-for-lebs).  Much to my surprise, many people proposed a now obvious solution: use a free transactional email relay.  To this day the server is still [blacklisted](http://www.spamhaus.org/sbl/query/SBL225915), but they did give me 3 months of free service after I demanded it.  I doubt I'll use it though at this rate.

I'm not really a web guy, but in the past few years things like Mandrill, Mailgun, Mailjet and SendGrid have materialized as pointed out by the replies on LowEndTalk.  Best part is that they have free mail tiers.  Awesome for the less then 200 emails my server would send a month.  Sign up for Mandrill (because when I'm sending only 200 free emails a month 12k free emails sounds awesome, right?).  Setup my postfix relayhost.  Profit?  Not so fast.


## Issues With Mandrill

At first I very closely monitored all my mail logs.  The test process went something like this:

1. Send a test email.
2. Watch my mail server relay it to Mandrill.
3. Watch Mandrill send it out to destination server.
4. Watch the logs on destination server to see it arrive.
5. Review the slick web interface saying "delivered".

Except, that's not quite how it worked.  Instead, step #5 occurs before step #3.  Not cool.  Turns out [someone on reddit](http://www.reddit.com/r/webdev/comments/2dq4qy/dont_trust_mandrill_email_service_here_is_why/) observed the same thing.  That user goes as far as to say email was "lost" which is indeed scary.  I haven't lost any emails as of yet (90% of my Mandrill volume to date was testing).

It's a free service.  There is probably some database *eventual consistency* issue or something (not really logical, right?).  Shrug, it was free and better then getting kicked in the face by ChicagoVPS + SpamHaus RBL.


## Mandrill + multipart/signed

One day (today) I attempted to send a gpg signed email.  Why? Because it excites me in ways only cypherpunks will understand.  To test my mutt + gpg setup I sent a gpg signed email to my gmail address.  The body made it, but the signature did not.  Turns out Mandrill strips the signature out.  Their API log JSON blobs show the email as arriving with a PGP signature, however when they get to gmail it's gone.  Gmail's fault? Nope, disabling the Mandrill relayhost on my mail server results in a proper PGP email in my gmail inbox.  Smoking gun.  Mandrill is misbehaving, again.

Since this blog is read by practically nobody (I don't expect people to listen to my babbling in person let alone on the Internet), the following serves primarily as my public bug report since Mandrill seems to have no way for free tier users to report issues.  Shame, since this seems like a legitimate problem.

### When sent directly to Gmail (no Mandrill)

    Delivered-To: 2bluesc@gmail.com
    Received: by 10.64.251.33 with SMTP id zh1csp308958iec;
            Tue, 30 Sep 2014 08:32:51 -0700 (PDT)
    X-Received: by 10.68.197.170 with SMTP id iv10mr58783781pbc.129.1412091170829;
            Tue, 30 Sep 2014 08:32:50 -0700 (PDT)
    Return-Path: <kyle@kyle...manna.com>
    Received: from nexus.frozenliquid.net (nexus.frozenliquid.net. [192.210.217.230])
            by mx.google.com with ESMTPS id ey16si13253883pac.57.2014.09.30.08.32.50
            for <2bluesc@gmail.com>
            (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
            Tue, 30 Sep 2014 08:32:50 -0700 (PDT)
    Received-SPF: pass (google.com: domain of kyle@kyle...manna.com designates 192.210.217.230 as permitted sender) client-ip=192.210.217.230;
    Authentication-Results: mx.google.com;
           spf=pass (google.com: domain of kyle@kyle...manna.com designates 192.210.217.230 as permitted sender) smtp.mail=kyle@kyle...manna.com;
           dkim=pass header.i=@frozenliquid.net
    Received: from localhost (localhost [127.0.0.1])
        by nexus.frozenliquid.net (Postfix) with ESMTP id 0BC882D8063D;
        Tue, 30 Sep 2014 08:32:48 -0700 (PDT)
    Authentication-Results: nexus.frozenliquid.net (amavisd-new);
        dkim=pass (2048-bit key) reason="pass (just generated, assumed good)"
        header.d=frozenliquid.net
    DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=frozenliquid.net;
         h=user-agent:content-disposition:content-type:content-type
        :mime-version:message-id:subject:subject:from:from:date:date
        :received; s=nexus; t=1412091166; bh=uCcSQKM3a4ckK5G6hZ77XmhO20e
        2TCWKVcdDkhbxGZk=; b=gm8/BmnKAfA2yT0dygjpJty62o058PY7O+fC3KsZ4tz
        cU4w+7DAL6HFVgbJfd4OBuNHZKpa/mjcpP87ebV3lI5/JTsl4bWDEDfJDS6mTtw+
        HlujMWVE2Ndu6svywJkPS0QBzRiSm4iAMPpjws/pUV3WE9FRKmZFS4OYHsXTSXCj
        Wb0W0LAEm5OfiWIu1SbEM+zY+k/Ozi4Pfj71vf4L/RrkwSfJrMEuUkQocLHfHOHY
        fqYaIsSbDvTBBApUb6rrlutIMVeeJav+Wf2KFCEPqdIiKaBulShhTRTlRgrDzyBm
        bHzch5eHeArD+sw+5QMW1AnArmExT9YottjGeJ6hCHA==
    X-Virus-Scanned: Debian amavisd-new at nexus.frozenliquid.net
    Received: from nexus.frozenliquid.net ([127.0.0.1])
        by localhost (nexus.frozenliquid.net [127.0.0.1]) (amavisd-new, port 10026)
        with ESMTP id gsAO2CghK9UA; Tue, 30 Sep 2014 08:32:46 -0700 (PDT)
    Date: Tue, 30 Sep 2014 08:32:42 -0700
    From: Kyle Manna <kyle@kyle...manna.com>
    To: 2bluesc@gmail.com, kyle@kyle...manna.com
    Subject: Test All
    Message-ID: <20140930153242.GH25280@kyle...manna.com>
    MIME-Version: 1.0
    Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="fd5uyaI9j6xoeUBo"
    Content-Disposition: inline
    User-Agent: Mutt/1.5.23 (2014-03-12)


    --fd5uyaI9j6xoeUBo
    Content-Type: text/plain; charset=us-ascii
    Content-Disposition: inline

    Test1

    --fd5uyaI9j6xoeUBo
    Content-Type: application/pgp-signature

    -----BEGIN PGP SIGNATURE-----
    Version: GnuPG v2

    iQIcBAEBAgAGBQJUKs0aAAoJEL173Gxf6G+LYdwQANv6dtfqtIwLTDYSgBevGipt
    FWMuVouwiS5jbMXzMTjjwwPAODxN6OroS7vNeHsRtZ9rqP2g4AXw46Hmz6g7BIoC
    KTS9Tsxny9Psw5MWT9Hjbrwjo7inUD3mfX1rIM1KzCTgH6trTzpvYv42mBjsydwt
    LC76khxi8neBGtJsKqX6CN7mEuq+QATDC+nzMgvs8mTe+w/7yejELV6VAkWZEZeG
    NupC5Z6QKHx2KdszUF3A0JkbBo2ttiVX8kOWdWwhpZHrVWcbCo3bQUhMH69VXeaC
    1jA5ntmsUIAQ+m1wQJjZVIFk6TIjrfgG2CaK8m9umgjpoUAQmzzQkyDVwglIsAEm
    +ww/wUcULlPg6Aq8iLpWCOfjtXb1kS8wGh3GZvXdAYkaat042T6XwOjjU3bhkb+F
    hODj0VzcdlexTCH1WCOQTcPC9fxLoIN6mQoyQZu50dbjGN9XnGRHkMaGPBpyY+qk
    SMUST7v8fbMaroT2xoDRKkRzo/05dpH+e72K9oLSAMU4VdurvMnIAeag2Yfr5/qj
    Cfn6IIpMfn+/DQ0kadmFgh6LLR/Yo/bZvZLCu+QOWfPT1fvgYmp8D12FgqKPlbt3
    53cE800EJuMz+vM4g+phOPJBjpHqdsQhM92d/JHipIMmmWuf3aL2PB+Biw2Aaw0d
    lYFJL2kq+V+D+ok4DoXa
    =hHsX
    -----END PGP SIGNATURE-----

    --fd5uyaI9j6xoeUBo--


### When relayed through Mandrill

    Delivered-To: 2bluesc@gmail.com
    Received: by 10.64.251.33 with SMTP id zh1csp309361iec;
            Tue, 30 Sep 2014 08:35:36 -0700 (PDT)
    X-Received: by 10.236.84.206 with SMTP id s54mr10660978yhe.111.1412091336181;
            Tue, 30 Sep 2014 08:35:36 -0700 (PDT)
    Return-Path: <bounce-md_30293850.542acdc7.v1-f5861d776ab64c88a828bacb6a34ecca@mandrillapp.com>
    Received: from mail128-135.atl41.mandrillapp.com (mail128-135.atl41.mandrillapp.com. [198.2.128.135])
            by mx.google.com with ESMTPS id d28si15985480yhd.127.2014.09.30.08.35.35
            for <2bluesc@gmail.com>
            (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
            Tue, 30 Sep 2014 08:35:36 -0700 (PDT)
    Received-SPF: pass (google.com: domain of bounce-md_30293850.542acdc7.v1-f5861d776ab64c88a828bacb6a34ecca@mandrillapp.com designates 198.2.128.135 as permitted sender) client-ip=198.2.128.135;
    Authentication-Results: mx.google.com;
           spf=pass (google.com: domain of bounce-md_30293850.542acdc7.v1-f5861d776ab64c88a828bacb6a34ecca@mandrillapp.com designates 198.2.128.135 as permitted sender) smtp.mail=bounce-md_30293850.542acdc7.v1-f5861d776ab64c88a828bacb6a34ecca@mandrillapp.com;
           dkim=pass header.i=@mail128-135.atl41.mandrillapp.com
    DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; s=mandrill; d=mail128-135.atl41.mandrillapp.com;
     h=From:Sender:Subject:To:Message-Id:Date:MIME-Version:Content-Type:Content-Transfer-Encoding; i=kyle@mail128-135.atl41.mandrillapp.com;
     bh=iiYwvGhLQKLahU8/f7/QY94YgQ0=;
     b=BaEwimpDddsfUyT5Va21E9ML60iCBJ0VREn6dMVC03n7ZyqAxQ+J4bNiEe76M3WNzt5ULnwyr7bO
       R0JjWRRGXlaWZV5+LOkFSSTAf0JtzA7qLc0esUFyd80bc2c/u0PyF9K50T4mfwKwxAsCaf0Qikn1
       ObyDiPR1+I2ej2Gz6eo=
    DomainKey-Signature: a=rsa-sha1; c=nofws; q=dns; s=mandrill; d=mail128-135.atl41.mandrillapp.com;
     b=QEweOQr9WbuISJhYd6olnLHVfMY1Bk8IOAP+oWypsRXjWiL1wTazvMCi73GN2FYoY4BMugJkIXth
       Ho+Y3tRw82pCQHXG/eUo2zZQGRvkNFDnZ2j+r6q+pZheNs+VvwjVPB2ZCrns1k++YCnDJbK8bz97
       GyrmtlOv59FAdjuZ+i8=;
    Received: from pmta04.atl01.mandrillapp.com (127.0.0.1) by mail128-135.atl41.mandrillapp.com id h5b6sg1mquki for <2bluesc@gmail.com>; Tue, 30 Sep 2014 15:35:35 +0000 (envelope-from <bounce-md_30293850.542acdc7.v1-f5861d776ab64c88a828bacb6a34ecca@mandrillapp.com>)
    DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=mandrillapp.com; 
     i=@mandrillapp.com; q=dns/txt; s=mandrill; t=1412091335; h=From : 
     Sender : Subject : To : Message-Id : Date : MIME-Version : Content-Type 
     : Content-Transfer-Encoding : From : Subject : Date : X-Mandrill-User : 
     List-Unsubscribe; bh=PqYAMl7AZUU8rZdTkQqOgRgiqpO0eQc6JpzEl+F7D+w=; 
     b=es5x7sYQdOI+PTU3HLm8j1eL/9qRlZq6LcKVABfg3JwAqzPZ9B08Ao2ZcHDExD2acTYmGA
     AaAFapEYuk7T6jO7R3J70UlsCRjlgpJoIl2qx4OLXsi5n35y0SZjuaH55y+m3PJCs3rkcPJ6
     UhrmcjTWK9spAKubD78QqnBBrOEWg=
    From: Kyle Manna <kyle@kyle...manna.com>
    Sender: Kyle Manna <kyle@mail128-135.atl41.mandrillapp.com>
    Subject: Test All
    Return-Path: <bounce-md_30293850.542acdc7.v1-f5861d776ab64c88a828bacb6a34ecca@mandrillapp.com>
    X-Virus-Scanned: Debian amavisd-new at nexus.frozenliquid.net
    To: <2bluesc@gmail.com>, <kyle@kyle...manna.com>
    Message-Id: <20140930153530.GI25280@kyle...manna.com>
    Received: from [192.210.217.230] by mandrillapp.com id f5861d776ab64c88a828bacb6a34ecca; Tue, 30 Sep 2014 15:35:35 +0000
    X-Report-Abuse: Please forward a copy of this message, including all headers, to abuse@mandrill.com
    X-Report-Abuse: You can also report abuse here: http://mandrillapp.com/contact/abuse?id=redacted
    X-Mandrill-User: md_30293850k
    Date: Tue, 30 Sep 2014 15:35:35 +0000
    MIME-Version: 1.0
    Content-Type: text/plain; charset=utf-8
    Content-Transfer-Encoding: 7bit

    Test2


### Mandrill's API logs

Reviewing the API logs shows that Mandrill gets the message with PGP header in the request:

    {
        "from_name": null,
        "send_at": null,
        "async": false,
        "raw_message": "Received: from nexus.frozenliquid.net (unknown [192.210.217.230])\n\t(Authenticated sender: Yr4gxCaXNO66mPQYScGxJQ@gmail.com)\n\tby ip-10-196-133-123 (Postfix) with ESMTPSA id 938FC8A84E;\n\tTue, 30 Sep 2014 15:35:35 +0000 (UTC)\nReceived: from localhost (localhost [127.0.0.1])\n\tby nexus.frozenliquid.net (Postfix) with ESMTP id 3D05A2D8063D;\n\tTue, 30 Sep 2014 08:35:35 -0700 (PDT)\nAuthentication-Results: nexus.frozenliquid.net (amavisd-new);\n\tdkim=pass (2048-bit key) reason=\"pass (just generated, assumed good)\"\n\theader.d=frozenliquid.net\nDKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=frozenliquid.net;\n\t h=user-agent:content-disposition:content-type:content-type\n\t:mime-version:message-id:subject:subject:from:from:date:date\n\t:received; s=nexus; t=1412091333; bh=U2C4Gfg6BV+UZDbsOU30Dtk3Klf\n\t5R0wdTrAd//hpkkA=; b=NWxp4S1RJFdbytWqQZ+6Cr+m5SI0hwR2ame12WVqVMW\n\to7v+v3Mma7GI8qaAFv0cSahkFd31OOh2fJ7gsCKcpaakoT3WcQietJYjji0Za7Qy\n\tSoPQEgyItSFrD7HQORfiAein8e7ZO8L2hhupTRWGzBjAGpsxSk4xUBBSSPJlCR+v\n\tr7iUhMnslFMg8p1skJmrRbq8jO00dod47wkER9OVo6Pa0JGBrfnZM6EkcFLTrp4f\n\tq3314PkryUhOi0LwCEN2xXVpyg/EpOwZ8PWz+86vB6Vll7FxB3U6jQn6Utf0TGxa\n\t0QaImeltm5tQFVtB8a4qtvcDQNVI0q9HlT9fcYI0P6w==\nX-Virus-Scanned: Debian amavisd-new at nexus.frozenliquid.net\nReceived: from nexus.frozenliquid.net ([127.0.0.1])\n\tby localhost (nexus.frozenliquid.net [127.0.0.1]) (amavisd-new, port 10026)\n\twith ESMTP id VEij1AF8TGH7; Tue, 30 Sep 2014 08:35:33 -0700 (PDT)\nDate: Tue, 30 Sep 2014 08:35:30 -0700\nFrom: Kyle Manna <kyle@kyle...manna.com>\nTo: 2bluesc@gmail.com, kyle@kyle...manna.com\nSubject: Test All\nMessage-ID: <20140930153530.GI25280@kyle...manna.com>\nMIME-Version: 1.0\nContent-Type: multipart/signed; micalg=pgp-sha1;\n\tprotocol=\"application/pgp-signature\"; boundary=\"K1SnTjlYS/YgcDEx\"\nContent-Disposition: inline\nUser-Agent: Mutt/1.5.23 (2014-03-12)\n\n\n--K1SnTjlYS/YgcDEx\nContent-Type: text/plain; charset=us-ascii\nContent-Disposition: inline\n\nTest2\n\n--K1SnTjlYS/YgcDEx\nContent-Type: application/pgp-signature\n\n-----BEGIN PGP SIGNATURE-----\nVersion: GnuPG v2\n\niQIcBAEBAgAGBQJUKs3BAAoJEL173Gxf6G+LbekP/A855DvmJ4X5TJiDL5DSpiFG\n7n7eL6a2oJvLrSwQICLL1UV83izrpozQi20me3DH6qWDCB0T/IjwZzUCN6owD8bY\nDzySvOwIVu5iVwSwa/JoQIcy+dQvwDR/JDBvXRIBRV1Aiel5I01VeNGE9PA8VdS2\n2JP4SPzupAMHMuwCVW/4DaJSvlZPsl0R27YD5sLIbpNMIrafUUcWyBMEqctH86wg\n9UfX2uvC5oMhkMQd4XSd2tn82/9zCV5X/uZPzWPpdAaC+guAGX0Cl8H+X0Qz44P/\nHRXMaxnSF+uDTxhr/kIV6Tj9bkTQmSgUgiMsfGR0ALUo5Bar2HXJwazJx1FW/AVi\n/vohavEjgHhoOBWQCA9h5KqvsPIpXs/zP4Et1IvKO2rTF2i7CRwMXGyE6eYeayE7\n9ebijy2SrTY00/BnDcbKrYzDkoOHkbQD0K1hXmDhH46aLQzRRwt8CWp07NZIRCxx\nNwxReYEOPc9ZoAUuaHQ4ZXMHhIS6nHALpcX/RQixbEiT26C53KXKVzR0v1XRK28V\nW3RD13LGj7eKDh/jhgiC9SH/0jhEOvqT+UCSmU8xKKDBZVSld5o+UcyB9v8XcEo6\nvn40/qQb87UStj40F2Epen3xWb2UIlMn42HhLamQTKrngAH7lJ8zrETDTnVmvqBx\nZ6VfplWsMVTC22+2xecn\n=bHIt\n-----END PGP SIGNATURE-----\n\n--K1SnTjlYS/YgcDEx--",
        "key": "Yr4gxCaXNO66mPQYScGxJQ",
        "to": [
            "2bluesc@gmail.com"
        ],
        "from_email": null,
        "ip_pool": null,
        "return_path_domain": null
    }

Response with no errors (i.e. "I did not molest your message"):

    [
        {
            "email": "2bluesc@gmail.com",
            "status": "sent",
            "_id": "f5861d776ab64c88a828bacb6a34ecca",
            "reject_reason": null
        }
    ]


## Solution? Try Another

Started off with Mailgun since it was hosted by Rackspace and probably run right.  Wrong, my account was flagged and needed "business verification".  I emailed support and charged on to the next service.  Several minutes later support had replied linking to their support site, but I had moved on.  Impressive to get an email back from support at 11 pm PDT.

Next, was SendGrid, their website seemed awkward.  Registration was easy and there was some "verification" step that needed to occur.  I assume it was some human okaying my account.  Again I got annoyed and charged on.  Several mintues later it too claimed to be ready, but I had already moved on.

Finally, I tried [Mailjet](https://www.mailjet.com/).  Their website seems more feature-ful, kind of sluggish due to over design and what not.  Registration was painless, and I was able to verify my account quickly.  Updated postfix configuration and placed a temporary magic text in the top-level of my website to prove ownership of my domain and was sending mail.  Tested mutt + pgp to gmail and it just worked.  Done.  Profit, finally.  In the meantime, the other accounts managed to activate themselves, too little too late for my needs.  Finished off the night with DKIM and SPF records so that they can propagate while I sleep.

## Final Solution?

Once DigitalOcean adds IPv6 support to their SFO data center, I'll move my mail server there (into a CoreOS service) and get rid of my dependence on ChicagoVPS.  At that point, I'll no longer be blacklisted and could then decide if I want to keep or drop Mailjet.  If it continues to work flawlessly, I might as well keep it.


## Update 2014.10.08

I soon realized that Mailjet requires me to verify *every* sending domain.  All of my servers that send cron emails need to be individually verified for *every* hostname.  Sigh.  I don't want to rewrite or forge the sender address (spammers would forge the header, so this policy is ridiculous anyways...), I'd rather see cron emails from user@hostname.full.tld.  I went through the process of activating my Mailgun account and using and that seems better for the moment.  I wish they would have cleaned-up the mail headers that leak too much data though... but it works the best so far.

In other news, ColoCrossing finally was removed from the blacklist.  I received this nice little email from MxToolbox informing me:

[![MxToolbox email screenshot](http://i.imgur.com/Lu4xTe5l.png)](http://imgur.com/Lu4xTe5)

64 days later.

I'll stick with Mailgun for now.  Hopefully Mandrill will fix their stuff as their service seemed better overall (multiple SMTP logins so each server could connect directly to their endpoints without sharing credentials).

In other news, I bet ChicagoVPS will never close my ticket eventhough the issue is (temporarily?) resolved.
