-- Environment variables of the Hyprland session.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
--
-- Scaling/cursor are deliberately set here (not in .bashrc) so GUI apps render
-- the same regardless of how they were launched (terminal vs. rofi).

-- Pin the integrated GPU (AMD Radeon 680M, pci 0000:34:00.0) so the compositor
-- never uses the discrete card. Machine-specific: `./install --scrub` (non-owner
-- setup) removes this line, so on other hardware wlroots auto-detects the GPU.
hl.env("WLR_DRM_DEVICES", "/dev/dri/by-path/pci-0000:34:00.0-card")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_SCALE_FACTOR", "1.6")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "0")
hl.env("GDK_SCALE", "2")
hl.env("XCURSOR_SIZE", "18")
hl.env("HYPRCURSOR_SIZE", "18")
