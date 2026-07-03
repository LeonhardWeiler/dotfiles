#!/bin/bash
set -e

# Repo-Root liegt eine Ebene über scripts/. Alle Stow-Pakete liegen in config/.
DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_DIR="$DOTFILES_DIR/config"

if ! command -v stow &> /dev/null; then
    echo "Stow wird benötigt. Bitte zuerst installieren."
    exit 1
elif [[ $EUID -ne 0 ]]; then
    echo "Für Root-Pakete sind erhöhte Rechte erforderlich. Falls gewünscht mit 'sudo' ausführen."
fi

ROOT_PKGS=("ly" "systemd-system" "pacman" "mkinitcpio")
USER_PKGS=()

# System-Dienste, die zum Setup gehoeren (frueher nur README-Merkliste).
# enable (ohne --now): wirkt ab dem naechsten Boot; ein sofortiges --now waehrend
# der Installation koennte die laufende Session stoeren (z. B. ly@tty2).
SYSTEM_UNITS=(
    "zram.service"
    "NetworkManager.service"
    "ly@tty2.service"
    "pipewire.service"
    "wireplumber.service"
    "dnsmasq.service"
    "sshd.service"
    "swtpm.service"
    "libvirtd.service"
    "legion-conservation.service"
)

# User-Units, deren Enablement (*.wants-Links) mitgetrackt wird. Nach einem
# Layout-Umzug koennen deren Enablement-Links ins Leere zeigen -> reenable
# baut sie sauber auf die aktuelle Unit-Position neu auf (Selbstheilung).
USER_UNITS=(
    "battery-check.timer"
    "dotfiles-sync.service"
)

chmod +x "$DOTFILES_DIR/scripts/update-package-list.sh"
chmod +x "$DOTFILES_DIR/scripts/install-programs.sh"

for dir in "$CONFIG_DIR"/*/; do
    dir=${dir%/}
    dir=${dir##*/}
    skip=false
    for skip_pkg in "${ROOT_PKGS[@]}"; do
        if [[ "$dir" == "$skip_pkg" ]]; then
            skip=true
            break
        fi
    done
    if ! $skip; then
        USER_PKGS+=("$dir")
    fi
done

# Entfernt in einem Zielbaum verwaiste Symlinks, die in dieses Repo zeigen.
# Nötig nach einem Repo-Umbau (z. B. Verschieben der Pakete nach config/): die
# alten Links zeigen dann ins Leere und stow -R kann sie nicht adoptieren, weil
# sie auf den alten Pfad verweisen. Es werden ausschließlich KAPUTTE Links
# entfernt, deren Ziel den Repo-Namen enthält — bestehende, gültige Links und
# fremde Symlinks bleiben unangetastet.
REPO_NAME="$(basename "$DOTFILES_DIR")"
remove_stale_links() {
    local sudo_pfx="$1"; shift
    local link tgt
    while IFS= read -r link; do
        tgt="$($sudo_pfx readlink "$link")"
        case "$tgt" in
            *"$REPO_NAME"/*)
                echo "  entferne verwaisten Link: $link"
                $sudo_pfx rm -f "$link"
                ;;
        esac
    # systemd-Enablement-Links (*.wants/, *.requires/) werden von systemctl
    # verwaltet, nicht von stow -> ausklammern, sonst würde ein Dienst hier
    # ungewollt deaktiviert.
    done < <($sudo_pfx find "$@" -maxdepth 5 \
        \( -path '*.wants/*' -o -path '*.requires/*' \) -prune \
        -o -xtype l -print 2>/dev/null)
}

read -p "Möchtest du die Änderungen wirklich anwenden? [y/N]: " confirm
confirm=${confirm,,}

if [[ "$confirm" == "y" || "$confirm" == "yes" ]]; then
    echo "Apply changes..."

    echo "Räume verwaiste Symlinks aus einem früheren Layout auf..."
    remove_stale_links "" "$HOME/.config" "$HOME/.local"
    # Direkte Home-Dotfiles (z. B. ~/.bashrc) nur oberste Ebene prüfen.
    while IFS= read -r link; do
        tgt="$(readlink "$link")"
        case "$tgt" in *"$REPO_NAME"/*) echo "  entferne verwaisten Link: $link"; rm -f "$link" ;; esac
    done < <(find "$HOME" -maxdepth 1 -xtype l 2>/dev/null)

    for pkg in "${USER_PKGS[@]}"; do
        stow --dir="$CONFIG_DIR" --target="$HOME" -R -v "$pkg"
    done

    remove_stale_links "sudo" /etc
    for pkg in "${ROOT_PKGS[@]}"; do
        sudo stow --dir="$CONFIG_DIR" --target=/ -R -v "$pkg"
    done

    # Dienste (re)aktivieren. 'reenable' statt 'enable' macht den Schritt
    # selbstheilend: nach einem Layout-Umzug werden verwaiste Enablement-Links
    # (*.wants) sauber auf die aktuelle Unit-Position neu aufgebaut, statt dass
    # ein Dienst "enabled, aber Unit not-found" haengen bleibt. Ohne --now, damit
    # die laufende Session (ly@tty2, libvirtd, ...) nicht gestoert wird.
    read -p "System- und User-Dienste (re)aktivieren (systemctl reenable)? [y/N]: " confirm
    confirm=${confirm,,}
    if [[ "$confirm" == "y" || "$confirm" == "yes" ]]; then
        for unit in "${SYSTEM_UNITS[@]}"; do
            echo "  reenable $unit"
            sudo systemctl reenable "$unit" || echo "  WARN: $unit nicht (re)aktiviert (Paket installiert?)"
        done
        for unit in "${USER_UNITS[@]}"; do
            echo "  reenable --user $unit"
            systemctl --user reenable "$unit" || echo "  WARN: --user $unit nicht (re)aktiviert"
        done
        echo "Hinweis: 'reenable' wirkt ab dem naechsten Boot/Login. Fuer"
        echo "sofortiges Starten je Dienst 'systemctl start <unit>'."
    fi

    read -p "Möchtest du das programs.txt file aktualisieren [Y/n]: " confirm
    confirm=${confirm,,}
    # Default ist Ja: nur bei ausdruecklichem n/no ueberspringen.
    if [[ "$confirm" != "n" && "$confirm" != "no" ]]; then
        echo "Aktualisiere programs.txt..."
        pacman -Qe | awk 'NR==FNR{skip[$1];next} !($1 in skip)' <(pacman -Qq base) - > "$DOTFILES_DIR/scripts/programs.txt"
    fi

    echo "Fertig!"
else
    echo "Abgebrochen. Keine Änderungen wurden gemacht."
    exit 0
fi

