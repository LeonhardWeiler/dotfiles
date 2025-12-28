#!/bin/bash
set -e

# Prüfen, ob yay installiert ist, sonst installieren
if ! command -v yay &> /dev/null
then
    echo "yay could not be found, installing yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay
fi

echo "Installing packages from programs.txt..."

while IFS= read -r line
do
    # Nur den Paketnamen extrahieren (alles vor dem ersten Leerzeichen)
    package=$(echo "$line" | awk '{print $1}')

    # Prüfen, ob Paket bereits installiert ist (yay prüft sowohl Pacman als auch AUR)
    if yay -Qs "^${package}$" &> /dev/null
    then
        echo "$package is already installed."
    else
        echo "$package not installed, installing with yay..."
        yay -S --noconfirm "$package"
    fi
done < programs.txt

echo "All packages from programs.txt have been processed."

