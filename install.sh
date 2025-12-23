#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Prüfen, ob stow installiert ist
if ! command -v stow &> /dev/null; then
    echo "Stow wird benötigt. Bitte zuerst installieren."
    exit 1
fi

cd "$DOTFILES_DIR"

# Pakete definieren
ROOT_PKGS=("ly" "zram")       # Pakete, die root brauchen
USER_PKGS=()                   # Normale Pakete automatisch erkennen

# Alle Ordner als mögliche Pakete sammeln
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

# Bestätigung
read -p "Möchtest du die Änderungen wirklich anwenden? [y/N]: " confirm
confirm=${confirm,,}

if [[ "$confirm" == "y" || "$confirm" == "yes" ]]; then
    echo "Apply changes..."

    # Normale Pakete
    for pkg in "${USER_PKGS[@]}"; do
        stow -R -v "$pkg"
    done

    # Root-Pakete
    for pkg in "${ROOT_PKGS[@]}"; do
        sudo stow -R -v --target=/ "$pkg"
    done

    echo "Fertig!"
else
    echo "Abgebrochen. Keine Änderungen wurden gemacht."
    exit 0
fi

