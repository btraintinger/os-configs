#!/usr/bin/env bash

username=bernhard

base_pkgs=(
	'base'
	'base-devel'
	'linux'
	'linux-headers'
	'linux-firmware'
	'efibootmgr'
	'grub'
	'ufw'
	'os-prober'
	'networkmanager'
)

coding_pkgs=(
	'gcc'
	'clang'
	'llvm'
	'ninja'
	'cmake'
	'extra-cmake-modules'
	'qt5'
	'qt6'
	'qtcreator'
	'perl'
	'python'
	'python-pip'
	'python-virtualenv'
	'pyenv'
	'go'
	'rustup'
	'jdk-openjdk'
	'groovy'
	'kotlin'
	'scala'
	'maven'
	'gradle'
	'ant'
	'deno'
	'nodejs'
	'npm'
	'dotnet-sdk'
	'mono'
	'ruby'
	'dart'
	'r'
	'julia'
	'emscripten'
	'wasmer'
	'texlive-core'
	'texlive-formatsextra'
	'texlive-latexextra'
	'texlive-bibtexextra'
	'texlive-pictures'
	'texlive-science'
	'arduino'
	'avr-gcc'
	'avr-libc'
	'avr-binutils'
	'avr-gdb'
	'avrdude'
	'simavr'
)

gui_apps_pkgs=(
	'obsidian'
	'alacritty'
	'konsole'
	'kate'
	'dolphin'
	'spectacle'
	'kfind'
	'kgpg'
	'kile'
	'kbibtex'
	'krdc'
	'firefox'
	'chromium'
	'bitwarden'
	'libreoffice-still'
	'mpv'
	'discord'
	'gimp'
	'blender'
	'inkscape'
	'grub-customizer'
	'zathura'
	'skanlite'
	'system-config-printer'
	'partitionmanager'
	'filelight'
	'ksysguard'
	'ark'
)

hacking_pkgs=(
	'nmap'
	'hydra'
	'aircrack-ng'
	'wireshark-qt'
	'tcpdump'
	'metasploit'
)

util_pkgs=(
	'openbsd-netcat'
	'traceroute'
	'net-tools'
	'dnsmasq'
	'git'
	'github-cli'
	'pacman-contrib'
	'neovim'
	'nano'
	'htop'
	'curl'
	'wget'
	'lynx'
	'openssh'
	'rsync'
	'speedtest-cli'
	'trash-cli'
	'usbutils'
	'unrar'
	'p7zip'
	'unzip'
	'zip'
	'posix'
	'tmux'
	'vifm'
	'dash'
	'bash'
	'zsh'
	'neofetch'
	'cmatrix'
	'lolcat'
	'cowsay'
	'youtube-dl'
	'bitwarden-cli'
	'chezmoi'
	'xclip'
	'exa'
	'dos2unix'
)

wm_de_pkgs=(
	'xorg'
	'wayland'
	'sddm'
	'plasma'
	'plasma-wayland-session'
	'alsa-utils'
	'alsa-plugins'
	'alsa-firmware'
	'sof-firmware'
	'alsa-ucm-conf'
	'pulseaudio'
	'pipewire'
	'pulseaudio-alsa'
	'sane'
	'scanlite'
	'cups'
	'cups-pdf'
	'ghostscript'
	'gsfonts'
	'hplip'
	'openvpn'
	'networkmanager-openvpn'
	'dhclient'
	'bluez'
	'bluez-utils'
	'blueberry'
	'pulseaudio-bluetooth'
)

virt_pkgs=(
	'qemu-full'
	'virt-manager'
	'virt-viewer'
	'dnsmasq'
	'bridge-utils'
	'iptables-nft'
	'libvirt'
	'libguestfs'
	'docker'
	'docker-compose'
	'docker-machine'
	'kubectl'
	'minikube'
	'helm'
	'wine-gecko'
	'wine-mono'
	'winetricks'
)

