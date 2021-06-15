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

yay -Rcc gnome-{backgrounds,books,boxes,characters,clocks,contacts,dictionary,documents} ;
yay -Rcc gnome-{font-viewer,logs,maps,menus,music,notes,photos,shell-extensions,software,todo} ;
yay -Rcc epiphany evolution totem rygel tracker tracker-miners vino xdg-user-dirs-gtk xdg-user-dirs ;

yay -Rcc xf86-video-intel network-manager-applet wireless_tools vim xterm pavucontrol ;
yay -Rcc base luit dialog sushi orca man-{pages,db} mousetweaks dleyna-server ;

yay -Qttdq | yay -Rns - ; yay -c && yay -Scc ;

# ===============================================================================
# INSTALL PACKAGES
# ===============================================================================

yay -S pacman-contrib base-devel fakeroot nano ;
yay -S intel-ucode intel-media-driver intel-media-sdk ;
yay -S neofetch openssh zip unrar p7zip ventoy-bin jre-openjdk ;

yay -S system-config-printer cups-{filters,pdf} hplip-minimal pdfarranger img2pdf ;
yay -S geary google-chrome chrome-gnome-shell transmission-gtk gimp vlc ;

yay -S ttf-ms-fonts adobe-source-han-sans-otc-fonts papirus-icon-theme ;
yay -S hunspell hunspell-{en_US,pt-br} libreoffice-{fresh,extension-languagetool} ;

yay -S virtualbox virtualbox-guest-iso virtualbox-ext-oracle ;
yay -S smartgit visual-studio-code-bin ankama-launcher ;

# ===============================================================================
# SYSTEM
# ===============================================================================

# Logs
echo -e 'Storage=none' | sudo tee --append /etc/systemd/coredump.conf ;
echo -e 'Storage=none' | sudo tee --append /etc/systemd/journald.conf ;
sudo rm -R /var/log/journal ;

# Make package (makepkg)
sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$(nproc)"/g' /etc/makepkg.conf ;
sudo sed -i 's/-march=x86-64 -mtune=generic -O2/-march=native -mtune=native -O3/g' /etc/makepkg.conf ;

# Services
sudo systemctl mask lvm2-monitor;
sudo systemctl mask systemd-random-seed;
echo -e '[main]\nsystemd-resolved=false' | sudo tee --append /etc/NetworkManager/NetworkManager.conf;

# Modprobe
echo -e 'options i915 fastboot=1\noptions i915 enable_guc=2\noptions i915 enable_fbc=1' | sudo tee /etc/modprobe.d/i915.conf ;

echo -e '
blacklist nouveau
blacklist iTCO_wdt
blacklist input_polldev
install input_polldev /bin/false' | sed '1{/^$/d}' | sudo tee /etc/modprobe.d/blacklist.conf ;

# Bluetooth
sudo sed -i 's/#FastConnectable = false/FastConnectable = true/g' /etc/bluetooth/main.conf ;
sudo sed -i 's/#ReconnectAttempts/ReconnectAttempts/g' /etc/bluetooth/main.conf ;
sudo sed -i 's/#ReconnectIntervals/ReconnectIntervals/g' /etc/bluetooth/main.conf ;
sudo sed -i 's/#AutoEnable=false/AutoEnable=true/g' /etc/bluetooth/main.conf ;

# Language
echo -e 'FONT=lat2-16\nFONT_MAP=8859-2' | sudo tee --append /etc/vconsole.conf ;
echo -e 'en_US.UTF-8 UTF-8' | sudo tee --append /etc/locale.gen ;
sudo locale-gen ;

# ===========================================================================
# SWAP
# ===========================================================================

sudo swapoff /swapfile ;
sudo rm -f /swapfile ;

memory_size=$(sudo free -m | awk '{ if($1=="Mem:") print substr($2, 0) + 1 }') ;

sudo fallocate -l $memory_size\M /swapfile ;
sudo chmod 600 /swapfile ; sudo mkswap /swapfile ; sudo swapon /swapfile ;

echo -e '# swap\n/swapfile none swap defaults 0 0' | sudo tee --append /etc/fstab;
echo -e 'vm.swappiness=1' | sudo tee /etc/sysctl.d/99-swappiness.conf ;

# ===========================================================================
# BOOT AND PLYMOUTH
# ===========================================================================

yay -S plymouth-git

sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub ;
sudo sed -i '/GRUB_DISTRIBUTOR="Arch"/a GRUB_DISABLE_OS_PROBER=false' /etc/default/grub ;
sudo sed -i 's/loglevel=3 quiet/loglevel=3 quiet splash vga=current pci=noaer fbcon=nodefer rd.udev.log_level=3 vt.global_cursor_default=0/g' /etc/default/grub ;

sudo sed -i 's/MODULES=()/MODULES=(i915 intel_agp)/g' /etc/mkinitcpio.conf ;
sudo sed -i 's/base udev/base udev plymouth/g' /etc/mkinitcpio.conf ;

