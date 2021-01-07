#!/bin/bash

# ===========================================================================
# GNOME - SHORTCUTS
# ===========================================================================

## Hide all normal windows  : Super + D
## Monitor                  : Ctrl + Alt + Delete (gnome-system-monitor)
## Nautilus                 : Super + E (nautilus --new-window)
## Print                    : Print (gnome-screenshot -a --interactive)
## Switch to workspace      : Super + [F1, F2, F3, F4]
## Switch windows           : Alt + Tab
## Terminal                 : Ctrl + Alt + T (gnome-terminal)
## Power Off                : Super + Delete (gnome-session-quit --power-off)

# ===========================================================================
# GNOME - EXTENSIONS
# ===========================================================================

## Arch Linux Updates Indicator
## Clipboard Indicator
## Dash to Dock
## GSConnect
## Sound Input & Output Device Chooser
## Top Panel Workspace Scroll

# ===============================================================================
# SYSTEM
# ===============================================================================

echo -e 'en_US.UTF-8 UTF-8' | sudo tee --append /etc/locale.gen
sudo locale-gen

sudo mkdir -p /etc/systemd/coredump.conf.d/
echo -e '[Coredump]\nStorage=none' | sudo tee --append /etc/systemd/coredump.conf.d/custom.conf
echo 'SystemMaxUse=50M' | sudo tee --append /etc/systemd/journald.conf

sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo sed -i 's/echo/#echo/g' /boot/grub/grub.cfg

echo -e 'FONT=lat0-16' | sudo tee --append /etc/vconsole.conf
sudo sed -i 's/MODULES=()/MODULES=(intel_agp i915)/g' /etc/mkinitcpio.conf
sudo mkinitcpio -p linux

# ===========================================================================
# CLEAR PACKAGES
# ===========================================================================

yay -Rcc gnome-{backgrounds,books,boxes,calendar,characters,contacts,dictionary,documents}
yay -Rcc gnome-{font-viewer,logs,maps,menus,music,notes,photos,shell-extensions,software,todo}
yay -Rcc baobab epiphany rygel totem vino yelp xdg-user-dirs-gtk xdg-user-dirs tracker tracker-miners

yay -Rcc xf86-video-intel network-manager-applet wireless_tools
yay -Rcc base luit cpupower dialog sushi orca man-{pages,db}
yay -Rcc vim xterm pavucontrol mousetweaks dleyna-server

yay -Qttdq | yay -Rns -
yay -c && yay -Scc

# ===============================================================================
# INSTALL PACKAGES
# ===============================================================================

yay -S pacman-contrib base-devel fakeroot nano openssh --needed
yay -S zip unrar p7zip neofetch ffmpegthumbnailer

yay -S system-config-printer cups-{filters,pdf} hplip-minimal pdfarranger img2pdf
yay -S jre-openjdk keepassxc ventoy-bin papirus-icon-theme

yay -S ttf-ms-fonts adobe-source-han-sans-otc-fonts
yay -S hunspell hunspell-{en_US,pt-br} libreoffice-{fresh,extension-languagetool}

yay -S transmission-gtk gimp vlc geary google-chrome chrome-gnome-shell
yay -S virtualbox virtualbox-guest-iso virtualbox-ext-oracle
yay -S smartgit visual-studio-code-bin ankama-launcher

# ===========================================================================
# GNOME - ENVIRONMENT
# ===========================================================================

# Autostart packages
mkdir -p ~/.config/autostart/
echo -e "[Desktop Entry]\nType=Application\nName=transmission-gtk\nExec=transmission-gtk -m" > ~/.config/autostart/transmission-gtk.desktop

# Autostart bluetooth
sudo sed -i 's/#AutoEnable=false/AutoEnable=true/g' /etc/bluetooth/main.conf

# Background images
sudo rm -R /usr/share/backgrounds/anarchy

sudo cp -R ./dynamic-wallpaper/** /usr/share/backgrounds/gnome/
sudo mv /usr/share/backgrounds/gnome/ghib/ghib-dynamic.xml /usr/share/gnome-background-properties/

# Custom folders
mkdir ~/Code ; gio set ~/Code metadata::custom-icon-name "folder-script"
mkdir ~/VirtualBox\ VMs ; gio set ~/VirtualBox\ VMs metadata::custom-icon-name "folder-linux"

# ===========================================================================
# GNOME - GSETTINGS
# ===========================================================================

# Theme
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"

# Mouse & Touchpad
gsettings set org.gnome.desktop.interface gtk-enable-primary-paste false
gsettings set org.gnome.desktop.peripherals.touchpad disable-while-typing false
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false
gsettings set org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled true

gsettings set org.gnome.desktop.peripherals.mouse speed .4
gsettings set org.gnome.desktop.peripherals.touchpad speed .4
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true

sudo -u gdm dbus-launch gsettings set org.gnome.desktop.peripherals.mouse speed .4
sudo -u gdm dbus-launch gsettings set org.gnome.desktop.peripherals.touchpad speed .4
sudo -u gdm dbus-launch gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true

# Keyboard
gsettings set org.gnome.desktop.peripherals.keyboard numlock-state true
sudo -u gdm dbus-launch gsettings set org.gnome.desktop.peripherals.keyboard numlock-state true

# Enable Night Light mode
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4000

sudo -u gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
sudo -u gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4000

# GEdit without extra blank line
gsettings set org.gnome.gedit.preferences.editor ensure-trailing-newline false

# Screencast unlimited
gsettings set org.gnome.settings-daemon.plugins.media-keys max-screencast-length 0

# ===========================================================================
# ACPID LID CLOSE/OPEN EVENT
# ===========================================================================

yay -S acpid
sudo systemctl enable acpid

echo 'HandleLidSwitch=ignore' | sudo tee --append /etc/systemd/logind.conf
echo 'HandleLidSwitchDocked=ignore' | sudo tee --append /etc/systemd/logind.conf
echo 'event=button/lid.*' | sudo tee --append /etc/acpi/events/lm_lid
echo 'action=/etc/acpi/lid.sh' | sudo tee --append /etc/acpi/events/lm_lid
echo -e '#!/bin/bash
user=$(ps -o uname= -p $(pgrep "^gnome-shell$"))
screen=$(cat /sys/class/drm/card0/*HDMI*/status | grep "^connected" | wc -l)

grep -q close /proc/acpi/button/lid/*/state

if [ $? = 0 ] && [ $screen -eq 0 ]; then
    runuser -l $user -c "busctl --user set-property org.gnome.Mutter.DisplayConfig /org/gnome/Mutter/DisplayConfig org.gnome.Mutter.DisplayConfig PowerSaveMode i 1"
fi

grep -q open /proc/acpi/button/lid/*/state

if [ $? = 0 ]; then
    runuser -l $user -c "busctl --user set-property org.gnome.Mutter.DisplayConfig /org/gnome/Mutter/DisplayConfig org.gnome.Mutter.DisplayConfig PowerSaveMode i 0"
fi' > /etc/acpi/lid.sh

chmod +x /etc/acpi/lid.sh

# ===============================================================================
# ENVIRONMENT SCRIPTS
# ===============================================================================

sudo gpasswd -a $(whoami) games
sudo gpasswd -a $(whoami) vboxusers
sudo systemctl enable cups

echo -e '
PATH="$HOME/.node_modules/bin:$PATH"
export npm_config_prefix=~/.node_modules

activate () {
  python -m venv .venv && source .venv/bin/activate
  if [ "$1" == "--init" ]; then
    pip install pip flake8 autopep8 --upgrade
  fi
}
' >> ~/.bashrc
