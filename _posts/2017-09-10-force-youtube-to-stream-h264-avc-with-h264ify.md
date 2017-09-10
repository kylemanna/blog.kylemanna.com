---
title: "Force YouTube to Stream H.264/AVC with h264ify"
excerpt: "Force YouTube + Chrome to stream encodings that can be decoded by my Radeon RX 470"
category: media
tags: [h265, h264, vp9, hevc, avc, av1, ffmpeg, youtube, gpu]
header:
  image: https://i.imgur.com/pSMgubm.png
  overlay_color: "#000"
  overlay_filter: "0.5"
  overlay_image: https://i.imgur.com/pSMgubm.png
---

## YouTube Streams VP9 by Default

YouTube will stream videos in WebM format whenever it can.  The WebM format selects VP9 for video encoding and Opus for audio encoding.  These are open standards and are great, but they require CPU decoding and that's not acceptable given my [recent efforts](/media/video-acceleration-with-vp9-and-h265/) to leverage hardware video acceleration on my AMD RX 470 GPU.

You can verify this first hand by loading up a [high resolution video](https://www.youtube.com/watch?v=aqz-KE-bpKQ&index=10&list=PL6B3937A5D230E335), right-clicking the video while playing and enabling "Stats for Nerds".  It should look something like the following:

![Big Buck Bunny Playback Screenshot with Nerd Stats Enabled](https://i.imgur.com/4a7rVis.png)

At some point I expect software support to be added to enable VP9 on the RX 470 since the [hardware appears to support it since UVD 6.3](https://en.wikipedia.org/wiki/Unified_Video_Decoder#UVD_6).  Until then, I want to downgrade to H264 (YouTube seems to refuse to support H265/HEVC) to leverage hardware decoding.

## Enter h264ify for Chrome

The [h264ify extension for Chrome](https://github.com/erkserkserks/h264ify) disables VP8/VP9 support to force the use of other codecs, most often H264.  Install the extension and visit [youtube.com/html5](https://youtube.com/html5) to verify missing support for WebM VP8 and WebM VP9.

Return to the video you tried earlier and verify that it is now using the H264/AVC codec and you should observe considerably lower CPU utilization.

![Big Buck Bunny Playback Screenshot with Nerd Stats Enabled and h264ify installed](https://i.imgur.com/yI8m0Xp.png)

## Side Effects

It appears that many of the 4k content on YouTube is just not available in H264/AVC format.  This is unfortunate, but given the choice of higher CPU utilization for resolution I often won't see (unless watching fullscreen), I'll take the reduced CPU utilization.

## Conclusion

I'll continue to use h264ify for better performance and reduced CPU utilization at the expense of lower resolution at times until hardware decoding support for VP9 is added to VA-API for my AMD RX 470.
