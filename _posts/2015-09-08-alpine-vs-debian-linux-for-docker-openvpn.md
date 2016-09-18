---
title: "Alpine vs Debian Linux for docker-openvpn"
description: ""
category: linux
tags: [linux, docker, alpine, debian, openvpn, vpn]
---

## Small Docker Images

A while back I switched my [kylemanna/openvpn](https://github.com/kylemanna/docker-openvpn) [Docker Hub image](https://hub.docker.com/r/kylemanna/openvpn/) from Ubuntu to Debian to save space.  It did a little bit, was still over 200MB.  Then with the release of Easy-RSA 3.0 I was able to drop the git dependency and use just the release tarball to get down to 150MB.  The problem is that 150MB still seems massive with tons of Debian cruft in it.

## Enter Alpine

[Alpine](https://www.alpinelinux.org/) is supposed to be ultra small with only the bare essentials.  This sounds perfect for a Docker image.

The reduced size also increases the security due to a reduced attack surface, which with Docker is admittedly already pretty small since only a single OpenVPN process is running anyways.  But hey, it sounds good.

I did what anyone in my position would have done: Created a new branch, converted the Dockerfile and setup a new Docker Hub build.

* Github [kylemanna/docker-openvpn alpine branch](https://github.com/kylemanna/docker-openvpn/tree/alpine)
* Docker Hub [tags](https://hub.docker.com/r/kylemanna/openvpn/tags/)

## Result

    ~ ❯❯❯ docker images
    REPOSITORY             TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
    kylemanna/openvpn      alpine              01f29d545370        7 minutes ago       12.4 MB
    kylemanna/openvpn      latest              0e27d3a8ec58        3 hours ago         150.5 MB
    kylemanna/openvpn      1.0                 0bda1c2e0f07        11 weeks ago        218.4 MB

[Docker Hub](https://hub.docker.com/r/kylemanna/openvpn/tags/)'s assessment:

    Tag      Size
    alpine   5 MB
    latest   60 MB
    1.0      85 MB

Everything is faster.  The Docker build of the image happens in seconds and the download is even faster.


## Test Drive

The conversion from Debian to Alpine took less than 30 minutes and just worked.  Of course when things "just work" I know it's too good to be true so I'm waiting for it to blow-up in my face.

I've converted three of my [$5/mo Digital Ocean droplets](http://do.co/1EQ6JUI) to the `alpine` tag for testing.  And they "just worked" too.  Hmm.


## Bonus

Alpine software release are more up to date:

* OpenVPN *2.3.4* -> *2.3.7* (Debian released an update a day later)
* OpenSSL *1.0.1k* -> *1.0.2b*
* Easy RSA 3 is in Alpine's testing branch, hopefully it'll hit the main branch and simplify things more.

      ~ ❯❯❯ docker run --rm -it kylemanna/openvpn:alpine openvpn --version
      OpenVPN 2.3.7 x86_64-alpine-linux-musl [SSL (OpenSSL)] [LZO] [EPOLL] [MH] [IPv6] built on Jul 10 2015
      library versions: OpenSSL 1.0.2b 11 Jun 2015, LZO 2.09
      Originally developed by James Yonan
      Copyright (C) 2002-2010 OpenVPN Technologies, Inc. <sales@openvpn.net>
      Compile time defines: enable_crypto='yes' enable_crypto_ofb_cfb='yes' enable_debug='yes' enable_def_auth='yes' enable_dlopen='unknown' enable_dlopen_self='unknown' enable_dlopen_self_static='unknown' enable_fast_install='yes' enable_fragment='yes' enable_http_proxy='yes' enable_iproute2='yes' enable_libtool_lock='yes' enable_lzo='yes' enable_lzo_stub='no' enable_management='yes' enable_multi='yes' enable_multihome='yes' enable_pam_dlopen='no' enable_password_save='yes' enable_pedantic='no' enable_pf='yes' enable_pkcs11='no' enable_plugin_auth_pam='yes' enable_plugin_down_root='yes' enable_plugins='yes' enable_port_share='yes' enable_selinux='no' enable_server='yes' enable_shared='yes' enable_shared_with_static_runtimes='no' enable_small='no' enable_socks='yes' enable_ssl='yes' enable_static='yes' enable_strict='no' enable_strict_options='no' enable_systemd='no' enable_win32_dll='yes' enable_x509_alt_username='no' with_crypto_library='openssl' with_gnu_ld='yes' with_mem_check='no' with_plugindir='$(libdir)/openvpn/plugins' with_sysroot='no'

      ~ ❯❯❯ docker run --rm -it kylemanna/openvpn:latest openvpn --version
      OpenVPN 2.3.4 x86_64-pc-linux-gnu [SSL (OpenSSL)] [LZO] [EPOLL] [PKCS11] [MH] [IPv6] built on Dec  1 2014
      library versions: OpenSSL 1.0.1k 8 Jan 2015, LZO 2.08
      Originally developed by James Yonan
      Copyright (C) 2002-2010 OpenVPN Technologies, Inc. <sales@openvpn.net>
      Compile time defines: enable_crypto=yes enable_debug=yes enable_def_auth=yes enable_dependency_tracking=no enable_dlopen=unknown enable_dlopen_self=unknown enable_dlopen_self_static=unknown enable_fast_install=yes enable_fragment=yes enable_http_proxy=yes enable_iproute2=yes enable_libtool_lock=yes enable_lzo=yes enable_lzo_stub=no enable_maintainer_mode=no enable_management=yes enable_multi=yes enable_multihome=yes enable_pam_dlopen=no enable_password_save=yes enable_pedantic=no enable_pf=yes enable_pkcs11=yes enable_plugin_auth_pam=yes enable_plugin_down_root=yes enable_plugins=yes enable_port_share=yes enable_selinux=no enable_server=yes enable_shared=yes enable_shared_with_static_runtimes=no enable_small=no enable_socks=yes enable_ssl=yes enable_static=yes enable_strict=no enable_strict_options=no enable_systemd=yes enable_win32_dll=yes enable_x509_alt_username=yes with_crypto_library=openssl with_gnu_ld=yes with_ifconfig_path=/sbin/ifconfig with_iproute_path=/sbin/ip with_mem_check=no with_plugindir='${prefix}/lib/openvpn' with_route_path=/sbin/route with_sysroot=no
      git revision: refs/heads/jessie/b35ad09bfc4a26e7
