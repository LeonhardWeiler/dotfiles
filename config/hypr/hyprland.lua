-- Einstiegspunkt der Hyprland-Konfiguration (Lua).
--
-- Die eigentliche Konfiguration ist thematisch auf Module aufgeteilt
-- (~/.config/hypr/*.lua) und wird hier in fester Reihenfolge geladen. Das
-- Splitting per require() ist das offiziell empfohlene Muster:
--   https://wiki.hypr.land/Configuring/Start/
--
-- Autocompletion/Typen fuer das globale `hl` kommen aus dem Stub
-- (/usr/share/hypr/stubs/hl.meta.lua), eingebunden ueber .luarc.json (lua_ls).
-- Pruefen: `luac -p <datei>.lua`; formatieren mit `stylua` (Tabs).

require("env") -- Umgebungsvariablen der Session
require("monitors") -- Monitor-Setup
require("devices") -- Per-Device-Einstellungen
require("keybinds") -- Tastatur-/Maus-Bindings
require("looknfeel") -- Look & Feel, Layout, Eingabe
require("autostart") -- Autostart beim Session-Start
