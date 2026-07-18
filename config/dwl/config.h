/* dwl configuration. dwl is configured at COMPILE time: edit this file and
 * rebuild (config/dwl/build-dwl, or `./install --dwl`). See config/dwl/README.md
 * for the keybind overview.
 *
 * Base: dwl 0.8 config.def.h (codeberg.org/dwl/dwl) plus the gaps patch
 * (config/dwl/patches/gaps.patch). Struct field order must match the dwl version
 * being built. */

/* Taken from https://github.com/djpohly/dwl/issues/466 */
#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                        ((hex >> 16) & 0xFF) / 255.0f, \
                        ((hex >> 8) & 0xFF) / 255.0f, \
                        (hex & 0xFF) / 255.0f }
/* appearance */
static const int sloppyfocus               = 1;  /* focus follows mouse */
static const int bypass_surface_visibility = 0;
static const unsigned int borderpx         = 0;  /* window border width */
static const float rootcolor[]             = COLOR(0x000000ff);
static const float bordercolor[]           = COLOR(0x595959ff); /* unfocused border */
static const float focuscolor[]            = COLOR(0xddddddff); /* focused border */
static const float urgentcolor[]           = COLOR(0xff0000ff);
/* This conforms to the xdg-protocol. Set the alpha to zero to restore the old behavior */
static const float fullscreen_bg[]         = {0.0f, 0.0f, 0.0f, 1.0f};

/* gaps (px, from the gaps patch) - inner = between windows, outer = screen edge */
static const unsigned int gappih = 3;  /* inner horizontal */
static const unsigned int gappiv = 3;  /* inner vertical */
static const unsigned int gappoh = 6;  /* outer horizontal */
static const unsigned int gappov = 6;  /* outer vertical */

/* tagging - 6 tags. TAGCOUNT must be <= 31. ALT+1..6 view a tag, ALT+SHIFT+1..6
 * move the focused window to a tag. */
#define TAGCOUNT (6)

/* logging */
static int log_level = WLR_ERROR;

static const Rule rules[] = {
	/* app_id             title       tags mask     isfloating   monitor */
	/* At least one rule must exist; this one is a harmless placeholder. */
	{ "__never_matches",  NULL,       0,            0,           -1 },
};

/* layout(s) - "tile" is the master-stack layout; floating and monocle stay
 * available for togglefullscreen and per-window floating. */
static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
};

/* monitors.
 * (x=-1, y=-1) means "auto-arrange"; the external output lands to the right of
 * eDP-1. Set fixed x/y here for a specific layout. */
static const MonitorRule monrules[] = {
	/* name        mfact  nmaster scale  layout       rotate/reflect               x    y */
	{ "eDP-1",     0.55f, 1,      1.6f,  &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,  -1,  -1 },
	{ "HDMI-A-1",  0.55f, 1,      1.0f,  &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,  -1,  -1 },
	/* fallback rule for any other output (at least one rule must exist) */
	{ NULL,        0.55f, 1,      1.0f,  &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,  -1,  -1 },
};

/* keyboard */
static const struct xkb_rule_names xkb_rules = {
	.layout  = "us",
	.variant = "colemak_dh",
	.options = "caps:swapescape",
};

static const int repeat_rate  = 25;
static const int repeat_delay = 300;

/* Trackpad */
static const int tap_to_click = 1;
static const int tap_and_drag = 1;
static const int drag_lock = 1;
static const int natural_scrolling = 0;
static const int disable_while_typing = 1;
static const int left_handed = 0;
static const int middle_button_emulation = 0;
static const enum libinput_config_scroll_method scroll_method = LIBINPUT_CONFIG_SCROLL_2FG;
static const enum libinput_config_click_method click_method = LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS;
static const uint32_t send_events_mode = LIBINPUT_CONFIG_SEND_EVENTS_ENABLED;
static const enum libinput_config_accel_profile accel_profile = LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE;
static const double accel_speed = 0.0;
static const enum libinput_config_tap_button_map button_map = LIBINPUT_CONFIG_TAP_MAP_LRM;

/* main modifier */
#define MODKEY WLR_MODIFIER_ALT

/* Tag keys: ALT+n = view tag n, ALT+SHIFT+n = move window to tag n; CTRL /
 * CTRL+SHIFT add the toggleview / toggletag variants. */
