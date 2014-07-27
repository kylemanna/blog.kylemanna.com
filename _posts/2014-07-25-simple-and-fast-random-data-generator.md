---
layout: post
title: "Simple and Fast Random Data Generator"
tagline: ""
category: 
tags: []
---
{% include JB/setup %}

# Issue

I was testing out some new harddrives and wanted to fill them with random data.  To avoid any filesystem or disk controller optimizations I wanted to ensure that no de-duping would be possible.

The most obvious solution is to use `/dev/urandom`, but that's terribly slow:

    $ for i in $(seq 5); do dd if=/dev/urandom bs=1M count=100 2>/dev/null | pv -bat > /dev/null; sleep 1 ; done
     100MiB 0:00:06 [  15MiB/s]
     100MiB 0:00:06 [14.8MiB/s]
     100MiB 0:00:06 [  15MiB/s]
     100MiB 0:00:06 [14.9MiB/s]
     100MiB 0:00:06 [14.8MiB/s]

Meanwhile, `/dev/zero` is insanely fast, but likely to be de-duped or compressed if possible:

    $ for i in $(seq 5); do dd if=/dev/zero bs=1M count=10k 2>/dev/null | pv -bat > /dev/null; sleep 1 ; done
      10GiB 0:00:02 [3.82GiB/s]
      10GiB 0:00:02 [   4GiB/s]
      10GiB 0:00:02 [   4GiB/s]
      10GiB 0:00:02 [3.82GiB/s]
      10GiB 0:00:02 [3.99GiB/s]

Ideally, I'd get something fast enough to saturate the disks (150 MB/s - 500 MB/s)

# How about Encryption?

Lets read zeros for the hell of it, and then rely on OpenSSL to take a weak password, salt it and then send us the encrypted output which might as well be pseudo-random data.  Benchmark:

    $ for i in $(seq 5); do dd if=/dev/zero bs=1M count=1k 2>/dev/null | openssl enc -rc4-40 -pass pass:weak | pv -bat > /dev/null; sleep 1 ; done
       1GiB 0:00:01 [ 532MiB/s]
       1GiB 0:00:01 [ 542MiB/s]
       1GiB 0:00:01 [ 534MiB/s]
       1GiB 0:00:01 [ 538MiB/s]
       1GiB 0:00:01 [ 540MiB/s]

To be more useful, change the stdout redirector to a file rather then /dev/null and boom, DONE.  Running the same script over and over each time will generate different ciphertext because the passphrase is derived key uses a salt by default to prevent de-duping.

It definitely consumes a bit more CPU, but it's supposed to be quick and dirty.  I'm sure I could do something in C and approach the performance of the `/dev/zero` benchmark, but it's not needed just yet.
