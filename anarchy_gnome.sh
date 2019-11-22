#!/bin/bash

### SYSTEM ###

sudo sed -i 's/loglevel=3/loglevel=3 quiet/g' /etc/default/grub
sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo -e 'en_US.UTF-8 UTF-8' | sudo tee --append /etc/locale.gen && sudo locale-gen
echo -e 'FONT=lat0-16' | sudo tee --append /etc/vconsole.conf

sudo mkdir -p /etc/systemd/coredump.conf.d/
echo -e '[Coredump]\nStorage=none' | sudo tee --append /etc/systemd/coredump.conf.d/custom.conf
echo 'SystemMaxUse=50M' | sudo tee --append /etc/systemd/journald.conf

gsettings set org.gnome.settings-daemon.plugins.media-keys max-screencast-length 0
sudo sed -i 's/#AutoEnable=false/AutoEnable=true/g' /etc/bluetooth/main.conf

### PACKAGES ###

yay -Rcc baobab epiphany evolution-data-server rygel totem xdg-user-dirs-gtk vino vim yelp
yay -Rcc gnome-{books,characters,clocks,dictionary,disk-utility,documents,font-viewer,logs,music,photos,shell-extensions,software,weather}

yay -S wd719x-firmware aic94xx-firmware
yay -S pacman-contrib base-devel acpid fakeroot downgrade neofetch

yay -S xdotool ffmpegthumbnailer p7zip unrar sshfs gst-libav bluez-{hid2hci,plugins,tools}
yay -S gnome-{getting-started-docs,multi-writer,passwordsafe,tweaks} gedit-plugins

yay -S ttf-liberation ttf-ms-fonts adobe-source-han-sans-otc-fonts
yay -S pdfarranger system-config-printer cups-{filters,pdf} hplip

yay -S gparted alacarte jre8-openjdk pamac-aur smartgit visual-studio-code-bin
yay -S google-chrome chrome-gnome-shell transmission-gtk gimp mpv

yay -S libreoffice-{fresh,extension-languagetool}
yay -S hunspell-{en_US,pt-br} hyphen-{en,pt-br} libmythes mythes-{en,pt-br}

yay -c && yay -Scc

### WAKFU ###

cd ~ && wget -c https://download.ankama.com/launcher/full/linux/x64 -O wakfu
chmod +x wakfu

mkdir -p ~/.config/Ankama/ && mv ./wakfu ~/.config/Ankama/
sudo ln -s ~/.config/Ankama/wakfu /usr/bin/wakfu

echo -e '
[Desktop Entry]
Type=Application
Name=Wakfu
Icon=/home/$(whoami)/.config/Ankama/zaap/wakfu/icon.png
Exec=wakfu\nCategories=Game' > ~/.local/share/applications/wakfu.desktop

### Turn off screen when lid close ###

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


### ENVIRONMENT ###

sudo systemctl enable acpid
sudo systemctl enable org.cups.cupsd
sudo systemctl enable avahi-daemon

mv ~/Área\ de\ trabalho ~/Code
sed -i 's/Área de trabalho/Code/g' ~/.config/user-dirs.dirs ; xdg-user-dirs-update

mkdir -p ~/.config/autostart/
echo -e '
[Desktop Entry]
Type=Application
Name=transmission-gtk
Exec=transmission-gtk -m' > ~/.config/autostart/transmission-gtk.desktop

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
    sleep 5 && xdotool mousemove 325 50  click 1
    sleep 1 && xdotool mousemove 738 185 click 1

    sleep 5 && xdotool mousemove 725 50 click 1
    sleep 1 && xdotool mousemove 738 185 click 1

    sleep 5 && xdotool mousemove 1275 55 click 1
    sleep 1 && xdotool mousemove 1690 185 click 1

    sleep 5 && xdotool mousemove 1700 55 click 1
    sleep 1 && xdotool mousemove 1690 185 click 1
  done
}' >> ~/.bashrc

### SHORTCUTS ###

## print   : gnome-screenshot --interactive
## terminal: gnome-terminal
## monitor : gnome-system-monitor
## xkill   : xkill
## nautilus: nautilus --new-window
## desktop : ocultar todas as janelas normais
## Trocar para o espaço de trabalho

### EXTENSIONS ###

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
