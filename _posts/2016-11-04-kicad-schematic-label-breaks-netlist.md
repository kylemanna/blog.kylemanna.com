---
title: "KiCad Schematic Label Breaks Netlist and Junction Surprises"
excerpt: "One poorly placed label and two nets become one with no ERC warnings and a junction surprise."
category: hardware
tags: [embedded, hardware, kicad, schematic, pcb]
header:
  image: https://i.imgur.com/w2g8RsN.png
  overlay_color: "#000"
  overlay_filter: "0.5"
  overlay_image: https://i.imgur.com/w2g8RsN.png
---

## KiCad Schematic Gotchas

I've stumbled across two surprising things with KiCad that people should be aware of:  

1. The first is pretty subtle having to do with junctions not being consistent and necessary.
2. The second has to do with label placed where two wires cross over and **assigning the same net to two previously unconnected nets**.

For reference, this occurred on KiCad 4.0.4.

## KiCad Junctions Aren't Required on Pins

Most people seasoned with schematic capture tools are familiar with the simple application of jumpers: Use them to connect wires that cross over one another.  If there's no junction and two wires come together, there is no connection.  That's true in KiCad for wires, but not true for pins.

Pins can have any number of connections without junctions.  This seems reasonable, but also somewhat inconsistent.  The electrical rules checker (ERC) will also call out issues with this.

However, those new to KiCad will think the nets are disconnected because they are used to junctions being required for more then 2 connections at a single node.  A fair assumption.

This is relatively harmless, since the ERC tool has your back.

## Label Origins on Wire Intersection

Now this is a big problem and almost burned me once.  My [spidey senses](https://www.google.com/search?safe=off&q=spidey+senses) caught this in layout when hooking up some parts just didn't seem right.  No PCBs were harmed.

If you have two wires crossing each other without a junction, they are not connected, as expected. However, **if you place the origin of a label on the wire intersection thinking you're labeling only one wire, you will in fact connect the nets.**

The ERC tool usually does not detect this.  The labeled net is assigned to both wires and nobody notices.  However, if both nets are classified as outputs, you'll get a ERC warning about two sources driving the same net.  But, many times this is not the case.

Nobody would (probably) put a label like this to start, but after re-organizing a schematic and moving things here and there, it's possible for the label to end up on an intersection like this on accident.

## Test Case

To prove my case I made a [simple KiCad project](https://github.com/kylemanna/kicad-netlist-headache) to illustrate my point.

### The KiCad Schematic

First, let's draw both.

[![KiCad Schematic](http://i.imgur.com/L5bCNhJ.png)](http://i.imgur.com/L5bCNhJ.png)

On the left is the union of multiple things (without wires in this case for simplicity).  Note that P1, R1 and C1 are all connected at the same pin without a junction.  No issues.  This seems mostly what was expected.  If C1 and R1 were connected to P1 via wires, it would work as well.  To restate my observation: **More then two wires can connect to each other without a junction as long as they intersect at a schematic symbol's pin.** And the above schematic works out.

On the right you'll see what looks like a strangely drawn resistor to perhaps terminate something on a connector.  Fine, and reasonable, just looks odd.

Hidden in the oddl ooks in that both sides of the resistor are connected tot he same net labeled `LABEL`.  Not obvious at all right?

Maybe you don't believe me?  Check the ERC, it passes.  Then check the netlist by looking at the layout.

### The KiCad Board Layout

[![KiCad Board Layout Surprise](http://i.imgur.com/w2g8RsN.png)](http://i.imgur.com/w2g8RsN.png)

On the left everything looks as expected and is connected.

On the right, look at the ratsnest wire as well as PCB pad net names and you'll see that **everything is connected to the `LABEL` net**.  If you made a board like this, you're probably in trouble.

## Conclusion

Are these bugs?  The junction issue probably isn't, it's just inconsistent.  The label intersection issue probably should be detected by the ERC unless a junction is present.

I'll file a [bug report](https://bugs.launchpad.net/kicad/+bug/1639329) and see what happens.  In the mean time, don't do this.
