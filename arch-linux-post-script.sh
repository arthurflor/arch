#!/bin/bash

desktop=$(echo $DESKTOP_SESSION | grep -Eo "plasma|gnome")

# ===============================================================================
# SYSTEM
# ===============================================================================

sudo sed -i 's/loglevel=3/loglevel=3 quiet pci=noaer/g' /etc/default/grub
sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo -e 'en_US.UTF-8 UTF-8' | sudo tee --append /etc/locale.gen && sudo locale-gen
echo -e 'FONT=lat0-16' | sudo tee --append /etc/vconsole.conf

sudo mkdir -p /etc/systemd/coredump.conf.d/
echo -e '[Coredump]\nStorage=none' | sudo tee --append /etc/systemd/coredump.conf.d/custom.conf
echo 'SystemMaxUse=50M' | sudo tee --append /etc/systemd/journald.conf

sudo sed -i 's/#AutoEnable=false/AutoEnable=true/g' /etc/bluetooth/main.conf


# ===============================================================================
# GNOME
# ===============================================================================

if [ $desktop == 'gnome' ] ; then

	# ===========================================================================
	# GNOME - SHORTCUTS
	# ===========================================================================

	## print   : gnome-screenshot --interactive
	## terminal: gnome-terminal
	## monitor : gnome-system-monitor
	## nautilus: nautilus --new-window
	## desktop : hide all windows
	## change workspace

	# ===========================================================================
	# GNOME - EXTENSIONS
	# ===========================================================================

	## AlternateTab
	## Arch Linux Updates Indicator
	## Clipboard Indicator
	## Dash to Dock
	## Dynamic Panel Transparency
	## GSConnect
	## NetSpeed
	## OpenWeather
	## Sound Input & Output Device Chooser
	## Top Panel Workspace Scroll

	# ===========================================================================
	# GNOME - PACKAGES
	# ===========================================================================
	
	yay -Rcc baobab epiphany evolution-data-server rygel totem xdg-user-dirs-gtk vino yelp
	yay -Rcc gnome-{books,boxes,calendar,characters,clocks,contacts,dictionary,disk-utility,documents}
	yay -Rcc gnome-{font-viewer,logs,maps,music,notes,photos,shell-extensions,software,todo,weather}

	yay -S ffmpegthumbnailer chrome-gnome-shell gnome-{multi-writer,tweaks} gparted transmission-gtk
	yay -S --edit-menu tela-icon-theme

	
	# ===========================================================================
	# GNOME - ENVIRONMENT
	# ===========================================================================

	mkdir -p ~/.config/autostart/
	echo -e "
	[Desktop Entry]
	Type=Application
	Name=transmission-gtk
	Exec=transmission-gtk -m" > ~/.config/autostart/transmission-gtk.desktop

	gsettings set org.gnome.settings-daemon.plugins.media-keys max-screencast-length 0

	sudo cp ./gnome-tweak-tool-lid-inhibitor /usr/lib/


# ===============================================================================
# KDE PLASMA
# ===============================================================================

elif [ $desktop == 'plasma' ] ; then
    
	# ===========================================================================
	# KDE PLASMA - PACKAGES
	# ===========================================================================

	yay -S kde-gtk-config kdeplasma-addons kinfocenter sddm-kcm user-manager
	yay -S discover packagekit-qt5 bluedevil ffmpegthumbs kdegraphics-thumbnailers
	yay -S breeze-gtk plasma-browser-integration kdeconnect spectacle print-manager
	yay -S ark okular gwenview skanlite kate kcalc filelight partitionmanager
	yay -S multibootusb qbittorrent

	# ===========================================================================
	# KDE PLASMA - ENVIRONMENT
	# ===========================================================================

	echo -e '[Wallet]\nEnabled=false' | sudo tee --append ~/.config/kwalletrc

fi


# ===============================================================================
# PACKAGES
# ===============================================================================

yay -Rcc vim xterm pavucontrol

yay -S pacman-contrib base-devel --needed
yay -S nano openssh neofetch fakeroot downgrade xmacro zip rar p7zip
yay -S system-config-printer pdfarranger cups-{filters,pdf} hplip

yay -S jre10-openjdk keepassxc ttf-ms-fonts adobe-source-han-sans-otc-fonts
yay -S virtualbox virtualbox-guest-iso virtualbox-ext-oracle

yay -S libreoffice-{fresh,extension-languagetool}
yay -S hunspell-{en_US,pt-br} hyphen-{en,pt-br} libmythes mythes-{en,pt-br}

yay -S google-chrome gimp vlc ankama-launcher
yay -S smartgit visual-studio-code-bin


# ===============================================================================
# ENVIRONMENT
# ===============================================================================

mkdir Code
gio set Code metadata::custom-icon-name "folder-script"

mkdir VirtualBox\ VMs
gio set VirtualBox\ VMs metadata::custom-icon-name "folder-activities"

echo -e "export SAL_USE_VCLPLUGIN=gtk" | sudo tee --append /etc/profile.d/libreoffice-fresh.sh

sudo gpasswd -a $(whoami) games
sudo gpasswd -a $(whoami) vboxusers

sudo systemctl enable org.cups.cupsd

echo -e '
activate () {
  python -m venv .venv && source .venv/bin/activate

  if [ "$1" == "--initial" ]; then
    pip install --upgrade pip flake8 autopep8
  fi
}

macrorec () {
  xmacrorec2 > "$1"
}

macroplay () {
  for ((;;)) do xmacroplay < "$1"; done
}
' >> ~/.bashrc

yay -c && yay -Scc
