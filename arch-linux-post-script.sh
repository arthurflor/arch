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
## Color Picker
## GSConnect
## Sound Input & Output Device Chooser
## Top Panel Workspace Scroll

# ===========================================================================
# CLEAR PACKAGES
# ===========================================================================

yay -Rcc gnome-{backgrounds,books,boxes,characters,clocks,contacts,dictionary,documents}
yay -Rcc gnome-{font-viewer,logs,maps,menus,music,notes,photos,shell-extensions,software,todo}
yay -Rcc epiphany evolution totem rygel tracker tracker-miners vino xdg-user-dirs-gtk xdg-user-dirs

yay -Rcc xf86-video-intel network-manager-applet wireless_tools vim xterm pavucontrol 
yay -Rcc base luit dialog sushi orca man-{pages,db} mousetweaks dleyna-server

yay -Qttdq | yay -Rns - ; yay -c && yay -Scc

# ===============================================================================
# INSTALL PACKAGES
# ===============================================================================

yay -S pacman-contrib base-devel fakeroot nano intel-ucode
yay -S neofetch openssh zip unrar p7zip ventoy-bin jre-openjdk

yay -S system-config-printer cups-{filters,pdf} hplip-minimal pdfarranger img2pdf
yay -S geary google-chrome chrome-gnome-shell transmission-gtk gimp mpv mpv-mpris

yay -S ttf-ms-fonts adobe-source-han-sans-otc-fonts papirus-icon-theme
yay -S hunspell hunspell-{en_US,pt-br} libreoffice-{fresh,extension-languagetool}

yay -S virtualbox virtualbox-guest-iso virtualbox-ext-oracle
yay -S smartgit visual-studio-code-bin ankama-launcher

# ===========================================================================
# BLUETOOTH
# ===========================================================================

sudo sed -i 's/#FastConnectable = false/FastConnectable = true/g' /etc/bluetooth/main.conf ;
sudo sed -i 's/#ReconnectAttempts/ReconnectAttempts/g' /etc/bluetooth/main.conf ;
sudo sed -i 's/#ReconnectIntervals/ReconnectIntervals/g' /etc/bluetooth/main.conf ;
sudo sed -i 's/#AutoEnable=false/AutoEnable=true/g' /etc/bluetooth/main.conf ;

# ===========================================================================
# SWAP
# ===========================================================================

sudo swapoff /swapfile ;
sudo rm -f /swapfile ;

sudo fallocate -l 15905M /swapfile ;

sudo chmod 600 /swapfile ;
sudo mkswap /swapfile ;
sudo swapon /swapfile ;

echo -e '# swap\n/swapfile none swap defaults 0 0' | sudo tee --append /etc/fstab

# ===========================================================================
# ACPID LID CLOSE/OPEN EVENT
# ===========================================================================

yay -S acpid

echo -e 'HandleLidSwitch=ignore\nHandleLidSwitchDocked=ignore' | sudo tee --append /etc/systemd/logind.conf
echo -e 'event=button/lid.*\naction=/etc/acpi/lid.sh' | sudo tee --append /etc/acpi/events/lm_lid

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

# ===========================================================================
# BOOT AND PLYMOUTH
# ===========================================================================

yay -S plymouth-git

sudo sed -i 's/MODULES=()/MODULES=(intel_agp i915)/g' /etc/mkinitcpio.conf
sudo sed -i 's/base udev/base udev plymouth/g' /etc/mkinitcpio.conf

sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sudo sed -i 's/loglevel=3/quiet splash loglevel=3 vga=current pci=noaer vt.global_cursor_default=0 rd.systemd.show_status=false rd.udev.log_priority=3 fbcon=nodefer i915.enable_guc=2 i915.enable_fbc=1/g' /etc/default/grub

sudo cp -R ./plymouth/** /usr/share/plymouth/themes/
sudo plymouth-set-default-theme minimal

sudo mkinitcpio -p linux ;
sudo grub-mkconfig -o /boot/grub/grub.cfg ;
sudo sed -i 's/echo/#echo/g' /boot/grub/grub.cfg ;

# ===============================================================================
# SYSTEM
# ===============================================================================

# Language
echo -e 'FONT=lat2-16' | sudo tee --append /etc/vconsole.conf ;
echo -e 'en_US.UTF-8 UTF-8' | sudo tee --append /etc/locale.gen ;
sudo locale-gen ;

# Logs
echo -e 'SystemMaxUse=50M' | sudo tee --append /etc/systemd/journald.conf ;

# Sysctl
echo -e 'kernel.printk = 3 3 3 3' | sudo tee /etc/sysctl.d/20-quiet-printk.conf ;
echo -e 'kernel.core_pattern=|/bin/false' | sudo tee /etc/sysctl.d/50-coredump.conf ;
echo -e 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-swappiness.conf ;

# Services
sudo systemctl enable cups acpid

# ===========================================================================
# GNOME - ENVIRONMENT
# ===========================================================================

# Autostart packages
mkdir -p ~/.config/autostart/
echo -e "[Desktop Entry]\nType=Application\nName=transmission-gtk\nExec=transmission-gtk -m" > ~/.config/autostart/transmission-gtk.desktop

# Custom folders
mkdir ~/Code ; gio set ~/Code metadata::custom-icon-name 'folder-script'
mkdir ~/VirtualBox\ VMs ; gio set ~/VirtualBox\ VMs metadata::custom-icon-name 'folder-linux'

# Background images
sudo rm -R /usr/share/backgrounds/anarchy

sudo cp -R ./dynamic-wallpaper/** /usr/share/backgrounds/gnome/
sudo mv /usr/share/backgrounds/gnome/ghib/ghib-dynamic.xml /usr/share/gnome-background-properties/

# ===========================================================================
# GNOME - GSETTINGS
# ===========================================================================

# Theme
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'

# Mouse & Touchpad
gsettings set org.gnome.desktop.peripherals.touchpad disable-while-typing false
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false
gsettings set org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled true

gsettings set org.gnome.desktop.peripherals.mouse speed .4
sudo -u gdm dbus-launch gsettings set org.gnome.desktop.peripherals.mouse speed .4

gsettings set org.gnome.desktop.peripherals.touchpad speed .4
sudo -u gdm dbus-launch gsettings set org.gnome.desktop.peripherals.touchpad speed .4

gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
sudo -u gdm dbus-launch gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true

# Keyboard
gsettings set org.gnome.desktop.peripherals.keyboard numlock-state true
sudo -u gdm dbus-launch gsettings set org.gnome.desktop.peripherals.keyboard numlock-state true

# Enable Night Light mode
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
sudo -u gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true

gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4000
sudo -u gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4000

# GEdit without extra blank line
gsettings set org.gnome.gedit.preferences.editor ensure-trailing-newline false

# Screencast unlimited
gsettings set org.gnome.settings-daemon.plugins.media-keys max-screencast-length 0

# ===========================================================================
# USER ENVIRONMENT
# ===========================================================================
sudo gpasswd -a $(whoami) games
sudo gpasswd -a $(whoami) vboxusers

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
