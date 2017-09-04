---
title: "Video Acceleration with VP9 and H.265/HEVC"
excerpt: "Experiments with Intel Quick Sync and ffmeg to re-encode old videos"
category: media
tags: [h265, h264, vp9, hevc, avc, av1, ffmpeg]
header:
  image: https://i.imgur.com/r7zEU45.png
  overlay_color: "#000"
  overlay_filter: "0.5"
  overlay_image: https://i.imgur.com/r7zEU45.png
---

## Motivation For Transcoding Videos

I have a collection of old videos from years ago that are encoded with all sorts of codecs but primarily MPEG2 and H.265/MPEG4 AVC. They were generated at different times and different places by different devices like old old cell phones to Go Pros.  Today they spend most of their time occupying space on my harddrive.  The primary motivation is to reduce disk consumption for what is largely data at rest without sacrificing playback performance or image quality.

Overall goals:

* Reduce file size
* Maintain same visual quality which is subjective to my eye
* Ensure that the videos can be played back with hardware accelerated decoders
* No concern for encoding time

To achieve the goals I'll walk you through my codec selection process:
1. Research what the common hardware I have is capable of
2. Verify that the software libraries actually support the hardware decoding
3. Evaluate hardware encoding support provided by Intel Quick Sync vs ffmpeg.
3. Transcode some videos
4. Review video quality, transcode time, etc
5. Repeat steps 3-5 until satisfied with encoder and decoder performance.

## Constraints

There are two constraints: available codecs and available hardware.

### Codecs

