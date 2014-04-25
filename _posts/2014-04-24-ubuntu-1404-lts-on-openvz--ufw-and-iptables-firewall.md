---
layout: post
title: "Ubuntu 14.04 LTS on OpenVZ + ufw and iptables Firewall"
tagline: "ufw drama"
category: linux
tags: [linux, vps, openvz, ufw, iptables]
---
{% include JB/setup %}

I upgraded my P.O.S. OpenVZ VPS (KVM from now on...) from Ubuntu 12.04.4 LTS to 14.04 LTS today and ran in to some problems with the firewall rules.  Everytime I'd reboot the VPS, it would to setup all the firewall rules setup by ufw, most notably the application allow rules (ie ssh) and the INPUT chain policy.  Kind of dangerous.

# Debugging

Running <code>/lib/ufw/ufw-init force-reload</code> manually returns:

	iptables-restore: line 4 failed
	ip6tables-restore: line 4 failed

# Fixing

Some digging revealed that this is the result of a semantics change in the iptables rules broke <code>/lib/ufw/ufw-init-functions</code>.  Around line 263 the culprit can be found.  The two changes: <code>-m conntrack --ctstate</code> -&gt; <code>-m state --state</code>.  The following works for me now until the next update clobbers it:

				# add tracking policy
				if [ "$DEFAULT_INPUT_POLICY" = "ACCEPT" ]; then
					printf "*filter\n"\
	"-A ufw${type}-track-input -p tcp -m state --state NEW -j ACCEPT\n"\
	"-A ufw${type}-track-input -p udp -m state --state NEW -j ACCEPT\n"\
	"COMMIT\n" | $exe-restore -n || error="yes"
				fi

				if [ "$DEFAULT_OUTPUT_POLICY" = "ACCEPT" ]; then
					printf "*filter\n"\
	"-A ufw${type}-track-output -p tcp -m state --state NEW -j ACCEPT\n"\
	"-A ufw${type}-track-output -p udp -m state --state NEW -j ACCEPT\n"\
	"COMMIT\n" | $exe-restore -n || error="yes"
				fi

				if [ "$DEFAULT_FORWARD_POLICY" = "ACCEPT" ]; then
					printf "*filter\n"\
	"-A ufw${type}-track-forward -p tcp -m state --state NEW -j ACCEPT\n"\
	"-A ufw${type}-track-forward -p udp -m state --state NEW -j ACCEPT\n"\
	"COMMIT\n" | $exe-restore -n || error="yes"
				fi

That should do it on top of applying similar updates to rules in <code>/etc/ufw</code> and the hacks I had [previously done in Ubuntu 12.04](/linux/2013/04/26/ufw-vps/).

# Next Steps

The real problem is that OpenVZ and ufw are crap.  Put an ancient kernel from OpenVZ (2.6.32-042stab078.26) and ufw together and there will be drama.  Next step is to get a better VPS (something with KVM, recommendations?).  And inevitably when the ufw package is updated in Ubuntu and undoes this change I'll probably convert back to straight iptables-save/restore files like I do in Arch.  None of those hacked up automatic firewall configuration shell scripts with a million variables -- just iptables-save output and simple iptables-restore script.  Life will be blissful again.
