# SPDX-License-Identifier: ISC
# Copyright (C) 2026 The leonhardweiler/dotfiles Authors
#
# Rewrite colors into the palette. Two modes, one rule:
#
#   default        stdin is text (SVG/QSS/XML); rewrite every color literal
#                  in it and print the text back.
#   MODE=pixels    stdin is `od -An -tu1 -v -w4` output of a raw RGBA image,
#                  one pixel per line; write the recolored pixels back as raw
#                  bytes. This exists because the VU meters ship as PNG, not
#                  SVG, and a bright green level bar is not something the skin
#                  can be left with. Doing it here rather than with an image
#                  filter keeps the color rule in exactly one place.
#                  Must be run under LC_ALL=C: that is what makes awk's %c
#                  emit one byte rather than a multi-byte UTF-8 encoding.
#
# The rule, in one sentence: keep the lightness, replace hue and saturation.
# Lightness is what upstream encodes a button's *state* in - unpressed,
# pressed, hovered, disabled are the same hue at different L, and every
# gradient and drop shadow is a lightness ramp. Rewriting only H and S
# therefore recolors the skin without flattening any of it.
#
# Reads the palette on the command line (see build-skin); everything it needs
# arrives as -v assignments plus the HUE_FAMILIES string.
#
# Recognises #rgb, #argb, #rrggbb and #aarrggbb. Alpha is carried through
# untouched. Two things that look like colors but are not, and are skipped:
# a run of hex digits followed by another alphanumeric character, which is an
# identifier (`url(#defs)`), and anything preceded by `&`, which is an XML
# character reference - `&#8855;` is the circled-times glyph on a button, and
# rewriting it as #88/#554446 both breaks the label and produces invalid XML.

function hex2num(s,   i, c, n, d) {
    n = 0
    for (i = 1; i <= length(s); i++) {
        c = tolower(substr(s, i, 1))
        d = index("0123456789abcdef", c) - 1
        n = n * 16 + d
    }
    return n
}

function num2hex(n,   d) {
    n = int(n + 0.5)
    if (n < 0) n = 0
    if (n > 255) n = 255
    d = "0123456789abcdef"
    return substr(d, int(n / 16) + 1, 1) substr(d, (n % 16) + 1, 1)
}

# --- RGB <-> HSL, all channels 0..1 except hue in degrees -------------------

function rgb2hsl(r, g, b,   mx, mn, d) {
    mx = (r > g ? r : g); if (b > mx) mx = b
    mn = (r < g ? r : g); if (b < mn) mn = b
    HSL_L = (mx + mn) / 2
    d = mx - mn
    if (d == 0) { HSL_H = 0; HSL_S = 0; return }
    HSL_S = (HSL_L > 0.5) ? d / (2 - mx - mn) : d / (mx + mn)
    if (mx == r)      HSL_H = (g - b) / d + (g < b ? 6 : 0)
    else if (mx == g) HSL_H = (b - r) / d + 2
    else              HSL_H = (r - g) / d + 4
    HSL_H *= 60
}

function hue2rgb(p, q, t) {
    if (t < 0) t += 1
    if (t > 1) t -= 1
    if (t < 1/6) return p + (q - p) * 6 * t
    if (t < 1/2) return q
    if (t < 2/3) return p + (q - p) * (2/3 - t) * 6
    return p
}

function hsl2hex(h, s, l,   q, p, hk) {
    if (s <= 0) { q = num2hex(l * 255); return q q q }
    q = (l < 0.5) ? l * (1 + s) : l + s - l * s
    p = 2 * l - q
    hk = h / 360
    return num2hex(hue2rgb(p, q, hk + 1/3) * 255) \
           num2hex(hue2rgb(p, q, hk) * 255) \
           num2hex(hue2rgb(p, q, hk - 1/3) * 255)
}

# --- The palette -----------------------------------------------------------

# Split "345 360 warn|0 14 warn|..." into parallel arrays once.
function load_families(   n, i, parts, f) {
    n = split(HUE_FAMILIES, parts, "|")
    for (i = 1; i <= n; i++) {
        split(parts[i], f, " ")
        FAM_FROM[i] = f[1] + 0
        FAM_TO[i]   = f[2] + 0
        FAM_HEX[i]  = f[3]
    }
    FAM_N = n
}