The codec list for consideration:
* [H.265 / HEVC](https://en.wikipedia.org/wiki/High_Efficiency_Video_Coding) is a proprietary yet popular video codec aiming to reduce the bitrate to half about half that of H.264.  It has patent licensing terms that require hardware manufacturer to pay per hardware device royalties for hardware codecs.
* [VP9](https://en.wikipedia.org/wiki/VP9) is positioned as a competitor for H.265 developed by Google with no patent licensing restrictions.
* [AV1](https://en.wikipedia.org/wiki/AOMedia_Video_1) is the forthcoming successor to VP9 also without patent licensing restrictions.

### Hardware

My current computers are a Dell Precision 5510 with an [Intel E3-1505M v5](http://ark.intel.com/products/89608/Intel-Xeon-Processor-E3-1505M-v5-8M-Cache-2_80-GHz) and a desktop with an [Intel i7-7700k](https://ark.intel.com/products/97129/Intel-Core-i7-7700K-Processor-8M-Cache-up-to-4_50-GHz).  Both feature Intel's fixed function video acceleration hardware called [Intel Quick Sync](https://en.wikipedia.org/wiki/Intel_Quick_Sync_Video), but the Skylake processor only has H265 decoding on the integrated processor while the Kaby Lake processor support hardware encode and decode of H.265 and VP9.

The desktop PC has a [AMD Radeon RX 470](http://www.amd.com/en-us/products/graphics/radeon-rx-series/radeon-rx-470) as the primary graphics adapter.  The [Unified Video Decoder v6.3](https://en.wikipedia.org/wiki/Unified_Video_Decoder#UVD_6) supports H.265 and VP9 (more on this later) as well.

None of the hardware has any support AV1, and is eliminated as a consideration.  The software codec is still under heavy development and hardware support likely won't follow for for at least 2 years.

## Adventures Enabling Hardware Decoding

Did some testing with mpv on my desktop and laptop.  VA-API seems to be the better way to go and was able to leverage my AMD RX 470 or Intel Kaby Lake Quick Sync and Intel Skylake Quick sync for video decoding.   HEVC was supported by all my computers, but VP9 support was missing on the Skylake laptop.

This quickly ruled out VP9 support.  HEVC support seems much more accessible these days.  I assume VP9 and later AV1 will catch-up.  Until then, my hardware is going H.265/HEVC route.

For reference, the simplest way to evaluate what `mpv` is using for video decoding is with the `mpv --msg-level=vd=debug`

    $ mpv --msg-level=vd=debug Sintel.2010.1080p.mkv
    Playing: Sintel.2010.1080p.mkv
     (+) Video --vid=1 (h264 1920x818 24.000fps)
     (+) Audio --aid=1 --alang=eng 'AC3 5.1 @ 640 Kbps' (ac3 6ch 48000Hz)
         Subs  --sid=1 --slang=ger (subrip)
         Subs  --sid=2 --slang=eng (subrip)
         Subs  --sid=3 --slang=spa (subrip)
         Subs  --sid=4 --slang=fre (subrip)
         Subs  --sid=5 --slang=ita (subrip)
         Subs  --sid=6 --slang=dut (subrip)
         Subs  --sid=7 --slang=pol (subrip)
         Subs  --sid=8 --slang=por (subrip)
         Subs  --sid=9 --slang=rus (subrip)
         Subs  --sid=10 --slang=vie (subrip)
    [vd] Container reported FPS: 24.000002
    [vd] Codec list:
    [vd]     h264 - H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10
    [vd]     h264_cuvid (h264) - Nvidia CUVID H264 decoder
    [vd] Opening video decoder h264
    [vd] Probing 'vaapi'...
    [vd] Trying hardware decoding.
    [vd] Selected video codec: h264 (H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10)
    AO: [pulse] 48000Hz 5.1(side) 6ch float
    [vd] Pixel formats supported by decoder: vdpau vaapi_vld yuv420p
    [vd] Codec profile: High (0x64)
    [vd] Requesting pixfmt 'vaapi_vld' from decoder.
    Using hardware decoding (vaapi).
    [vd] Decoder format: 1920x818 [0:1] vaapi[nv12] bt.709/auto/auto/limited CL=mpeg2/4/h264
    [vd] Using container aspect ratio.
    VO: [vaapi] 1920x818 vaapi[nv12]
    AV: 00:00:02 / 00:14:48 (0%) A-V:  0.000
    [vd] Uninit video.

For more debugging query VA-API with `vainfo`:

    $ vainfo
    libva info: VA-API version 0.40.0
    libva info: va_getDriverName() returns 0
    libva info: Trying to open /usr/lib/dri/radeonsi_drv_video.so
    libva info: Found init function __vaDriverInit_0_40
    libva info: va_openDriver() returns 0
    vainfo: VA-API version: 0.40 (libva )
    vainfo: Driver version: mesa gallium vaapi
    vainfo: Supported profile and entrypoints
          VAProfileMPEG2Simple            : VAEntrypointVLD
          VAProfileMPEG2Main              : VAEntrypointVLD
          VAProfileVC1Simple              : VAEntrypointVLD
          VAProfileVC1Main                : VAEntrypointVLD
          VAProfileVC1Advanced            : VAEntrypointVLD
          VAProfileH264ConstrainedBaseline: VAEntrypointVLD
          VAProfileH264ConstrainedBaseline: VAEntrypointEncSlice
          VAProfileH264Main               : VAEntrypointVLD
          VAProfileH264Main               : VAEntrypointEncSlice
          VAProfileH264High               : VAEntrypointVLD
          VAProfileH264High               : VAEntrypointEncSlice
          VAProfileHEVCMain               : VAEntrypointVLD
          VAProfileHEVCMain10             : VAEntrypointVLD
          VAProfileNone                   : VAEntrypointVideoProc

And the more verbose vdpau method:

    $ vdpauinfo
    display: :1   screen: 0
    API version: 1
    Information string: G3DVL VDPAU Driver Shared Library version 1.0

    Video surface:

    name   width height types
    -------------------------------------------
    420    16384 16384  NV12 YV12
    422    16384 16384  UYVY YUYV
    444    16384 16384  Y8U8V8A8 V8U8Y8A8

    Decoder capabilities:

    name                        level macbs width height
    ----------------------------------------------------
    MPEG1                          --- not supported ---
    MPEG2_SIMPLE                    3 65536  4096  4096
    MPEG2_MAIN                      3 65536  4096  4096
    H264_BASELINE                  52 65536  4096  4096
    H264_MAIN                      52 65536  4096  4096
    H264_HIGH                      52 65536  4096  4096
    VC1_SIMPLE                      1 65536  4096  4096
    VC1_MAIN                        2 65536  4096  4096
    VC1_ADVANCED                    4 65536  4096  4096
    MPEG4_PART2_SP                  3 65536  4096  4096
    MPEG4_PART2_ASP                 5 65536  4096  4096
    DIVX4_QMOBILE                  --- not supported ---
    DIVX4_MOBILE                   --- not supported ---
    DIVX4_HOME_THEATER             --- not supported ---
    DIVX4_HD_1080P                 --- not supported ---
    DIVX5_QMOBILE                  --- not supported ---
    DIVX5_MOBILE                   --- not supported ---
    DIVX5_HOME_THEATER             --- not supported ---
    DIVX5_HD_1080P                 --- not supported ---
    H264_CONSTRAINED_BASELINE       0 65536  4096  4096
    H264_EXTENDED                  --- not supported ---
    H264_PROGRESSIVE_HIGH          --- not supported ---
    H264_CONSTRAINED_HIGH          --- not supported ---
    H264_HIGH_444_PREDICTIVE       --- not supported ---
    HEVC_MAIN                      186 65536  4096  4096
    HEVC_MAIN_10                   186 65536  4096  4096
    HEVC_MAIN_STILL                --- not supported ---
    HEVC_MAIN_12                   --- not supported ---
    HEVC_MAIN_444                  --- not supported ---

    Output surface:

    name              width height nat types
    ----------------------------------------------------
    B8G8R8A8         16384 16384    y  NV12 YV12 UYVY YUYV Y8U8V8A8 V8U8Y8A8 A8I8 I8A8
    R8G8B8A8         16384 16384    y  NV12 YV12 UYVY YUYV Y8U8V8A8 V8U8Y8A8 A8I8 I8A8
    R10G10B10A2      16384 16384    y  NV12 YV12 UYVY YUYV Y8U8V8A8 V8U8Y8A8 A8I8 I8A8
    B10G10R10A2      16384 16384    y  NV12 YV12 UYVY YUYV Y8U8V8A8 V8U8Y8A8 A8I8 I8A8

    Bitmap surface:

    name              width height
    ------------------------------
    B8G8R8A8         16384 16384
    R8G8B8A8         16384 16384
    R10G10B10A2      16384 16384
    B10G10R10A2      16384 16384
    A8               16384 16384

    Video mixer:

    feature name                    sup
    ------------------------------------
    DEINTERLACE_TEMPORAL             y
    DEINTERLACE_TEMPORAL_SPATIAL     -
    INVERSE_TELECINE                 -
    NOISE_REDUCTION                  y
    SHARPNESS                        y
    LUMA_KEY                         y
    HIGH QUALITY SCALING - L1        y
    HIGH QUALITY SCALING - L2        -
    HIGH QUALITY SCALING - L3        -
    HIGH QUALITY SCALING - L4        -
    HIGH QUALITY SCALING - L5        -
    HIGH QUALITY SCALING - L6        -
    HIGH QUALITY SCALING - L7        -
    HIGH QUALITY SCALING - L8        -
    HIGH QUALITY SCALING - L9        -

    parameter name                  sup      min      max
    -----------------------------------------------------
    VIDEO_SURFACE_WIDTH              y        48     4096
    VIDEO_SURFACE_HEIGHT             y        48     4096
    CHROMA_TYPE                      y
    LAYERS                           y         0        4

    attribute name                  sup      min      max
    -----------------------------------------------------
    BACKGROUND_COLOR                 y
    CSC_MATRIX                       y
    NOISE_REDUCTION_LEVEL            y      0.00     1.00
    SHARPNESS_LEVEL                  y     -1.00     1.00
    LUMA_KEY_MIN_LUMA                y
    LUMA_KEY_MAX_LUMA                y



After some experimentation my `~/.config/mpv/mpv.conf` for both the RX 470 machine + Skylake laptop was:

    hwdec=vaapi
    vo=vaapi
    msg-level=vd=debug


After tweaking `mpv` I confirmed that Chromium was leveraging VA-API where possible.  But it was not by default.  This was resolved with the [chromium-vappi AUR package](https://aur.archlinux.org/packages/chromium-vaapi/) on Arch Linux and enabling the `chrome://flags/#enable-accelerated-video` flag.


![Chromium Flags page](https://i.imgur.com/cIN7yIZ.png "Chromium Flags page")

![Chromium GPU page](https://i.imgur.com/uomO8uC.png "Chromium GPU page")

Test playback with a CPU process monitor open and find a 4k 60FPS YouTube Video. I think I saw CPU drop from something like 100% (8 cores = 800%) to sub 20% with video acceleration enabled.

With a little bit of leg work I had both Chromium and `mpv` using hardware accelerated H.265/HEVC decoding on all my machines.

## Encoding

This is a very deep topic after a number of experiments that would take to long to detail here and aren't exhaustive enough to draw a real conclusion I settled on a `ffmpeg` command line below for re-encoding videos (week later still running...)

    crf=26
    preset=medium
    /usr/bin/time -v ffmpeg \
        -vaapi_device /dev/dri/renderD129 -hwaccel vaapi"
        -i "${src}" \
        -vcodec hevc -crf ${crf} -preset ${preset} \
        -acodec copy \
        -threads 7 \
        -y -f matroska \
        -benchmark \
        "${src}.crf${crf}.${preset}.mkv"

I could spend weeks researching this and tweaking it more, but hardware decoding from the Intel Kaby Lake processor and software encoding using 7 cores produced the best image quality and smallest file size.

I chose single pass encoding as it seems to run considerably faster then 2 pass encoding.  The only upside to two pass encoding that I could discern (above all the noise on the Internet) from first hand experience was that it would only allow me have an exact file size.  Since I'm not burning my videos to fixed size media like DVDs or Blu-Ray I see no value in 2 pass encoding.

Intel QuickSync yielded approximately 2.5x faster encoding support, but the resulting file was about 30% bigger with a little more image noise.  I'm sure I could fix this, but didn't have the patience to dig any deeper.  The command line I used was approximately the following:

    /usr/bin/time -v ffmpeg \
        -hwaccel vaapi -i "${src}" \
        -vaapi_device /dev/dri/renderD129 -vf 'format=nv12,hwupload' \
        -vcodec hevc_vaapi -crf ${crf} \
        -acodec copy \
        -threads 8 -y -f matroska \
        "${src}.mkv"


A brief experiment with VP9 encoding just to satisfied my curiosity resulted in larger files.  Some quick Google searches for VP9 support showed that it wasn't up to speed with modern H.265/HEVC implementations and matched my observatoins.  Rumor is that Google's AV1 codec will close the gap in codec performance with H.265/HEVC, so this is something I'll look for when I buy a GPU again in maybe 2 years.  I don't see any value in pursuing VP9 as it produces larger file sizes at the same image quality and has poor software+hardware support.

## Conclusion

It appears that taking some time to re-encode your MPEG4 or H.264 videos will slash your video file size at least in half or save you 30% at worst.  Modern hardware decoding makes it trivial to decode these videos without taking a CPU or power hit.
