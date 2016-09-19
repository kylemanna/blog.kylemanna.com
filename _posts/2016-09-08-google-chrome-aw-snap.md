---
title: "Google Chrome says Aw, Snap"
excerpt: "How I workaround Google Chrome's memory fragmentation problem on Linux"
category: linux
tags: [linux, chrome, chromium, google]
header:
  image: https://i.imgur.com/sebgnJ7.png
  overlay_color: "#000"
  overlay_filter: "0.7"
  overlay_image: https://i.imgur.com/sebgnJ7.png
---

## Aw, Snap!

For the longest time I ran Google Chrome (v53.0.2785.92 at the time of writing) package from the AUR on Arch Linux.  When I did the initial research between Chrome and Chromium, it seemed that Chrome was simpler as it came things like Flash player and PDF viewer out of the box.  And that was life until maybe a month or so ago.

More recently, Google Chrome has made a habit of saying "Aw, Snap!".
![Google Chrome - Aw, Snap!](https://i.imgur.com/sebgnJ7.png)

That's right. But why? A quick Google search will show that this typically caused by running out of memory. Ok, simple to test right. Except, I'm not out of memory.  My system has 16 GB of RAM, and while I fully believe Chrome could consume all of that with just Gmail loaded, it's not out of RAM, not even close.  Plenty of swap and plenty of RAM doing nothing more then file system caching.  So what's going wrong?

Check my kernel message buffer with dmesg, and what do we see?  The out of memory killer running and killing my Chrome processes.

    [731411.303799] chromium invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=300
    [731411.303802] chromium cpuset=/ mems_allowed=0
    [731411.303806] CPU: 2 PID: 7255 Comm: chromium Tainted: G           O    4.7.2-1-ARCH #1
    [731411.303808] Hardware name: Gigabyte Technology Co., Ltd. Z68MX-UD2H-B3/Z68MX-UD2H-B3, BIOS F13 02/21/2012
    [731411.303809]  0000000000000286 00000000ddd5dd37 ffff88013ff23b48 ffffffff812eb132
    [731411.303811]  ffff88013ff23d28 ffff880146788000 ffff88013ff23bb8 ffffffff811f6e5c
    [731411.303813]  ffff88013ff23b70 0000000000000000 ffff88041f497c08 ffff88041f7ee000
    [731411.303815] Call Trace:
    [731411.303820]  [<ffffffff812eb132>] dump_stack+0x63/0x81
    [731411.303823]  [<ffffffff811f6e5c>] dump_header+0x60/0x1e8
    [731411.303827]  [<ffffffff811762fa>] oom_kill_process+0x22a/0x440
    [731411.303829]  [<ffffffff8117696a>] out_of_memory+0x40a/0x4b0
    [731411.303830]  [<ffffffff8117c05b>] __alloc_pages_nodemask+0xf0b/0xf30
    [731411.303832]  [<ffffffff8117c3d4>] alloc_kmem_pages_node+0x54/0xd0
    [731411.303834]  [<ffffffff81077c06>] copy_process.part.8+0x136/0x19a0
    [731411.303836]  [<ffffffff81079647>] _do_fork+0xd7/0x3d0
    [731411.303837]  [<ffffffff810799e9>] SyS_clone+0x19/0x20
    [731411.303839]  [<ffffffff81003c07>] do_syscall_64+0x57/0xb0
    [731411.303842]  [<ffffffff815de861>] entry_SYSCALL64_slow_path+0x25/0x25
    [731411.303843] Mem-Info:
    [731411.303846] active_anon:1221471 inactive_anon:345995 isolated_anon:0
                     active_file:1151817 inactive_file:407362 isolated_file:0
                     unevictable:583 dirty:5811 writeback:0 unstable:0
                     slab_reclaimable:739382 slab_unreclaimable:47599
                     mapped:171476 shmem:92125 pagetables:21095 bounce:0
                     free:63049 free_pcp:32 free_cma:0
    [731411.303849] Node 0 DMA free:15900kB min:64kB low:80kB high:96kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15984kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
    [731411.303853] lowmem_reserve[]: 0 3478 16012 16012
    [731411.303855] Node 0 DMA32 free:121548kB min:14664kB low:18328kB high:21992kB active_anon:1023040kB inactive_anon:434828kB active_file:667340kB inactive_file:573012kB unevictable:208kB isolated(anon):0kB isolated(file):0kB present:3644928kB managed:3569300kB mlocked:208kB dirty:4332kB writeback:0kB mapped:163492kB shmem:74524kB slab_reclaimable:607288kB slab_unreclaimable:40492kB kernel_stack:3472kB pagetables:16484kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
    [731411.303859] lowmem_reserve[]: 0 0 12534 12534
    [731411.303861] Node 0 Normal free:114748kB min:52848kB low:66060kB high:79272kB active_anon:3862844kB inactive_anon:949152kB active_file:3939928kB inactive_file:1056436kB unevictable:2124kB isolated(anon):0kB isolated(file):0kB present:13099008kB managed:12835004kB mlocked:2124kB dirty:18912kB writeback:0kB mapped:522412kB shmem:293976kB slab_reclaimable:2350240kB slab_unreclaimable:149904kB kernel_stack:14480kB pagetables:67896kB unstable:0kB bounce:0kB free_pcp:128kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
    [731411.303865] lowmem_reserve[]: 0 0 0 0
    [731411.303866] Node 0 DMA: 1*4kB (U) 1*8kB (U) 1*16kB (U) 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15900kB
    [731411.303874] Node 0 DMA32: 27865*4kB (UME) 1250*8kB (UME) 8*16kB (H) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 121588kB
    [731411.303880] Node 0 Normal: 28673*4kB (UME) 0*8kB 12*16kB (H) 1*32kB (H) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 114916kB
    [731411.303886] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
    [731411.303887] 1660387 total pagecache pages
    [731411.303888] 8583 pages in swap cache
    [731411.303889] Swap cache stats: add 1858410, delete 1849827, find 2903130/3121476
    [731411.303890] Free swap  = 2930992kB
    [731411.303891] Total swap = 4194300kB
    [731411.303892] 4189980 pages RAM
    [731411.303892] 0 pages HighMem/MovableOnly
    [731411.303893] 84929 pages reserved
    [731411.303894] 0 pages hwpoisoned
    ...
    [731411.304181] Out of memory: Kill process 6656 (chromium) score 336 or sacrifice child
    [731411.304204] Killed process 6656 (chromium) total-vm:1874308kB, anon-rss:653584kB, file-rss:75376kB, shmem-rss:14144kB


## Simple Things First

I disabled all the Chrome extensions.  Better? No.

Switched to the Arch Linux Chromium build with new user profiles hoping a locally built version would behave better.  Better? No.

It's not out of memory, the simple fixes didn't work.  What else could it be?  Perhaps I'll run the [memory profiler built-in to Chrome](https://chromium.googlesource.com/chromium/src/+/master/components/tracing/docs/memory_infra.md), but that crashed as well with the the kernel OOM killer or hitting a userspace limit:

   [769989.651467] mmap: chromium (14412): VmData 2741895168 exceed data ulimit 2147483647. Update limits or use boot option ignore_rlimit_data.

And then I remember a long time ago I wrestled with an embedded device with a similar problem and the fix was to increase the minimum reserved memory and the problem never surfaced again. The problem: memory fragmentation.

## Memory Fragmentation

Rather then spend hours proving that it's the right fix on my workstation, I just tested my theory by increasing the `min_free_kbytes` field in the kernel.

Starting point for my system was 67MB:

    ~ ❯❯❯ cat /proc/sys/vm/min_free_kbytes
    67000

And to watch the different size pages become exhausted watch the [buddyinfo](https://www.kernel.org/doc/Documentation/filesystems/proc.txt) file at `/proc/buddyinfo'

    ~ ❯❯❯ watch -dn1 cat /proc/buddyinfo

To test the problem I brought it down to 25MBs and opened a bunch of tabs.  Problem reproduced easier and sooner.

Satisfied with solving something at least close to the real problem led me to just increase it to 1% of my available memory or 160MB:

    ~ ❯❯❯ sudo sysctl -w vm.min_free_kbytes=160000
    vm.min_free_kbytes = 160000

Test again.  This time the problem was very hard to recreate, but still seems plausible with opening an obnoxious number of tabs in a very short period.

Good enough.

## Long Term Fix

The fix, if it's fair to call this a proper fix is to have `sysctl` st the value every time it boots:

    ~ ❯❯❯ echo 'vm.min_free_kbytes=160000' | sudo tee /etc/sysctl.d/10-memory.conf

To attempt to reduce memory fragmentation long term, I also run [The Great Suspender](https://github.com/deanoemcke/thegreatsuspender) to flush out tabs that sit idle for 12+ hours.  I like to think this allows the kernel to coalesce smaller pages into bigger pages, but this might just be wishful thinking.

How about others? Anyone else seen something similar? Leave it in the comments below.
