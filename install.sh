#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

if ! command -v stow &> /dev/null; then
    echo "Stow wird benötigt. Bitte zuerst installieren."
    exit 1
fi

cd "$DOTFILES_DIR"

read -p "Möchtest du die Änderungen wirklich anwenden? [y/N]: " confirm
confirm=${confirm,,}

if [[ "$confirm" == "y" || "$confirm" == "yes" ]]; then
    echo "Apply changes..."
    for pkg in */; do
        pkg=${pkg%/}
        if [ "$pkg" != "ly" ]; then
            stow -R -v "$pkg"
        fi
    done
    sudo stow -R -v --target=/ ly
    echo "Fertig!"
else
    echo "Abgebrochen. Keine Änderungen wurden gemacht."
    exit 0
fi

