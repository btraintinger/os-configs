#!/usr/bin/env bash

aur_gui_pkgs=(
    'visual-studio-code-bin'
    'megasync-bin'
    'eagle'
    'ltspice'
    'postman-bin'
    'brave-bin'
    'github-desktop-bin'
    'ocs-url'
    'jetbrains-toolbox'
    'logisim-evolution-bin'
    'hterm'
    'grub-theme-poly-dark-git'
)

aur_util_pkgs=(
    'platformio'
    'nerd-fonts-jetbrains-mono'
    'ttf-ms-fonts'
    'hollywood'
    'nvm'
    'flutter'
    'miniconda3'
    'android-sdk'
    'android-emulator'
    'android-sdk-platform-tools'
    'android-sdk-cmdline-tools-latest'
)

echo "CLONING: Paru"
cd ~
git clone "https://aur.archlinux.org/paru-bin.git"
cd ~/paru-bin
makepkg -si --noconfirm
cd ~
rm -rf ~/paru-bin

paru -S --noconfirm $aur_util_pkgs
paru -S --noconfirm --needed $aur_gui_pkgs

sudo usermod -aG flutterusers $USER
flutter config --android-sdk /opt/android-sdk

chezmoi init btraintinger --apply