sudo cp -R ./plymouth/** /usr/share/plymouth/themes ;
sudo plymouth-set-default-theme mono-glow ;

sudo mkinitcpio -p linux ;
sudo grub-mkconfig -o /boot/grub/grub.cfg ;
sudo sed -i 's/echo/#echo/g' /boot/grub/grub.cfg ;

cd /boot/EFI/boot && cp grubx64.efi grubx64.efi.bak && echo -n -e \\x00 | sudo tee patch && 
cat grubx64.efi | strings -t d | grep "Welcome to GRUB!" | awk '{print $1;}' | sudo xargs -I{} dd if=patch of=grubx64.efi obs=1 conv=notrunc seek={} && cd - ;

# ===========================================================================
# ACPID LID CLOSE/OPEN EVENT
# ===========================================================================

yay -S acpid

echo -e '
#!/bin/bash

case "$1" in
    button/lid)
        user=$(getent passwd $(awk "/^Uid:/{print \$2}" /proc/$(pgrep "^gnome-shell$")/status) | awk -F: "{print \$1}")

        case "$3" in
            close)
                if [ $(cat /sys/class/drm/card0/*HDMI*/status | grep "^connected" | wc -l) -eq 0 ]; then
                    runuser -l $user -c "busctl --user set-property org.gnome.Mutter.DisplayConfig /org/gnome/Mutter/DisplayConfig org.gnome.Mutter.DisplayConfig PowerSaveMode i 1"
                fi
                ;;
            open)
                runuser -l $user -c "busctl --user set-property org.gnome.Mutter.DisplayConfig /org/gnome/Mutter/DisplayConfig org.gnome.Mutter.DisplayConfig PowerSaveMode i 0"
                ;;
        esac
        ;;
esac
;;' | sed '1{/^$/d}' | sudo tee /etc/acpi/handler.sh ;

echo -e 'HandleLidSwitch=ignore\nHandleLidSwitchDocked=ignore' | sudo tee --append /etc/systemd/logind.conf ;

sudo systemctl enable acpid ;

# ===========================================================================
# GNOME - GSETTINGS
# ===========================================================================

# Theme
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' ;
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' ;

# Session manager autosave
gsettings set org.gnome.SessionManager auto-save-session true ;
gsettings set org.gnome.SessionManager auto-save-session-one-shot true ;

# Mouse & Touchpad
gsettings set org.gnome.desktop.peripherals.touchpad disable-while-typing false ;
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false ;
gsettings set org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled true ;

gsettings set org.gnome.desktop.peripherals.mouse speed .4 ;
sudo -u gdm dbus-launch gsettings set org.gnome.desktop.peripherals.mouse speed .4 ;

gsettings set org.gnome.desktop.peripherals.touchpad speed .4 ;
sudo -u gdm dbus-launch gsettings set org.gnome.desktop.peripherals.touchpad speed .4 ;

gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true ;
sudo -u gdm dbus-launch gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true ;

# Keyboard
gsettings set org.gnome.desktop.peripherals.keyboard numlock-state true ;
sudo -u gdm dbus-launch gsettings set org.gnome.desktop.peripherals.keyboard numlock-state true ;

# Enable Night Light mode
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true ;
sudo -u gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true ;

gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4000 ;
sudo -u gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4000 ;

# GEdit without extra blank line
gsettings set org.gnome.gedit.preferences.editor ensure-trailing-newline false ;

# Screencast unlimited
gsettings set org.gnome.settings-daemon.plugins.media-keys max-screencast-length 0 ;

# ===========================================================================
# ENVIRONMENT
# ===========================================================================

# Services and Groups
sudo systemctl enable cups ;

sudo gpasswd -a $(whoami) games ;
sudo gpasswd -a $(whoami) vboxusers ;

# Autostart packages
mkdir -p ~/.config/autostart ;
echo -e '[Desktop Entry]\nType=Application\nName=transmission-gtk\nExec=transmission-gtk -m' > ~/.config/autostart/transmission-gtk.desktop ;

# Custom folders
mkdir ~/Code ; gio set ~/Code metadata::custom-icon-name 'folder-script' ;
mkdir ~/VirtualBox\ VMs ; gio set ~/VirtualBox\ VMs metadata::custom-icon-name 'folder-linux' ;

# Background images
sudo rm -R /usr/share/backgrounds/anarchy

sudo cp -R ./dynamic-wallpaper/** /usr/share/backgrounds/gnome/ ;
sudo mv /usr/share/backgrounds/gnome/ghib/ghib-dynamic.xml /usr/share/gnome-background-properties/ ;

# Shell script
echo -e '
activate () {
  python -m venv .venv && source .venv/bin/activate
  if [ "$1" == "-i" ]; then
    pip install -U pip setuptools autopep8 flake8
  fi
}

export PYTHONDONTWRITEBYTECODE=1

PATH="$HOME/.node_modules/bin:$PATH"
export npm_config_prefix=~/.node_modules' >> ~/.bashrc
