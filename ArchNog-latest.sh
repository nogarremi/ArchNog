#!/bin/bash
mapfile -t current_pwd < <(pwd)
mapfile -t VALID_DRIVES < <(lsblk -do name | awk '$0="/dev/"$0' | grep -v loop | grep -v NAME)

printf "%s\n" "${VALID_DRIVES[@]}"

read -rep 'Which drive should we do this on: ' BTRFS_DRIVE

if ! [[ ${VALID_DRIVES[*]} =~ "$BTRFS_DRIVE" ]]; then
	echo "${BTRFS_DRIVE} is a valid drive!"
	exit 1
fi

# Making parts
fdisk $BTRFS_DRIVE <<EOF
g
n
1

+2G
t
1
n
2

+30G
t
2
19
n
3


t
3
20
w
EOF

mkfs.btrfs -L main -f /dev/sda3
mkswap -L swap /dev/sda2
mkfs.fat -F 32 -n bootloader /dev/sda1

read -n1 -srp "Press enter to coninue"

# Butter Subvols
mount --mkdir /dev/sda3 /mnt/root
btrfs subv create /mnt/root/root
btrfs subv create /mnt/root/root/@
btrfs subv create /mnt/root/root/usr
btrfs subv create /mnt/root/root/opt
btrfs subv create /mnt/root/root/tmp
btrfs subv create /mnt/root/root/var
btrfs subv create /mnt/root/root/var/tmp
btrfs subv create /mnt/root/root/var/log
btrfs subv create /mnt/root/root/var/log/audit
btrfs subv create /mnt/root/root/shm

read -n1 -srp "Press enter to coninue"

# Mounting for chroot
swapon /dev/sda2
mount --mkdir --bind /mnt/root/root/@ /mnt/@
mount --mkdir /dev/sda1 /mnt/@/efi
mount --mkdir --bind /mnt/root/root/usr /mnt/@/usr
mount --mkdir --bind /mnt/root/root/opt /mnt/@/opt
mount --mkdir --bind /mnt/root/root/tmp /mnt/@/tmp
mount --mkdir --bind /mnt/root/root/var /mnt/@/var
mount --mkdir --bind /mnt/root/root/var/tmp /mnt/@/var/tmp
mount --mkdir --bind /mnt/root/root/var/log /mnt/@/var/log
mount --mkdir --bind /mnt/root/root/var/log/audit /mnt/@/var/log/audit
mount --mkdir --bind /mnt/root/root/shm /mnt/@/dev/shm

read -n1 -srp "Press enter to coninue"

reflector --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
cp ${current_pwd}/ArchNog_chroot.sh /mnt/@/ArchNog_chroot.sh

read -n1 -srp "Press enter to coninue"

# Strapping into the installation
pacman -Scc --noconfirm
pacstrap -K /mnt/@ base base-devel util-linux man-db man-pages texinfo ntp \
	btrfs-progs git zsh vis gcc make curl htop neofetch reflector linux-firmware \
	networkmanager bluez blueman obsidian firefox discord python code rofi \
	kitty hyprland polkit swaybg viewnior  pavucontrol starship wl-clipboard \
	ffmpeg ffmpegthumbnailer tumbler playerctl noise-suppression-for-voice \
	thunar thunar-archive-plugin swaylock pamixer nix papirus-icon-theme dunst \
	ttf-nerd-fonts-symbols-common otf-firamono-nerd inter-font ttf-fantasque-nerd \
	ttf-jetbrains-mono-nerd ttf-iosevka-nerd adobe-source-code-pro-fonts swaylock \
	waybar

arch-chroot /mnt/@ ./ArchNog_chroot.sh