setup_arch_config() {
	# Add sudo rights
	sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

	# use all cores for compilation.
	sed -i "s/-j2/-j$(nproc)/;s/^#MAKEFLAGS/MAKEFLAGS/" /etc/makepkg.conf

	# locales
	sed -i 's/^#de_AT.UTF-8 UTF-8/de_AT.UTF-8 UTF-8/' /etc/locale.gen
	sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
	locale-gen

	timedatectl --no-ask-password set-timezone Europe/Vienna
	timedatectl --no-ask-password set-ntp 1
	localectl --no-ask-password set-locale LANG="en_US.UTF-8" LC_TIME="de_AT.UTF-8" LC_NUMERIC="de_AT.UTF-8" LC_MONETARY="de_AT.UTF-8" LC_PAPER="de_AT.UTF-8" LC_MEASUREMENT="de_AT.UTF-8"
	localectl --no-ask-password set-keymap de

	hwclock --systohc
}

setup_pacman() {
	# Add parallel downloading
	sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

	# Enable multilib
	sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

	# Pacman theme
	grep -q "ILoveCandy" /etc/pacman.conf || sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf

	pacman -Syu --noconfirm
	# refresh keyring
	pacman -S archlinux-keyring --noconfirm

	pacman -S --noconfirm reflector
	cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
	echo -e \
		"--save /etc/pacman.d/mirrorlist\n" \
		"--country Austria,Germany\n" \
		"--protocol https" \
		>/etc/xdg/reflector/reflector.conf
	systemctl enable --now reflector.service
}

setup_base_system() {
	pacman -S --needed --noconfirm $base_pkgs
	pacman -S --needed --noconfirm $util_pkgs
}

setup_cpu_gpu() {
	# install processor microcode
	if grep "GenuineIntel" /proc/cpuinfo; then
		pacman -S --noconfirm intel-ucode
	elif grep "AuthenticAMD" /proc/cpuinfo; then
		pacman -S --noconfirm amd-ucode
	fi

	# Graphics Drivers find and install
	if lspci | grep -E "NVIDIA|GeForce"; then
		pacman -S nvidia --noconfirm --needed
		nvidia-xconfig
	elif lspci | grep -E "Radeon"; then
		pacman -S xf86-video-amdgpu --noconfirm --needed
	elif lspci | grep -E "Integrated Graphics Controller"; then
		pacman -S libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils --needed --noconfirm
	fi
	pacman -S mesa --needed --noconfirm
}

setup_user() {
	useradd -m -G wheel,uucp -s /bin/zsh $username
}

setup_hacking() {
	pacman -S --needed --noconfirm $hacking_pkgs

	usermod -aG wireshark $username
}

setup_virt() {
	pacman -S --needed --noconfirm $virt_pkgs

	sed -i "s/#unix_sock_group =  \"libvirt\"/unix_sock_group = \"libvirt\"/g" /etc/libvirt/libvirtd.conf
	sed -i "s/#unix_sock_rw_perms = \"0770\"/unix_sock_rw_perms = \"0770\"/g" /etc/libvirt/libvirtd.conf
	echo "options kvm-intel nested=1" >> /etc/modprobe.d/kvm-intel.conf

	usermod -aG docker,libvirt $username
	minikube config set driver kvm2

	systemctl enable containerd.service
	systemctl enable libvirtd.service
	systemctl enable docker.service
}

setup_wm() {
	pacman -S --needed --noconfirm $wm_de_pkgs
	pacman -S --needed --noconfirm $gui_apps_pkgs

	sed -i 's/AutoEnable=false/AutoEnable=true/' /etc/bluetooth/main.conf

	systemctl enable cups.service
	systemctl enable NetworkManager.service
	systemctl enable bluetooth.service
}

setup_arch_config
setup_pacman
setup_base_system
setup_cpu_gpu
#setup_user
setup_hacking
setup_virt
setup_wm
