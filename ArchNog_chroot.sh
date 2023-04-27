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
read -srep 'Password: ' unencrypted

mapfile -t password < <(openssl passwd -6 $unencrypted)

groupadd sudoers
useradd --btrfs-subvolume-home -U -m -p $password -G sudoers  $username

echo "%sudoers ALL=(ALL:ALL) ALL" >> /etc/sudoers

# Disable root
passwd -l root
usermod -s /usr/sbin/nologin root

git clone https://aur.archlinux.org/yay-git.git
chown -R $username:$username yay-git
chown -R $username:$username dotconfigs

## Su section
sudo -i -u $username bash <<EOF
cd /
cp -R ./dotconfig/dunst ~/.config/
cp -R ./dotconfig/hypr ~/.config/
cp -R ./dotconfig/kitty ~/.config/
cp -R ./dotconfig/pipewire ~/.config/
cp -R ./dotconfig/rofi ~/.config/
cp -R ./dotconfig/swaylock ~/.config/
cp -R ./dotconfig/waybar ~/.config/
cp -R ./dotconfig/wlogout ~/.config/
chmod +x ~/.config/hypr/xdg-portal-hyprland
chmod +x ~/.config/waybar/scripts/waybar-wttr.py
cd /yay-git
makepkg -si --noconfirm
yay -R --noconfirm swaylock waybar
yay -S --noconfirm waybar-hyprland wlogout swaylock-effects sddm-git nordic-theme otf-sora ttf-icomoon-feather
EOF
