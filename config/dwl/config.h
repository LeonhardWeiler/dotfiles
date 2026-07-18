/* dwl configuration - ported 1:1 (where possible) from the Hyprland config
 * under config/hypr/. dwl is configured at COMPILE time: edit this file and
 * rebuild (config/dwl/build-dwl, or `./install --dwl`). See config/dwl/README.md
 * for the mapping and the points that could NOT be reproduced 1:1.
 *
 * Base: dwl 0.8 config.def.h (codeberg.org/dwl/dwl). Struct field order must
 * match the dwl version being built. */

/* Taken from https://github.com/djpohly/dwl/issues/466 */
#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                        ((hex >> 16) & 0xFF) / 255.0f, \
                        ((hex >> 8) & 0xFF) / 255.0f, \
                        (hex & 0xFF) / 255.0f }
/* appearance */
static const int sloppyfocus               = 1;  /* hypr input.follow_mouse = 1 */
static const int bypass_surface_visibility = 0;
static const unsigned int borderpx         = 0;  /* hypr general.border_size = 0 */
static const float rootcolor[]             = COLOR(0x000000ff);
static const float bordercolor[]           = COLOR(0x595959ff); /* hypr inactive_border rgb(595959) */
static const float focuscolor[]            = COLOR(0xddddddff); /* hypr active_border  rgb(dddddd) */
static const float urgentcolor[]           = COLOR(0xff0000ff);
/* This conforms to the xdg-protocol. Set the alpha to zero to restore the old behavior */
static const float fullscreen_bg[]         = {0.0f, 0.0f, 0.0f, 1.0f};

/* tagging - 6 tags to mirror the 6 Hyprland workspaces (TAGCOUNT must be <= 31).
 * NOTE: dwl "tags" are not identical to Hyprland "workspaces" (a window can hold
 * several tags, several tags can be viewed at once), but ALT+1..6 (view) and
 * ALT+SHIFT+1..6 (move) behave like workspace switching for everyday use. */
#define TAGCOUNT (6)

/* logging */
static int log_level = WLR_ERROR;

static const Rule rules[] = {
	/* app_id             title       tags mask     isfloating   monitor */
	/* At least one rule must exist; this one is a harmless placeholder. */
	{ "__never_matches",  NULL,       0,            0,           -1 },
};

/* layout(s) - Hyprland ran the master layout only; dwl "tile" is the equivalent
 * master-stack layout. Floating/monocle stay available for togglefullscreen and
 * per-window floating. */
static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
};

/* monitors - ported from config/hypr/monitors.lua.
 * (x=-1, y=-1) means "auto-arrange". The Hyprland HDMI position (2560x0) is not
 * reproduced literally because dwl's x/y live in the SCALED layout space, not
 * Hyprland's; auto-arrange places the external screen to the right of eDP-1,
 * which matches the intended layout. Adjust x/y here if you need a fixed spot. */
static const MonitorRule monrules[] = {
	/* name        mfact  nmaster scale  layout       rotate/reflect               x    y */
	{ "eDP-1",     0.55f, 1,      1.6f,  &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,  -1,  -1 },
	{ "HDMI-A-1",  0.55f, 1,      1.0f,  &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,  -1,  -1 },
	/* fallback rule for any other output (at least one rule must exist) */
	{ NULL,        0.55f, 1,      1.0f,  &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,  -1,  -1 },
};

/* keyboard - ported from config/hypr/looknfeel.lua (input block). */
static const struct xkb_rule_names xkb_rules = {
	.layout  = "us",
	.variant = "colemak_dh",
	.options = "caps:swapescape",
};

static const int repeat_rate  = 25;
static const int repeat_delay = 300; /* hypr input.repeat_delay = 300 */

/* Trackpad - hypr touchpad.natural_scroll = false. */
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

/* main modifier - hypr mainMod = ALT */
#define MODKEY WLR_MODIFIER_ALT

/* Tag keys: ALT+n = view tag n, ALT+SHIFT+n = move window to tag n (mirrors the
 * Hyprland workspace binds). CTRL / CTRL+SHIFT toggles are dwl extras and do not
 * clash with anything from the Hyprland config. */
