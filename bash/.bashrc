[[ $- != *i* ]] && return

export HISTFILE=~/.config/bash/.bash_history
shopt -u histappend

battery_status() {
  echo "$(acpi -b | grep -P -o '[0-9]+(?=%)')%"
}

PS1='$(battery_status) \w \$ '

export PATH="$HOME/.config/scripts:$PATH"

export ELECTRON_OZONE_PLATFORM_HINT=wayland
export QT_QPA_PLATFORM=wayland
export QT_SCALE_FACTOR=0.8
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export GDK_SCALE=2
export GDK_DPI_SCALE=0.5
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export QT_SCALE_FACTOR=2
export XCURSOR_SIZE=32

export VIRSH_DEFAULT_CONNECT_URI="qemu:///system"
export TYPST_PACKAGE_PATH="$HOME/.config/typst/packages"
export GIT_CONFIG_GLOBAL="$HOME/.config/git/.gitconfig"

alias resolve='distrobox-enter davincibox -- env QT_SCALE_FACTOR=0.9 QT_AUTO_SCREEN_SCALE_FACTOR=0 /opt/resolve/bin/resolve'
alias open='xdg-open'
