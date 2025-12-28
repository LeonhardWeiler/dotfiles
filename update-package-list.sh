#!/bin/bash

read -p "Möchtest du das programs.txt file aktualisieren [y/N]: " confirm
confirm=${confirm,,}
if [[ "$confirm" == "y" || "$confirm" == "yes" ]]; then
  echo "Aktualisiere programs.txt..."
  pacman -Qe | grep -v "$(pacman -Qq base)" > programs.txt
fi