#define TAGKEYS(KEY,SKEY,TAG) \
	{ MODKEY,                    KEY,            view,            {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL,  KEY,            toggleview,      {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_SHIFT, SKEY,           tag,             {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT,SKEY,toggletag, {.ui = 1 << TAG} }

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands - from config/hypr/programs.lua */
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

	/* Focus in the master/stack (hypr J/K = cyclenext/cycleprev) */
	{ MODKEY,                       XKB_KEY_j,       focusstack,       {.i = +1} },
	{ MODKEY,                       XKB_KEY_k,       focusstack,       {.i = -1} },

	/* Master area width (closest tiled equivalent of hypr's horizontal resize;
	 * hypr's vertical resize and pixel-exact moves have no tiled counterpart -
	 * see README). */
	{ MODKEY|WLR_MODIFIER_SHIFT,    XKB_KEY_h,       setmfact,         {.f = -0.05f} },
	{ MODKEY|WLR_MODIFIER_SHIFT,    XKB_KEY_l,       setmfact,         {.f = +0.05f} },

	/* Fullscreen / master swap. dwl has no separate "maximized" vs "fullscreen":
	 * both hypr binds map to togglefullscreen. */
	{ MODKEY,                       XKB_KEY_m,       togglefullscreen, {0} },
	{ MODKEY,                       XKB_KEY_z,       togglefullscreen, {0} },
	{ MODKEY,                       XKB_KEY_Return,  zoom,             {0} },

	/* Workspaces 1-6 -> tags 1-6 */
	TAGKEYS(          XKB_KEY_1, XKB_KEY_exclam,                       0),
	TAGKEYS(          XKB_KEY_2, XKB_KEY_at,                           1),
	TAGKEYS(          XKB_KEY_3, XKB_KEY_numbersign,                   2),
	TAGKEYS(          XKB_KEY_4, XKB_KEY_dollar,                       3),
	TAGKEYS(          XKB_KEY_5, XKB_KEY_percent,                      4),
	TAGKEYS(          XKB_KEY_6, XKB_KEY_asciicircum,                  5),

	/* Multimedia keys (ALT+Fx as in Hyprland). NOTE: unlike Hyprland's
	 * locked=true, dwl does not run keybinds while the session is locked. */
	{ MODKEY,                       XKB_KEY_F3,      spawn, SHCMD("~/.local/bin/vol_ctl up") },
	{ MODKEY,                       XKB_KEY_F2,      spawn, SHCMD("~/.local/bin/vol_ctl down") },
	{ MODKEY,                       XKB_KEY_F1,      spawn, SHCMD("~/.local/bin/vol_ctl mute") },
	{ MODKEY,                       XKB_KEY_F6,      spawn, SHCMD("~/.local/bin/bright_ctl up") },
	{ MODKEY,                       XKB_KEY_F5,      spawn, SHCMD("~/.local/bin/bright_ctl down") },

	/* Screenshot (region -> clipboard). hyprshot is Hyprland-only, so this uses
	 * grim + slurp + wl-copy. */
	{ 0,                            XKB_KEY_Print,   spawn, SHCMD("grim -g \"$(slurp)\" - | wl-copy") },

	/* Ctrl-Alt-Backspace and Ctrl-Alt-Fx: keep the VT-switch escape hatches. */
	{ WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_Terminate_Server, quit, {0} },
#define CHVT(n) { WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_XF86Switch_VT_##n, chvt, {.ui = (n)} }
	CHVT(1), CHVT(2), CHVT(3), CHVT(4), CHVT(5), CHVT(6),
	CHVT(7), CHVT(8), CHVT(9), CHVT(10), CHVT(11), CHVT(12),
};

/* Mouse: ALT+left = move, ALT+right = resize (hypr mouse:272 / mouse:273).
 * ALT+middle = togglefloating is a harmless dwl extra. */
static const Button buttons[] = {
	{ MODKEY, BTN_LEFT,   moveresize,     {.ui = CurMove} },
	{ MODKEY, BTN_MIDDLE, togglefloating, {0} },
	{ MODKEY, BTN_RIGHT,  moveresize,     {.ui = CurResize} },
};
