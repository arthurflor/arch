#!/bin/bash

echo "Do you want to start?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) exit;;
    esac
done

desktop=$(echo $DESKTOP_SESSION | grep -Eo "plasma|gnome")

### AUR (pikaur)
    git clone https://aur.archlinux.org/pikaur.git && cd pikaur && makepkg -fsri && cd - && sudo rm -R pikaur

    echo -e "
    autoclick(){ xdotool click --delay 10000 --repeat 99999 1; }
    activate(){ python -m venv .venv && source .venv/bin/activate; }
    pkgin(){ pikaur -S \$@; }
    pkgre(){ pikaur -Rcc \$@; }
    pkgse(){ pikaur -Ss \$@; }
    pkgup(){ pikaur -Syyu; }
    pkgcl(){ pikaur -Scc; orphan=\$(pikaur -Qtdq) && pikaur -Rns \$orphan; }" >> ~/.bashrc

    pikaur -S libinput-gestures --noconfirm
    sudo sed -i "s/gesture/#gesture/g" /etc/libinput-gestures.conf

    echo -e "gesture swipe right _internal ws_up" | sudo tee --append /etc/libinput-gestures.conf
    echo -e "gesture swipe left  _internal ws_down" | sudo tee --append /etc/libinput-gestures.conf

    echo -e "gesture swipe up    xdotool key super+a" | sudo tee --append /etc/libinput-gestures.conf
    echo -e "gesture swipe down  xdotool key ctrl+F7" | sudo tee --append /etc/libinput-gestures.conf

    sudo gpasswd -a $(whoami) input && libinput-gestures-setup autostart

### Common packages
    pikaur -S wd719x-firmware aic94xx-firmware --noconfirm
    pikaur -S jre multibootusb keepassxc pdfarranger --noconfirm

    pikaur -S google-chrome qbittorrent gimp vlc --noconfirm
    pikaur -S virtualbox virtualbox-ext-oracle --noconfirm

    pikaur -S libreoffice-{fresh,extension-languagetool} hunspell-en_US hunspell-pt-br --noconfirm
    echo -e "export SAL_USE_VCLPLUGIN=gtk3" | sudo tee --append /etc/profile.d/libreoffice-fresh.sh
    sudo sed -i 's/Logo=1/Logo=0/' /etc/libreoffice/sofficerc

    pikaur -S smartgit visual-studio-code-bin --noconfirm

### Games
    pikaur -S openssl-1.0 libpng12 --noconfirm
    cd ~ && wget -c https://download.wakfu.com/full/linux/x64 -O - | tar -xz

    mkdir -p ~/.local/share/applications/ && mv Wakfu .wakfu && cd -
    sudo ln -s ~/.wakfu/Wakfu /usr/bin/wakfu
    echo -e "[Desktop Entry]\nType=Application\nName=Wakfu\nIcon=/home/$(whoami)/.wakfu/game/icon.png\nExec=wakfu\nCategories=Game" > ~/.local/share/applications/wakfu.desktop

    ### -- | wakfu tips | --
    ## ~/.wakfu/jre/bin/ControlPanel
    ## Java config: Parameters runtime: -Xms4096m -Xmx4096m

### Custom packages and settings to Gnome
if [ $desktop == "gnome" ] ; then
    ### -- | shorcuts | --
    ## print   : gnome-screenshot --interactive
    ## terminal: gnome-terminal
    ## monitor : gnome-system-monitor
    ## xkill   : xkill
    ## nautilus: nautilus --new-window
    ## desktop : ocultar todas as janelas normais

    ### -- | extensions | --
    ## AlternateTab
    ## Arch Linux Updates Indicator
    ## Bumblebee Status
    ## Clipboard Indicator
    ## Dash to Dock
    ## Dynamic Panel Transparency
    ## GSConnect
    ## OpenWeather
    ## Sound Input & Output Device Chooser
    ## Status Area Horizontal Spacing
    ## TopIcons Plus

    ### Remove packages unused
    sudo pacman -Rcc gnome-{boxes,calendar,characters,clocks,contacts,dictionary,documents,font-viewer,getting-started-docs,logs,maps,music,shell-extensions,todo,video-effects}
    sudo pacman -Rcc baobab evolution evolution-data-server rygel totem xdg-user-dirs-gtk vino yelp

    ### Gnome settings
    echo -e "HandleLidSwitch=lock" | sudo tee --append /etc/systemd/logind.conf
    gsettings set org.gnome.settings-daemon.plugins.media-keys max-screencast-length 0

### Custom packages and settings to KDE
# elif [ $desktop == "plasma" ] ; then
    ### -- | shortcuts | --
    ## launcher: monitor, dolphin, google-chrome, qbittorrent
    ## kwin: show desktop
fi

### Clear
sudo pacman -Scc; orphan=$(sudo pacman -Qtdq) && sudo pacman -Rns $orphan;

### -- | nvidia tips | --
## nvidia settings: optirun nvidia-settings -c :8
## Steam (nvidia): LD_PRELOAD='/usr/lib/nvidia/libGL.so' optirun %command%