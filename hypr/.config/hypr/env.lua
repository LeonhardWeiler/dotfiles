-- Umgebungsvariablen der Hyprland-Session.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
--
-- Skalierung/Cursor werden bewusst hier (nicht in der .bashrc) gesetzt, damit
-- GUI-Apps unabhaengig vom Startweg (Terminal vs. Rofi) gleich rendern.

hl.env("WLR_DRM_DEVICES", "/dev/dri/by-path/pci-0000:34:00.0-card")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_SCALE_FACTOR", "1.6")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "0")
hl.env("GDK_SCALE", "2")
hl.env("XCURSOR_SIZE", "18")
hl.env("HYPRCURSOR_SIZE", "18")
