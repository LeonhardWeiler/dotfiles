#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

if ! command -v stow &> /dev/null; then
    echo "Stow wird benötigt. Bitte zuerst installieren."
    exit 1
elif [[ $EUID -ne 0 ]]; then
    echo "Für Root-Pakete sind erhöhte Rechte erforderlich. Falls gewünscht mit 'sudo' ausführen."
fi

cd "$DOTFILES_DIR"

ROOT_PKGS=("ly" "systemd-system")
# Verzeichnisse, die keine Stow-Pakete sind und weder als User- noch als
# Root-Paket verlinkt werden sollen.
IGNORE_PKGS=("prompts")
USER_PKGS=()

chmod +x update-package-list.sh
chmod +x install-programs.sh

for dir in */; do
    dir=${dir%/}
    skip=false
    for skip_pkg in "${ROOT_PKGS[@]}" "${IGNORE_PKGS[@]}"; do
        if [[ "$dir" == "$skip_pkg" ]]; then
            skip=true
            break
        fi
    done
    if ! $skip; then
        USER_PKGS+=("$dir")
    fi
done

read -p "Möchtest du die Änderungen wirklich anwenden? [y/N]: " confirm
confirm=${confirm,,}

if [[ "$confirm" == "y" || "$confirm" == "yes" ]]; then
    echo "Apply changes..."

    for pkg in "${USER_PKGS[@]}"; do
        stow -R -v "$pkg"
    done

    for pkg in "${ROOT_PKGS[@]}"; do
        sudo stow -R -v --target=/ "$pkg"
    done

    read -p "Möchtest du das programs.txt file aktualisieren [Y/n]: " confirm
    confirm=${confirm,,}
    # Default ist Ja: nur bei ausdruecklichem n/no ueberspringen.
    if [[ "$confirm" != "n" && "$confirm" != "no" ]]; then
        echo "Aktualisiere programs.txt..."
        pacman -Qe | awk 'NR==FNR{skip[$1];next} !($1 in skip)' <(pacman -Qq base) - > programs.txt
    fi

    echo "Fertig!"
else
    echo "Abgebrochen. Keine Änderungen wurden gemacht."
    exit 0
fi

