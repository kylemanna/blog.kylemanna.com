---
layout: post
title: "Deleting Unused Docker Volumes"
description: ""
category: linux
tags: [linux, docker, volumes]
---
## Investigating Docker Volumes

While investigating migrating my [kylemanna/openvpn](https://github.com/kylemanna/docker-openvpn) image to use native [Docker Volumes](https://docs.docker.com/engine/reference/commandline/volume_create/) instead of the old busybox hack to create an empty volume I discovered I have a ton of dangling volumes.  And consuming a ton of disk space.

What are they?  What's in them? Why are they dangling and not clean-up?

## What's in the Dangling Volumes?

Docker v1.9 added `docker volume` commands and later releases enhanced it.  To query the dangling volumes:

    $ docker volume ls -f dangling=true
    DRIVER              VOLUME NAME
    local               0039d65be4c135d76340672bdff7e3b442ec65ef013aab486e60f111b37b4223
    local               00c6dad23070368f18b963a8e4ee65f16b372969fa1a091c43ac41e500665a77
    ...
    local               fe93d89dd4747e47098f69741e967626bed0ae35c7a12c541f4ce7b4ca043ea3
    local               ff33f29a0ca8d60da171a6ead8966735856639a2e743793e83d0305f9d44eef7

In my case, I had **343** *dangling* volume containers.

    $ docker volume ls -f dangling=true | wc -l
    343

To check the total disk space:

    $ docker volume ls -f dangling=true  | awk '{print "/var/lib/docker/volumes/" $2 }' | xargs sudo du -hc
    ...
    1.8G total

Dig deeper and sort them by disk space:

    $ docker volume ls -f dangling=true  | awk '{print "/var/lib/docker/volumes/" $2 }' | xargs sudo du -bs | sort -n
    0       /var/lib/docker/volumes/_tmp
    10      /var/lib/docker/volumes/12aea7b48bc182f4c108ba0a63f67a453249de3dcc30db046468b691f1ca88cf
    10      /var/lib/docker/volumes/2b892d2094c16ab90d7536562be52d3816280f4288a6491bf1ec2e2f0b70deb4
    205422216 /var/lib/docker/volumes/9a62b9bd1221926e5484782918161309113176ed411f04e95297e9cedc8eaea1
    219513907 /var/lib/docker/volumes/adeb596ed11b2c6a62000a2abf7eb7ae868da64a9d0c11e2e3002e32d3187022


After reviewing the files in the biggest volumes it appears that I have some abandon volumes for MySQL databases for things I experimented with over a year ago.

No need for these anymore.

## Delete the Old

Measure the size of my volumes directory before:

    $ sudo du -hs /var/lib/docker/volumes
    1.9G    /var/lib/docker/volumes

### Delete the Volumes Without Data

    for i in $(docker volume ls -f dangling=true  | awk '{print $2}'); do sudo test -d "/var/lib/docker/volumes/$i/_data" || echo docker volume rm $i; done

Note: *Remove the `echo` from the above command to actually remove them.  The `echo` was added to preview what would run.*

This cleaned up *205* volumes for me.

Delete the data volumes without a `_data` directory as it appears there is little risk of losing anything.

Use my [handy docker-cleanup](https://github.com/kylemanna/docker-cleanup) script to examine and then delete the remaining directories:

    git clone https://github.com/kylemanna/docker-cleanup.git
    cd docker-cleanup
    sudo ./docker-volume-cleanup.sh

Example output:

    ===========================================
    :: Displaying fe93d89dd4747e47098f69741e967626bed0ae35c7a12c541f4ce7b4ca043ea3
    ===========================================

    /var/lib/docker/volumes/fe93d89dd4747e47098f69741e967626bed0ae35c7a12c541f4ce7b4ca043ea3
    └── _data
    ├── 9.4-main.pg_stat_tmp
    │   ├── db_0.stat
    │   ├── db_12141.stat
    │   └── global.stat
    └── 9.4-main.pid

    2 directories, 4 files

    creation: -
    modification: 2015-10-19 18:21:37.187453160 -0700
    size: 76K

    Delete fe93d89dd4747e47098f69741e967626bed0ae35c7a12c541f4ce7b4ca043ea3? [y/N]: y
    Executing: docker volume rm fe93d89dd4747e47098f69741e967626bed0ae35c7a12c541f4ce7b4ca043ea3
    fe93d89dd4747e47098f69741e967626bed0ae35c7a12c541f4ce7b4ca043ea3
    ...

Measure the size of my volumes directory after cleanup:

    $ sudo du -hs /var/lib/docker/volumes
    169M    /var/lib/docker/volumes

Dangling volume containers now: **0**.

## The Real Question

How'd this happen? Was there a bug or user error that didn't clean these up?  The oldest volumes are from 2014 and some as recent as last week.
