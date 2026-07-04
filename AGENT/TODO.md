# Dotfiles – Aufgabenplanung

Sammlung geplanter, noch **nicht umgesetzter** Arbeiten am Dotfiles-Repo.
Ein Commit pro abgearbeitetem Punkt (siehe Skill `implement-todo`).

> **Erledigt:** P11 (Repo-Umbau auf `config/` + `scripts/`) ist umgesetzt und
> end-to-end verifiziert. P12 (kritische Config-Bewertung) abgeschlossen.
> **P13 (alle `CFG-*`-Config-Fixes) ist umgesetzt** – je ein Commit, Findings aus
> dem Health-Report entfernt, Zähler angepasst.

---

## P13 – Config-Fixes aus der P12-Bewertung umsetzen ✅ erledigt

Reaktion auf die Findings in `AGENT/project-health-report.html`. Jeder Punkt =
eigener Commit; behobene Findings aus dem Report entfernt.

- [x] **CFG-QT-2 fix** (mittel) – `QT_QPA_PLATFORMTHEME` konsistent auf `qt5ct`
      (env.lua + .bash_profile). keepassxc ist Qt5, qt6ct war nicht installiert.
- [x] **CFG-BTOP-1 fix** – auf 3 abweichende Keys reduziert + `save_config_on_exit
    = false` (sonst bläht btop die Datei bei Exit wieder auf).
- [x] **CFG-LY-1 fix** – auf 10 abweichende Keys reduziert + dokumentiert
      (verhaltensgleich; ly fällt bei fehlenden Keys auf Defaults zurück).
- [x] **CFG-QT-1 fix** – `[SettingsWindow] geometry` aus `qt5ct.conf` entfernt.
- [x] **CFG-BASH-1 fix** – doppelte (hardcodierte) Nix-Einbindung in
      `.bash_profile` entfernt.
- [x] **CFG-MIME-1 fix** – redundante `[Added Associations]` entfernt.
- [x] **CFG-PW-1 fix** – `min-quantum` 32 → 128, begründet kommentiert.

### Erledigt (nachgezogen)

- [x] **SH-1 fix** – `install.sh` (re)aktiviert Units per `systemctl reenable`
      (System + User) → repariert verwaiste Enablement-Links nach Layout-Umzug.
- [x] **LY-2** – `/etc/ly/config.ini.pacnew` gesichtet (neue Keys sind reine
      Defaults, nichts zu übernehmen) und entfernt.
