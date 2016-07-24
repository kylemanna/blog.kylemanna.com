---
layout: post
title: "DigitalOcean SFO1 vs SFO2"
description: ""
category: cloud
tags: [linux, cloud, digital ocean]
---

## DigitalOcean SFO1 vs SFO2

Yesterday [DigitalOcean announced](https://www.digitalocean.com/company/blog/announcing-sfo2/) the availability of their SFO2 datacenter.  Curious to see what was different, I did a quick investigation.  This is by no means exhaustive, and I'm a more elaborate application specific benchmark would be more interesting, but this is a quick overview.

## Network

Quick check from my apartment in San Francisco on Comcast (and via WiFi, I know...).

### SFO1

     $ tracepath 45.55.15.x
     1?: [LOCALHOST]                                         pmtu 1500
     1:  router                                                0.810ms
     2:  172.16.12.1                                           1.446ms
     3:  96.120.89.209                                        12.058ms
     4:  te-0-7-0-4-sur04.sfgeary.ca.sfba.comcast.net         10.930ms
     5:  be-313-ar01.hayward.ca.sfba.comcast.net              12.025ms
     6:  lag-14.ear2.SanJose1.Level3.net                      14.050ms
     7:  ae-1-6.bar2.SanFrancisco1.Level3.net                 15.104ms asymm  9
     8:  DIGITAL-OCE.bar2.SanFrancisco1.Level3.net            19.098ms asymm 11
     9:  no reply
    10:  45.55.15.x                                           15.841ms reached


### SFO2

    $ tracepath 138.68.15.x
     1?: [LOCALHOST]                                         pmtu 1500
     1:  router                                                1.009ms
     2:  172.16.12.1                                           1.294ms
     3:  96.120.89.209                                        13.694ms
     4:  te-0-7-0-4-sur04.sfgeary.ca.sfba.comcast.net         11.516ms
     5:  be-313-ar01.hayward.ca.sfba.comcast.net              12.551ms
     6:  lag-14.ear2.SanJose1.Level3.net                      14.765ms
     7:  DIGITAL-OCE.ear2.SanJose1.Level3.net                 12.979ms
     8:  no reply
     9:  138.68.15.x                                          14.680ms reached
         Resume: pmtu 1500 hops 9 back 9

Nothing really interesting to see here.

## Processors

How about the processors?  Did they move to a new generation?

### SFO1
    root@ubuntu-512mb-sfo1-01:~# cat /proc/cpuinfo
    processor       : 0
    vendor_id       : GenuineIntel
    cpu family      : 6
    model           : 45
    model name      : Intel(R) Xeon(R) CPU E5-2630 0 @ 2.30GHz
    stepping        : 7
    microcode       : 0x1
    cpu MHz         : 2299.998
    cache size      : 15360 KB
    physical id     : 0
    siblings        : 1
    core id         : 0
    cpu cores       : 1
    apicid          : 0
    initial apicid  : 0
    fpu             : yes
    fpu_exception   : yes
    cpuid level     : 13
    wp              : yes
    flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon rep_good nopl eagerfpu pni pclmulqdq vmx ssse3 cx16 pcid sse4_1 sse4_2 x2apic popcnt tsc_deadline_timer aes xsave avx hypervisor lahf_lm vnmi ept tsc_adjust xsaveopt arat
    bugs            :
    bogomips        : 4599.99
    clflush size    : 64
    cache_alignment : 64
    address sizes   : 40 bits physical, 48 bits virtual
    power management:

### SFO2
    root@ubuntu-512mb-sfo2-01:~# cat /proc/cpuinfo
    processor       : 0
    vendor_id       : GenuineIntel
    cpu family      : 6
    model           : 63
    model name      : Intel(R) Xeon(R) CPU E5-2650L v3 @ 1.80GHz
    stepping        : 2
    microcode       : 0x1
    cpu MHz         : 1799.998
    cache size      : 30720 KB
    physical id     : 0
    siblings        : 1
    core id         : 0
    cpu cores       : 1
    apicid          : 0
    initial apicid  : 0
    fpu             : yes
    fpu_exception   : yes
    cpuid level     : 13
    wp              : yes
    flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon rep_good nopl eagerfpu pni pclmulqdq vmx ssse3 fma cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand hypervisor lahf_lm abm vnmi ept fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid xsaveopt arat
    bugs            :
    bogomips        : 3599.99
    clflush size    : 64
    cache_alignment : 64
    address sizes   : 40 bits physical, 48 bits virtual
    power management:

It certainly looks like a step forward in processor technology.  Small lithography process, lower clock speed, lower power, and of course, more cores.  That's what DigitalOcean is selling primarily is cores + RAM + SSD space.

Intel's [ARK highlights the differences](http://ark.intel.com/compare/64593,64585) between the processor generations.

## Conclusion

DigitalOcean did the logical thing: moved to newer processor that will allow them to run more droplets per host while consuming less power. Surprise? Of course not.

But now we know.
