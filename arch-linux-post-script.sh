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

yay -Qttdq | yay -Rns - ; yay -c && yay -Scc

# ===============================================================================
# INSTALL PACKAGES
# ===============================================================================

yay -S pacman-contrib base-devel fakeroot nano ;
yay -S intel-ucode intel-media-driver intel-media-sdk ;
yay -S neofetch openssh zip unrar p7zip ventoy-bin jre-openjdk ;

yay -S system-config-printer cups-{filters,pdf} hplip-minimal pdfarranger img2pdf ;
yay -S geary google-chrome chrome-gnome-shell transmission-gtk gimp mpv mpv-mpris ;

yay -S ttf-ms-fonts adobe-source-han-sans-otc-fonts papirus-icon-theme ;
yay -S hunspell hunspell-{en_US,pt-br} libreoffice-{fresh,extension-languagetool} ;

yay -S virtualbox virtualbox-guest-iso virtualbox-ext-oracle ;
yay -S smartgit visual-studio-code-bin ankama-launcher ;

# ===========================================================================
# SWAP
# ===========================================================================

sudo swapoff /swapfile ;
sudo rm -f /swapfile ;

memory_size=$(sudo free -m | awk '{ if($1=="Mem:") print substr($2, 0) + 1 }') ;
sudo fallocate -l $memory_size\M /swapfile ;

sudo chmod 600 /swapfile ;
sudo mkswap /swapfile ;
sudo swapon /swapfile ;

echo -e '# swap\n/swapfile none swap defaults 0 0' | sudo tee --append /etc/fstab;

swap_device=$(sudo findmnt -no UUID -T /swapfile) && 
swap_offset=$(sudo filefrag -v /swapfile | awk '{ if($1=="0:"){print substr($4, 1, length($4)-2)} }') && 

sudo sed -i 's/loglevel=3/loglevel=3 resume=UUID='$swap_device' resume_offset='$swap_offset'/g' /etc/default/grub ;
sudo sed -i 's/filesystems fsck/filesystems resume fsck/g' /etc/mkinitcpio.conf ;

sudo mkinitcpio -p linux-zen ;
sudo grub-mkconfig -o /boot/grub/grub.cfg ;
sudo sed -i 's/echo/#echo/g' /boot/grub/grub.cfg ;

# ===============================================================================
# SYSTEM
# ===============================================================================

# Language
echo -e 'FONT=lat2-16\nFONT_MAP=8859-2' | sudo tee --append /etc/vconsole.conf ;
echo -e 'en_US.UTF-8 UTF-8' | sudo tee --append /etc/locale.gen ;
sudo locale-gen ;

# Logs
echo -e 'Storage=none' | sudo tee --append /etc/systemd/journald.conf ;
sudo rm -R /var/log/journal ;

# Sysctl
echo -e 'kernel.printk = 3 3 3 3' | sudo tee /etc/sysctl.d/20-quiet-printk.conf ;
echo -e 'kernel.core_pattern=|/bin/false' | sudo tee /etc/sysctl.d/50-coredump.conf ;
echo -e 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-swappiness.conf ;

# Services
sudo systemctl mask lvm2-monitor;
sudo systemctl mask systemd-random-seed;
echo -e '[main]\nsystemd-resolved=false' | sudo tee --append /etc/NetworkManager/NetworkManager.conf;

# Bluetooth
sudo sed -i 's/#FastConnectable = false/FastConnectable = true/g' /etc/bluetooth/main.conf ;
sudo sed -i 's/#ReconnectAttempts/ReconnectAttempts/g' /etc/bluetooth/main.conf ;
sudo sed -i 's/#ReconnectIntervals/ReconnectIntervals/g' /etc/bluetooth/main.conf ;
sudo sed -i 's/#AutoEnable=false/AutoEnable=true/g' /etc/bluetooth/main.conf ;

# Make package (makepkg)
sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$(nproc)"/g' /etc/makepkg.conf ;
sudo sed -i 's/-march=x86-64 -mtune=generic -O2/-march=native -mtune=native -O3/g' /etc/makepkg.conf ;

# IO Scheduler
## SSD
echo -e 'ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"' | sudo tee /etc/udev/rules.d/60-ssd.rules ;

## NVME
echo -e 'ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"' | sudo tee /etc/udev/rules.d/60-nvme.rules ;

# ===========================================================================
# ACPID LID CLOSE/OPEN EVENT
# ===========================================================================

yay -S acpid

echo -e 'HandleLidSwitch=ignore\nHandleLidSwitchDocked=ignore' | sudo tee --append /etc/systemd/logind.conf ;
echo -e 'event=button/lid.*\naction=/etc/acpi/lid.sh' | sudo tee --append /etc/acpi/events/lm_lid ;

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
# BOOT
# ===========================================================================

sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub ;

sudo sed -i 's/loglevel=3/quiet nowatchdog loglevel=3 vga=current pci=noaer vt.global_cursor_default=0 rd.systemd.show_status=false rd.udev.log_priority=3 fbcon=nodefer intel_pstate=disable cpufreq.default_governor=conservative fsck.mode=skip/g' /etc/default/grub ;

cd /boot/EFI/boot && cp grubx64.efi grubx64.efi.bak && 

echo -n -e \\x00 | sudo tee patch && cat grubx64.efi | strings -t d | grep "Welcome to GRUB!" | awk '{print $1;}' | sudo xargs -I{} dd if=patch of=grubx64.efi obs=1 conv=notrunc seek={} && cd -

sudo mkinitcpio -p linux-zen ;
sudo grub-mkconfig -o /boot/grub/grub.cfg ;
sudo sed -i 's/echo/#echo/g' /boot/grub/grub.cfg ;

# ===========================================================================
# PLYMOUTH
# ===========================================================================

yay -S plymouth-git

sudo sed -i 's/MODULES=()/MODULES=(i915 intel_agp)/g' /etc/mkinitcpio.conf ;
sudo sed -i 's/base udev/base systemd sd-plymouth/g' /etc/mkinitcpio.conf ;
sudo sed -i 's/loglevel=3/splash loglevel=3/g' /etc/default/grub ;

sudo cp -R ./plymouth/** /usr/share/plymouth/themes;
sudo plymouth-set-default-theme mono-glow;

sudo mkinitcpio -p linux-zen ;
sudo grub-mkconfig -o /boot/grub/grub.cfg ;
sudo sed -i 's/echo/#echo/g' /boot/grub/grub.cfg ;

# ===========================================================================
# GNOME - GSETTINGS
# ===========================================================================

# Theme
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' ;
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' ;

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

# Show day of week in top panel
gsettings set org.gnome.desktop.interface clock-show-weekday true ;

# ===========================================================================
# ENVIRONMENT
# ===========================================================================

# Services
sudo systemctl enable cups acpid

# Groups
sudo gpasswd -a $(whoami) games ;
sudo gpasswd -a $(whoami) vboxusers ;

# Disable vertical synchronization
echoh -e '
<device screen="0" driver="dri2">
	<application name="Default">
		<option name="vblank_mode" value="0"/>
	</application>
</device>
' > ~/.drirc

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
  if [ "$1" == "--init" ]; then
    pip install -U pip wheel setuptools autopep8 flake8
  fi
}

PATH="$HOME/.node_modules/bin:$PATH"
export npm_config_prefix=~/.node_modules

export PYTHONDONTWRITEBYTECODE=1
' >> ~/.bashrc