# Hue of a palette color, as the target for a family.
function family_target(hex,   r, g, b) {
    r = hex2num(substr(hex, 2, 2)) / 255
    g = hex2num(substr(hex, 4, 2)) / 255
    b = hex2num(substr(hex, 6, 2)) / 255
    rgb2hsl(r, g, b)
    # HSL_H is left in place for the caller.
}

function target_hue(h,   i) {
    for (i = 1; i <= FAM_N; i++)
        if (h >= FAM_FROM[i] && h <= FAM_TO[i]) return FAM_HEX[i]
    return FAM_HEX[1]
}

# --- The rule itself -------------------------------------------------------

function convert(rgb,   r, g, b, h, s, l, tgt, th, ns) {
    if (rgb in CACHE) return CACHE[rgb]

    r = hex2num(substr(rgb, 1, 2)) / 255
    g = hex2num(substr(rgb, 3, 2)) / 255
    b = hex2num(substr(rgb, 5, 2)) / 255
    rgb2hsl(r, g, b)
    h = HSL_H; s = HSL_S; l = HSL_L

    if (s * 100 <= NEUTRAL_MAX_S) {
        # Already neutral. Upstream's greys are the same greys we want.
        CACHE[rgb] = rgb
        return rgb
    }

    if (s * 100 <= SURFACE_MAX_S) {
        # A tinted surface, not an accent - PaleMoon's warm moonlight cast on
        # button faces and panels. Flatten it to true grey so the skin reads
        # neutral like the terminal does.
        CACHE[rgb] = hsl2hex(0, 0, l)
        return CACHE[rgb]
    }

    # A real accent. Map its hue onto the palette and pull the saturation into
    # the muted band; a 100%-saturated upstream orange must not come out as a
    # neon green.
    tgt = target_hue(h)
    family_target(tgt)
    th = HSL_H

    ns = ACCENT_MIN_S + (ACCENT_MAX_S - ACCENT_MIN_S) \
         * (s * 100 - SURFACE_MAX_S) / (100 - SURFACE_MAX_S)
    # A light tint reads far louder than a dark one at the same saturation.
    if (l * 100 > BRIGHT_L) ns *= BRIGHT_S_FACTOR
    CACHE[rgb] = hsl2hex(th, ns / 100, l)
    return CACHE[rgb]
}

# --- Scanning --------------------------------------------------------------

function is_alnum(c) { return c ~ /^[0-9A-Za-z_]$/ }

BEGIN { load_families() }

# --- Pixel mode ------------------------------------------------------------
# Fully transparent pixels carry no visible color; recoloring them would only
# change what shows through a resize filter later.

MODE == "pixels" {
    a = $4
    if (a == 0) { printf "%c%c%c%c", $1, $2, $3, a; next }
    new = convert(num2hex($1) num2hex($2) num2hex($3))
    printf "%c%c%c%c", hex2num(substr(new, 1, 2)), hex2num(substr(new, 3, 2)), \
                       hex2num(substr(new, 5, 2)), a
    next
}

{
    out = ""
    rest = $0
    while (match(rest, /#[0-9a-fA-F]+/)) {
        pre = substr(rest, 1, RSTART - 1)
        tok = substr(rest, RSTART, RLENGTH)
        rest = substr(rest, RSTART + RLENGTH)

        digits = substr(tok, 2)
        n = length(digits)
        # An identifier that merely starts with hex digits is not a color,
        # and neither is an XML character reference.
        if ((rest != "" && is_alnum(substr(rest, 1, 1))) \
            || (pre != "" && substr(pre, length(pre), 1) == "&")) {
            out = out pre tok
            continue
        }

        alpha = ""
        rgb = ""
        if (n == 3) {
            rgb = substr(digits,1,1) substr(digits,1,1) \
                  substr(digits,2,1) substr(digits,2,1) \
                  substr(digits,3,1) substr(digits,3,1)
        } else if (n == 4) {
            alpha = substr(digits,1,1) substr(digits,1,1)
            rgb = substr(digits,2,1) substr(digits,2,1) \
                  substr(digits,3,1) substr(digits,3,1) \
                  substr(digits,4,1) substr(digits,4,1)
        } else if (n == 6) {
            rgb = digits
        } else if (n == 8) {
            alpha = substr(digits, 1, 2)
            rgb = substr(digits, 3)
        } else {
            out = out pre tok
            continue
        }

        out = out pre "#" alpha convert(tolower(rgb))
    }
    print out rest
}
