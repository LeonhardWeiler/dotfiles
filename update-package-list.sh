#!/bin/bash

read -p "Möchtest du das programs.txt file aktualisieren [Y/n]: " confirm
confirm=${confirm,,}
# Default ist Ja: nur bei ausdruecklichem n/no ueberspringen.
if [[ "$confirm" != "n" && "$confirm" != "no" ]]; then
  echo "Aktualisiere programs.txt..."
  pacman -Qe | awk 'NR==FNR{skip[$1];next} !($1 in skip)' <(pacman -Qq base) - > programs.txt
fi

