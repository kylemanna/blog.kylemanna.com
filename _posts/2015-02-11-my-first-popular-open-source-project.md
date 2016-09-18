---
title: "My First Popular Open Source Project"
tagline: "accidently cool"
category: linux
tags: [docker, openvpn, linux, github, digital ocean]
---

## A Pretty Good Idea

I started playing around with Digital Ocean last year and wanted to setup an OpenVPN server in a droplet.  Better yet, set it up in a Docker container to manage the mess.  Okay, somebody already did this right?  Kind of.  I stumbled upon Jérôme Petazzoni's [jpetazzo/dockvpn](https://github.com/jpetazzo/dockvpn) project and [DOCKER + JOYENT + OPENVPN = BLISS](http://blog.docker.com/2013/09/docker-joyent-openvpn-bliss/) blog posting.  It was closed but missed the point of simplifying the PKI headache typically associated with OpenVPN.  Plus the mechanism for distributing a single static key (as opposed to a PKI configuration) scared me.  He wrote the blog post to demonstrate how to leverage a cloud host (Joyent) + Docker + OpenVPN -- not on how to make it the best thing ever...  that's where I came in.


## Fork It

I forked his project with the primary goal to implement a proper PKI.  Well, that's not actually that hard and so [kylemanna/docker-openvpn](https://github.com/kylemanna/docker-openvpn) was born.  I ripped out the strange http server to distribute the static key and added EasyRSA to manage the PKI.  I wrote some quick wrapper scripts to manage some common tasks (generate PKI, generate certs, get cert+config).  Tested it out and called it a day or a week or whatever.


## People Started Using It

Suddenly people started using it.  Well, okay, cool.  Then I started getting handy pull requests.  Then more people started using it.  Cool.  I realized with [pull request #9](https://github.com/kylemanna/docker-openvpn/issues/9) that most people seemed to acknowledge they liked my implementation more.  That's a welcome compliment.


## Could I Make Some Money?

Digital Ocean has an awesome referral program: $25 for me and $10 discount for new sign-ups.  All I needed to do was place my referral link in the `README.md` and I would get some nice passive money to fund testing [kylemanna/openvpn](https://registry.hub.docker.com/u/kylemanna/openvpn) on Digital Ocean and my other servers.  Now I can help users find a cloud provider that's known to work and they help fund development.  Right now I'm averaging maybe one sign-up referral a week.  Not bad.  Time will tell to see how many of those convert to payouts after people spend over the minimum amount for Digital Ocean to pay me.


## Money For Tutorials

Digital Ocean also pays people money to write tutorials.  This is an interesting SEO tactic that results in a Google searches for popular technologies returning results on Digital Ocean.  It seemed obvious: I'll write a tutorial using the existing `README.md` as a template.

I wrote a tutorial, and after what seemed like forever (2 months?) over the year end holidays of 2014 my [Digital Ocean Docker + OpenVPN tutorial](https://www.digitalocean.com/community/tutorials/how-to-run-openvpn-in-a-docker-container-on-ubuntu-14-04) was published.  They paid me $200 which I cashed out via PayPal minus PayPal fees (grrr, begin Bitcoin rant...)

Interestingly enough, after the two revision of the article went through, my link back to Digital Ocean still contains my referral code.  More referrals -> :).


## Who Is Using This

Prior to writing the tutorial I wanted to track my [Docker Hub Registry](https://registry.hub.docker.com/u/kylemanna/openvpn/) statistics.  Now, I'm not a web guy (or cloud guy!), so I poked around and stumbled on a solution.  I used import.io to scrape the Docker Hub Registry page and log the downloads, stars.  Initially I queried import.io from my home workstation, but I later leveraged Google Docs Sheets + Google App Scripts to poll import.io.  Then I could graph the data in Google Sheets. At the time of writing it looked something like this:

![Docker Hub Downloads](https://i.imgur.com/oJd6yn0.png "Docker Hub Downloads")

First thing to jump out for most people is the nearly perfect linear climb from 11k downloads to 93k downloads.  I have no idea what happened there, I assume someone's cloud deploy script broke and did a 80k `docker pull kylemanna/openvpn` commands.  Oops.


## Next Steps

I hope that it becomes more popular. :)  IPv6 support is coming when I get time, someday.

It'd be nice if somebody could throw together a Python/Ruby/Node.js web server that could act as front end over https for administration.  That's beyond my interest (and skills) as it relates to web technologies.  I envision a way to do everything my wrapper shell scripts do but from the command line.  Additionally the web UI could interface to OpenVPN's management interface and get runtime status.  [Changetips](https://www.changetip.com/) for anyone who provides something of significant substance. 
