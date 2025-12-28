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

ROOT_PKGS=("ly" "zram" "systemd-system" "mkinitcpio")
USER_PKGS=()

chmod +x update-package-list.sh

for dir in */; do
    dir=${dir%/}
    skip=false
    for root_pkg in "${ROOT_PKGS[@]}"; do
        if [[ "$dir" == "$root_pkg" ]]; then
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

    read -p "Möchtest du das programs.txt file aktualisieren [y/N]: " confirm
    confirm=${confirm,,}
    if [[ "$confirm" == "y" || "$confirm" == "yes" ]]; then
        echo "Aktualisiere programs.txt..."
        pacman -Qe | grep -v "$(pacman -Qq base)" > programs.txt
    fi

    echo "Fertig!"
else
    echo "Abgebrochen. Keine Änderungen wurden gemacht."
    exit 0
fi