#define TAGKEYS(KEY,SKEY,TAG) \
	{ MODKEY,                    KEY,            view,            {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL,  KEY,            toggleview,      {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_SHIFT, SKEY,           tag,             {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT,SKEY,toggletag, {.ui = 1 << TAG} }

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static const char *termcmd[]    = { "foot", NULL };
static const char *menucmd[]    = { "rofi", "-show", "drun", NULL };
static const char *filescmd[]   = { "rofi", "-show", "filebrowser", NULL };
static const char *browsercmd[] = { "zen-browser", NULL };
static const char *lockcmd[]    = { "hyprlock", NULL };

static const Key keys[] = {
	/* modifier                     key              function          argument */
	/* Launch programs / control windows */
	{ MODKEY|WLR_MODIFIER_SHIFT,    XKB_KEY_Return,  spawn,            {.v = termcmd} },
	{ MODKEY|WLR_MODIFIER_SHIFT,    XKB_KEY_c,       killclient,       {0} },
	{ MODKEY|WLR_MODIFIER_SHIFT,    XKB_KEY_q,       quit,             {0} },
	{ MODKEY,                       XKB_KEY_v,       togglefloating,   {0} },
	{ MODKEY|WLR_MODIFIER_SHIFT,    XKB_KEY_p,       spawn,            {.v = menucmd} },
	{ MODKEY|WLR_MODIFIER_SHIFT,    XKB_KEY_t,       spawn,            {.v = filescmd} },
	{ MODKEY|WLR_MODIFIER_SHIFT,    XKB_KEY_n,       spawn,            {.v = browsercmd} },
	{ WLR_MODIFIER_LOGO,            XKB_KEY_l,       spawn,            {.v = lockcmd} },

	/* Focus in the master/stack */
	{ MODKEY,                       XKB_KEY_j,       focusstack,       {.i = +1} },
	{ MODKEY,                       XKB_KEY_k,       focusstack,       {.i = -1} },

	/* Master area width */
	{ MODKEY|WLR_MODIFIER_SHIFT,    XKB_KEY_h,       setmfact,         {.f = -0.05f} },
	{ MODKEY|WLR_MODIFIER_SHIFT,    XKB_KEY_l,       setmfact,         {.f = +0.05f} },

	/* Fullscreen / master swap */
	{ MODKEY,                       XKB_KEY_m,       togglefullscreen, {0} },
	{ MODKEY,                       XKB_KEY_z,       togglefullscreen, {0} },
	{ MODKEY,                       XKB_KEY_Return,  zoom,             {0} },

	/* Tags 1-6 */
	TAGKEYS(          XKB_KEY_1, XKB_KEY_exclam,                       0),
	TAGKEYS(          XKB_KEY_2, XKB_KEY_at,                           1),
	TAGKEYS(          XKB_KEY_3, XKB_KEY_numbersign,                   2),
	TAGKEYS(          XKB_KEY_4, XKB_KEY_dollar,                       3),
	TAGKEYS(          XKB_KEY_5, XKB_KEY_percent,                      4),
	TAGKEYS(          XKB_KEY_6, XKB_KEY_asciicircum,                  5),

	/* Multimedia keys */
	{ MODKEY,                       XKB_KEY_F3,      spawn, SHCMD("~/.local/bin/vol_ctl up") },
	{ MODKEY,                       XKB_KEY_F2,      spawn, SHCMD("~/.local/bin/vol_ctl down") },
	{ MODKEY,                       XKB_KEY_F1,      spawn, SHCMD("~/.local/bin/vol_ctl mute") },
	{ MODKEY,                       XKB_KEY_F6,      spawn, SHCMD("~/.local/bin/bright_ctl up") },
	{ MODKEY,                       XKB_KEY_F5,      spawn, SHCMD("~/.local/bin/bright_ctl down") },

	/* Screenshot (region -> clipboard) */
	{ 0,                            XKB_KEY_Print,   spawn, SHCMD("grim -g \"$(slurp)\" - | wl-copy") },

	/* Ctrl-Alt-Backspace and Ctrl-Alt-Fx: VT-switch escape hatches. */
	{ WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_Terminate_Server, quit, {0} },
#define CHVT(n) { WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_XF86Switch_VT_##n, chvt, {.ui = (n)} }
	CHVT(1), CHVT(2), CHVT(3), CHVT(4), CHVT(5), CHVT(6),
	CHVT(7), CHVT(8), CHVT(9), CHVT(10), CHVT(11), CHVT(12),
};

/* Mouse: ALT+left = move, ALT+right = resize, ALT+middle = togglefloating. */
static const Button buttons[] = {
	{ MODKEY, BTN_LEFT,   moveresize,     {.ui = CurMove} },
	{ MODKEY, BTN_MIDDLE, togglefloating, {0} },
	{ MODKEY, BTN_RIGHT,  moveresize,     {.ui = CurResize} },
};
