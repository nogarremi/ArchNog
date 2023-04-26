#!/bin/bash
pacman -Syu --noconfirm

# Set Locale info
ln -sf /usr/share/zoneinfo/US/Pacific /etc/localtime
hwclock -w

systemctl enable ntpd.service

read -rep 'Hostname: ' sys_hostname

echo "$sys_hostname" > /etc/hostname
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=colemak" > /etc/vconsole.conf

locale-gen

# Create user
read -rep 'Username: ' username
read -srep 'Password: ' password
groupadd sudoers
useradd --btrfs-subvolume-home -U -p $password -G sudoers  $username

echo "%sudoers ALL=(ALL:ALL) ALL" >> /etc/sudoers

# Disable root
passwd -l root
usermod -s /usr/sbin/nologin root

read -n1 -srp "Press enter to coninue"

## Su section
su - $username

git clone https://aur.archlinux.org/yay-git.git
cd yay-git
makepkg -si --noconfirm
cd ..

yay -S --noconfirm waybar-hyprland wlogout swaylock-effects sddm-git \
	nordic-theme otf-sora ttf-icomoon-feather
