#!/bin/bash

desktop=$(echo $DESKTOP_SESSION | grep -Eo "plasma|gnome")

# ===============================================================================
# SYSTEM
# ===============================================================================

sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sudo sed -i 's/loglevel=3/quiet loglevel=0 rd.systemd.show_status=0 rd.udev.log_priority=0 pci=noaer fbcon=nodefer/g' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg && sudo sed -i 's/echo/#echo/g' /boot/grub/grub.cfg

echo -e 'en_US.UTF-8 UTF-8' | sudo tee --append /etc/locale.gen && sudo locale-gen
echo -e 'FONT=lat0-16' | sudo tee --append /etc/vconsole.conf

sudo mkdir -p /etc/systemd/coredump.conf.d/
echo -e '[Coredump]\nStorage=none' | sudo tee --append /etc/systemd/coredump.conf.d/custom.conf
echo 'SystemMaxUse=50M' | sudo tee --append /etc/systemd/journald.conf

sudo sed -i 's/#AutoEnable=false/AutoEnable=true/g' /etc/bluetooth/main.conf
sudo rm -R /usr/share/backgrounds/anarchy


# ===============================================================================
# GNOME
# ===============================================================================

if [ $desktop == 'gnome' ] ; then

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

	# ===========================================================================
	# GNOME - PACKAGES
	# ===========================================================================
	
	yay -Rcc baobab epiphany rygel totem xdg-user-dirs-gtk vino yelp
	yay -Rcc gnome-{books,boxes,calendar,characters,contacts,dictionary,documents,font-viewer}
	yay -Rcc gnome-{logs,maps,music,notes,photos,shell-extensions,software,todo}

    yay -S ffmpegthumbnailer chrome-gnome-shell
    yay -S geary transmission-gtk gnome-multi-writer

	# ===========================================================================
	# GNOME - ENVIRONMENT
	# ===========================================================================

	mkdir -p ~/.config/autostart/
	echo -e "[Desktop Entry]\nType=Application\nName=geary\nExec=geary --gapplication-service" > ~/.config/autostart/geary.desktop
	echo -e "[Desktop Entry]\nType=Application\nName=transmission-gtk\nExec=transmission-gtk -m" > ~/.config/autostart/transmission-gtk.desktop

	sudo cp -R ./dynamic-wallpaper/** /usr/share/backgrounds/gnome/
	sudo mv /usr/share/backgrounds/gnome/ghib/ghib-dynamic.xml /usr/share/gnome-background-properties/

    # Theme
    gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
    # Keyboard & Mouse
    gsettings set org.gnome.desktop.peripherals.touchpad disable-while-typing false
    gsettings set org.gnome.desktop.interface gtk-enable-primary-paste false
	# GEdit without extra blank line
	gsettings set org.gnome.gedit.preferences.editor ensure-trailing-newline false
    # Screencast unlimited
	gsettings set org.gnome.settings-daemon.plugins.media-keys max-screencast-length 0   

	# ===========================================================================
	# GNOME - ACPID LID CLOSE/OPEN EVENT
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

yay -S pacman-contrib base-devel fakeroot --needed
yay -S nano openssh neofetch xmacro zip unrar p7zip

yay -S system-config-printer cups-{filters,pdf} hplip-minimal
yay -S jre-openjdk keepassxc pdfarranger img2pdf

yay -S ttf-ms-fonts adobe-source-han-sans-otc-fonts
yay -S libreoffice-{fresh,extension-languagetool}
yay -S hunspell-{en_US,pt-br} hyphen-{en,pt-br} libmythes mythes-{en,pt-br}

yay -S virtualbox virtualbox-guest-iso virtualbox-ext-oracle
yay -S google-chrome gimp vlc ankama-launcher
yay -S smartgit visual-studio-code-bin


# ===============================================================================
# ENVIRONMENT
# ===============================================================================

sudo gpasswd -a $(whoami) games
sudo gpasswd -a $(whoami) vboxusers
sudo systemctl enable org.cups.cupsd

echo -e '
PATH="$HOME/.node_modules/bin:$PATH"
export npm_config_prefix=~/.node_modules
' >> ~/.bashrc

echo -e '
activate () {
  python -m venv .venv && source .venv/bin/activate

  if [ "$1" == "--initial" ]; then
    pip install pip flake8 autopep8 --upgrade
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
