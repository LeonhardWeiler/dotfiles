-- Tastatur- und Maus-Bindings.
-- See https://wiki.hypr.land/Configuring/Basics/Binds/

local p = require("programs")
local mainMod = "ALT" -- Haupt-Modifier

-- Programme starten / Fenster steuern
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd(p.terminal))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exit())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd(p.menu))
hl.bind(mainMod .. " + SHIFT + o", hl.dsp.exec_cmd(p.pass))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd(p.files))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd(p.browser))
hl.bind("SUPER + L", hl.dsp.exec_cmd(p.lock))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(p.wsmgr))

-- Fokus im Master-Layout wechseln
hl.bind(mainMod .. " + J", hl.dsp.layout("cyclenext"))
hl.bind(mainMod .. " + K", hl.dsp.layout("cycleprev"))

-- Aktives Fenster vergroessern/verkleinern
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })

-- Aktives Fenster verschieben
hl.bind(mainMod .. " + CTRL + SHIFT + h", hl.dsp.window.move({ x = -20, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + SHIFT + j", hl.dsp.window.move({ x = 0, y = -20, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + SHIFT + k", hl.dsp.window.move({ x = 0, y = 20, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + SHIFT + l", hl.dsp.window.move({ x = 20, y = 0, relative = true }), { repeating = true })

-- Vollbild / Master-Tausch
hl.bind(mainMod .. " + m", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mainMod .. " + z", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + Return", hl.dsp.layout("swapwithmaster"))

-- Workspaces 1-6: fokussieren (mainMod) bzw. Fenster verschieben (mainMod+SHIFT)
for i = 1, 6 do
	hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Maus: Fenster ziehen / groessen
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())

-- Multimedia-Tasten (locked = auch im gesperrten Zustand)
hl.bind(mainMod .. " + F3", hl.dsp.exec_cmd("~/.config/scripts/vol_ctl up"), { locked = true, repeating = true })
hl.bind(mainMod .. " + F2", hl.dsp.exec_cmd("~/.config/scripts/vol_ctl down"), { locked = true, repeating = true })
hl.bind(mainMod .. " + F1", hl.dsp.exec_cmd("~/.config/scripts/vol_ctl mute"), { locked = true, repeating = true })
hl.bind(mainMod .. " + F6", hl.dsp.exec_cmd("~/.config/scripts/bright_ctl up"), { locked = true, repeating = true })
hl.bind(mainMod .. " + F5", hl.dsp.exec_cmd("~/.config/scripts/bright_ctl down"), { locked = true, repeating = true })

-- Screenshot (Region -> Zwischenablage)
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
