-- Entry point of the Hyprland configuration (Lua).
--
-- The actual configuration is split thematically into modules
-- (~/.config/hypr/*.lua) and loaded here in a fixed order. Splitting via
-- require() is the officially recommended pattern:
--   https://wiki.hypr.land/Configuring/Start/
--
-- Autocompletion/types for the global `hl` come from the stub
-- (/usr/share/hypr/stubs/hl.meta.lua), included via .luarc.json (lua_ls).
-- Check with `luac -p <file>.lua`; format with `stylua` (tabs).

require("env") -- session environment variables
require("monitors") -- monitor setup
require("devices") -- per-device settings
require("keybinds") -- keyboard/mouse bindings
require("looknfeel") -- look & feel, layout, input
require("autostart") -- autostart at session start
