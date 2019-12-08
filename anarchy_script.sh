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
echo -e 'vm.swappiness=10' | sudo tee --append /etc/sysctl.d/99-swappiness.conf

# ===============================================================================
# PACKAGES
# ===============================================================================

yay -Rcc vim
yay -S pacman-contrib base-devel fakeroot nano p7zip unrar zip --needed

yay -S wd719x-firmware aic94xx-firmware
yay -S xdotool downgrade neofetch

yay -S pdfarranger system-config-printer cups-{filters,pdf} hplip
yay -S ttf-ms-fonts adobe-source-han-sans-otc-fonts

yay -S jre8-openjdk multibootusb keepassxc
yay -S google-chrome firefox qbittorrent gimp mpv

yay -S libreoffice-{fresh,extension-languagetool}
yay -S hunspell-{en_US,pt-br} hyphen-{en,pt-br} libmythes mythes-{en,pt-br}

yay -S smartgit visual-studio-code-bin
yay -S virtualbox virtualbox-guest-iso virtualbox-ext-oracle

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
	## xkill   : xkill
	## nautilus: nautilus --new-window
	## desktop : hide all windows
	## Change workspace

	# ===========================================================================
	# GNOME - EXTENSIONS
	# ===========================================================================

	## AlternateTab
	## Clipboard Indicator
	## Dash to Dock
	## Dynamic Panel Transparency
	## GSConnect
	## OpenWeather
	## Pamac Updates Indicator
	## Sound Input & Output Device Chooser
	## Status Area Horizontal Spacing
	## Top Panel Workspace Scroll
	## Transparent Top Bar

	# ===========================================================================
	# GNOME - PACKAGES
	# ===========================================================================
	
	yay -Rcc baobab epiphany evolution-data-server rygel totem xdg-user-dirs-gtk vino yelp
	yay -Rcc gnome-{books,boxes,characters,clocks,dictionary,disk-utility,documents,font-viewer}
	yay -Rcc gnome-{getting-started-docs,logs,music,photos,shell-extensions,software,weather}

	yay -S acpid ffmpegthumbnailer gnome-tweaks gedit-plugins chrome-gnome-shell gparted pamac-aur

	# ===========================================================================
	# GNOME - LID CLOSE
	# ===========================================================================

	echo -e 'HandleLidSwitch=ignore' | sudo tee --append /etc/systemd/logind.conf
	echo -e 'HandleLidSwitchDocked=ignore' | sudo tee --append /etc/systemd/logind.conf

	sudo touch /etc/acpi/events/lm_lid /etc/acpi/lid.sh
	sudo chmod +x /etc/acpi/lid.sh

	echo -e 'event=button/lid.*\naction=/etc/acpi/lid.sh' | sudo tee --append /etc/acpi/events/lm_lid
	echo -e '
	#!/bin/bash

	USER='$(whoami)'
	grep -q close /proc/acpi/button/lid/*/state

	if [ $? = 0 ]; then
	  su -c  "sleep 0.5 && xset -display :0.0 dpms force off" - $USER
	fi

	grep -q open /proc/acpi/button/lid/*/state

	if [ $? = 0 ]; then
	  su -c  "xset -display :0 dpms force on &> /tmp/screen.lid" - $USER
	fi' | sudo tee --append /etc/acpi/lid.sh

	sudo systemctl enable acpid

	# ===========================================================================
	# GNOME - ENVIRONMENT
	# ===========================================================================

	gsettings set org.gnome.settings-daemon.plugins.media-keys max-screencast-length 0

# ===============================================================================
# KDE
# ===============================================================================

elif [ $desktop == 'plasma' ] ; then

	# ===========================================================================
	# KDE - ADDONS
	# ===========================================================================

    ## Netspeed
    ## La Capitaine
    
	# ===========================================================================
	# KDE - PACKAGES
	# ===========================================================================

	yay -S kde-gtk-config kdeplasma-addons kinfocenter sddm-kcm user-manager
	yay -S discover packagekit-qt5 bluedevil ffmpegthumbs kdegraphics-thumbnailers
	yay -S breeze-gtk plasma-browser-integration kwalletmanager kdeconnect spectacle
	yay -S print-manager skanlite kate kcalc ark okular gwenview filelight partitionmanager

fi


# ===============================================================================
# WAKFU
# ===============================================================================

cd ~ && wget -c https://download.ankama.com/launcher/full/linux/x64 -O wakfu
chmod +x wakfu

mkdir -p ~/.config/Ankama/
mkdir -p ~/.local/share/applications/

mv ./wakfu ~/.config/Ankama/
sudo ln -s ~/.config/Ankama/wakfu /usr/bin/wakfu

echo -e '
[Desktop Entry]
Type=Application
Name=Wakfu
Icon=/home/'$(whoami)'/.config/Ankama/zaap/wakfu/icon.png
Exec=wakfu\nCategories=Game' > ~/.local/share/applications/wakfu.desktop

# ===============================================================================
# ENVIRONMENT
# ===============================================================================

echo -e "export SAL_USE_VCLPLUGIN=gtk" | sudo tee --append /etc/profile.d/libreoffice-fresh.sh

sudo gpasswd -a $(whoami) vboxusers

sudo systemctl enable org.cups.cupsd
sudo systemctl enable avahi-daemon

echo -e '
activate(){
  python -m venv .venv && source .venv/bin/activate

  if [ "$1" == "initial" ]; then
    pip install --upgrade pip flake8 autopep8
  fi
}' >> ~/.bashrc

echo -e '
autoclick(){
  while [ 1 ]; do
    sleep 5 && xdotool mousemove 325 50  click 1 && sleep 1 && xdotool click 1
    sleep 1 && xdotool mousemove 725 200 click 1 && sleep 1 && xdotool click 1

    sleep 5 && xdotool mousemove 625 50  click 1 && sleep 1 && xdotool click 1
    sleep 1 && xdotool mousemove 725 200 click 1 && sleep 1 && xdotool click 1

    sleep 5 && xdotool mousemove 1275 50  click 1 && sleep 1 && xdotool click 1
    sleep 1 && xdotool mousemove 1675 200 click 1 && sleep 1 && xdotool click 1

    sleep 5 && xdotool mousemove 1575 50  click 1 && sleep 1 && xdotool click 1
    sleep 1 && xdotool mousemove 1675 200 click 1 && sleep 1 && xdotool click 1
  done
}' >> ~/.bashrc

yay -c && yay -Scc
