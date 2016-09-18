---
title: "Long Range Zip Musings"
tagline: "aka lrzip"
category: archive 
tags: [compression, archive, lrzip, 7z, tar, xz, zpaq]
---

I stumbled upon [lrzip](https://github.com/ckolivas/lrzip) and was curious about it's viability as an archive compression tool for my old project files.  Due to the infrequent access, I don't care much about compression/decompression time, but I do care about the size as they are backed-up to the cloud via obnam.  I recorded the compression/decompression times just for my amusement, the system is an i5-2500K with 16 GB of RAM.  Filesize is the ultimate determining factor and the reason I chose ZPAQ for the compression algorithm.

## Tests

To test lrzip I found a tar archive I made a while back and compressed with 7zip.  I don't have/remember the 7zip command line arguments, but they were certainly aggressive. The source file is 3.1 GB consisting mostly highly compressible source code files.

First quick test, decompress the 7zip (which is tar behind the scenes) and then stream it to lrzip.  This isn't as efficient as the "-U" unlimited option that leverages free RAM:

    $ time ( 7z -so x ./proj_k320.tar.7z | lrzip -z - > proj_k320.tar.bz2 )
    1409.92s user 16.58s system 264% cpu 8:58.99 total

Decompress the tar archive and then use the unlimited option:

    $ time lrzip -Uz proj_k320.tar -o proj_k320.tar.lrz.u
    proj_k320.tar - Compression Ratio: 6.844. Average Compression Speed:  4.559MB/s.
    1372.07s user 10.79s system 202% cpu 11:21.87 total

## Results

    $ ls -lhtr
    -rw-r--r-- 1 nitro nitro 3.1G Dec 14 13:01 proj_k320.tar
    -rw-rw-r-- 1 nitro nitro 891M Aug  2  2012 proj_k320.tar.7z
    -rw-r--r-- 1 nitro nitro 456M Dec 14 12:50 proj_k320.tar.lrz
    -rw-r--r-- 1 nitro nitro 455M Dec 14 13:17 proj_k320.tar.lrz.u
	-rw-r--r-- 1 nitro nitro 789M Dec 14 14:23 proj_k320.tar.xz

## Integrity Verification

	$ sha1sum proj_k320.tar
	68c00ccacfff2e01e99057e00b6ac12c7435d25e  proj_k320.tar
	sha1sum proj_k320.tar  10.63s user 0.31s system 99% cpu 10.947 total

    $ time 7z -so x ./proj_k320.tar.7z | sha1sum
    68c00ccacfff2e01e99057e00b6ac12c7435d25e  -
    10.84s user 0.59s system 15% cpu 1:11.54 total

    $ time lrzcat proj_k320.tar.lrz | sha1sum
    68c00ccacfff2e01e99057e00b6ac12c7435d25e  -
    1382.04s user 5.59s system 276% cpu 8:21.58 total

	$ time lrzcat proj_k320.tar.lrz.u | sha1sum
	68c00ccacfff2e01e99057e00b6ac12c7435d25e  -
	sha1sum  10.85s user 0.54s system 1% cpu 11:33.15 total

