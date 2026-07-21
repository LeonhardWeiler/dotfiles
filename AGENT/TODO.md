If you want to shave off more memory

Given your setup (dwl, foot, minimal userland), the remaining meaningful opportunities are:

Replace NetworkManager with systemd-networkd + iwd if you don't need its features.
Disable power-profiles-daemon if you never change power modes.
Disable polkit if your workflow doesn't rely on graphical authorization.
Consider whether you need PipeWire and WirePlumber, or whether plain ALSA would suffice. That can save a few tens of megabytes but at the cost of modern audio features.

Those changes are incremental. They won't halve your idle memory.

I think the battery issue is worth chasing

The continuous BAT0 events are the one thing that genuinely looks abnormal.

If you happen to know your laptop model, or can provide it with:

sudo dmidecode -s system-product-name

that would help determine whether this is a known firmware quirk. Given the RC kernel, I'd also be interested in whether the behavior changes on a stable kernel, because that's a strong indicator of whether you're looking at a firmware characteristic or a kernel regression.
