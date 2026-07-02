#!/bin/bash

read -p "Möchtest du das programs.txt file aktualisieren [y/N]: " confirm
confirm=${confirm,,}
if [[ "$confirm" == "y" || "$confirm" == "yes" ]]; then
  echo "Aktualisiere programs.txt..."
  pacman -Qe | awk 'NR==FNR{skip[$1];next} !($1 in skip)' <(pacman -Qq base) - > programs.txt
fi

