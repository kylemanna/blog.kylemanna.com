---
title: "Android AOSP Docker Image for Building Android ROMs"
tagline: "Android AOSP Docker Image updated for building Android Nougat ROMs and now simpler then ever"
category: android
tags: [linux, android, nougat, docker, rom]
---

## Build your Android Nougat ROM

Took some time this weekend to build update my Android AOSP Docker image to build stock Android AOSP Nougat ROM.  No major changes were necessary.  I did update to Ubuntu 16.04 and dropped the external OpenJDK dependencies and use the packages available from the Ubuntu repositories.

The build is now slightly simpler.

## Test Drive Building Android Nougat ROM

Build the ROM with no scewing around with the following commands:

    mkdir nougat ; cd nougat
    export AOSP_VOL=$PWD
    curl -O https://raw.githubusercontent.com/kylemanna/docker-aosp/master/tests/build-nougat.sh
    bash ./build-nougat.sh

Wait for 1-4 hours depending on your Internet connection and CPU and it should be done.

Those steps compared with installing an out-of-date virtual machine to run some old distribution that only builds a certain version of Android, all thanks to Docker.  Docker contain the mess and allows your production builds to built by the same Docker image as development builds built by developers.
.
## Next Steps

Next step?  Hack-up `build-nougat.sh` script to suit your needs and live on.

Someday I'll write-up a blog on the design of AOSP.  Someday, when I get some time.
