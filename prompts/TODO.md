# Dotfiles – Aufgabenplanung

Sammlung geplanter, noch **nicht umgesetzter** Arbeiten am Dotfiles-Repo.
Ein Commit pro abgearbeitetem Punkt (siehe Skill `implement-todo`).

> **Erledigt:** P11 (Repo-Umbau auf `config/` + `scripts/`) ist umgesetzt und
> end-to-end verifiziert. P12 (kritische Config-Bewertung) ist als Bewertung
> abgeschlossen; die daraus abgeleiteten **Fixes** stehen unten (P13) und sind
> als Findings `CFG-*` im Health-Report dokumentiert.

---

## P13 – Config-Fixes aus der P12-Bewertung umsetzen

Reaktion auf die Findings in `prompts/project-health-report.html`. Reihenfolge
grob nach Priorität. Jeder Punkt = eigener Commit; nach dem Umsetzen das
zugehörige Finding aus dem Report **entfernen** und Zähler anpassen.

- [ ] **CFG-QT-2 fix** (mittel) – Qt-Platform-Theme vereinheitlichen. Klären, ob
      die GUI-Apps Qt5 oder Qt6 sind, dann `QT_QPA_PLATFORMTHEME` in
      `config/hypr/.config/hypr/env.lua` **und** `config/bash/.bash_profile`
      konsistent setzen. Bei Qt6: `qt6ct`-Config als Stow-Paket anlegen (bzw.
      `qt5ct.conf` übernehmen).
- [ ] **CFG-BTOP-1 fix** (niedrig) – `config/btop/.config/btop/btop.conf` gegen
      btop-Defaults abgleichen und auf die bewusst geänderten Keys eindampfen.
- [ ] **CFG-LY-1 fix** (niedrig) – `config/ly/etc/ly/config.ini` auf die
      tatsächlich abweichenden Keys reduzieren (oder Vollkopie bewusst
      dokumentieren).
- [ ] **CFG-QT-1 fix** (niedrig) – `[SettingsWindow] geometry` aus
      `config/qt5ct/.config/qt5ct/qt5ct.conf` entfernen (reiner UI-State).
- [ ] **CFG-BASH-1 fix** (niedrig) – doppelte Nix-Einbindung in
      `config/bash/.bash_profile` entfernen (bedingtes Laden in `.bashrc` reicht).
- [ ] **CFG-MIME-1 fix** (niedrig) – redundante `[Added Associations]` in
      `config/mimeapps/.config/mimeapps.list` prüfen und ggf. entfernen.
- [ ] **CFG-PW-1 fix** (niedrig) – `min-quantum` in
      `config/pipewire/.config/pipewire/pipewire-pulse.conf.d/99-custom.conf`
      anheben (z. B. 64/128) oder den niedrigen Wert kommentiert begründen.

### Erfolgskriterien

- Jeder Fix ist ein fokussierter Commit; Verhalten bewusst geändert, dokumentiert.
- Behobene `CFG-*`-Findings sind aus dem Health-Report entfernt, Zähler stimmen.
- Keine Regression bei Stow-Verlinkung/Login/Rendering.
