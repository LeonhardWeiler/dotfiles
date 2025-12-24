#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

if ! command -v stow &> /dev/null; then
    echo "Stow wird benötigt. Bitte zuerst installieren."
    exit 1
fi

cd "$DOTFILES_DIR"

ROOT_PKGS=("ly" "zram" "systemd-system")
USER_PKGS=()

for dir in */; do
    dir=${dir%/}
    skip=false
    for root_pkg in "${ROOT_PKGS[@]}"; do
        if [[ "$dir" == "$root_pkg" ]]; then
            skip=true
            break
        fi
    done
    $skip || USER_PKGS+=("$dir")
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

    echo "Fertig!"
else
    echo "Abgebrochen. Keine Änderungen wurden gemacht."
    exit 0
fi

