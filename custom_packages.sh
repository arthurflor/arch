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
    pkgin(){ pikaur -S \$@; }
    pkgre(){ pikaur -Rcc \$@; }
    pkgse(){ pikaur -Ss \$@; }
    pkgup(){ pikaur -Syyu; }
    pkgcl(){ pikaur -Scc; orphan=\$(pikaur -Qtdq) && pikaur -Rns \$orphan; }
    " | sudo tee --append ~/.bashrc

### Common packages 
    pikaur -S wd719x-firmware aic94xx-firmware --noconfirm
    pikaur -S jre multibootusb keepassxc pdfarranger --noconfirm

    pikaur -S google-chrome qbittorrent gimp vlc --noconfirm
    pikaur -S virtualbox virtualbox-guest-iso virtualbox-ext-oracle --noconfirm

    pikaur -S libreoffice-{fresh,extension-languagetool} hunspell-en_US hunspell-pt-br --noconfirm
    echo -e "export SAL_USE_VCLPLUGIN=gtk3" | sudo tee --append /etc/profile.d/libreoffice-fresh.sh
    sudo sed -i 's/Logo=1/Logo=0/' /etc/libreoffice/sofficerc

    pikaur -S smartgit visual-studio-code-bin --noconfirm

### Games
    pikaur -S libpng12 --noconfirm

    cd ~ && wget -c https://download.wakfu.com/full/linux/x64 -O - | tar -xz
    mkdir -p ~/.local/share/applications/ && mv Wakfu .wakfu && cd -
    echo -e "[Desktop Entry]\nEncoding=UTF-8\nType=Application\nName=Wakfu\nIcon=~/.wakfu/game/icon.png\nExec=optirun ~/.wakfu/Wakfu\nCategories=Game" | sudo tee --append ~/.local/share/applications/wakfu.desktop

### Custom packages and settings to KDE
if [ $desktop == "plasma" ] ; then
    ### -- | shortcuts | --
    ## launcher: monitor, dolphin, google-chrome, qbittorrent 
    ## kwin: show desktop

    sudo sed -i 's/margins.bottom;/margins.bottom + 6;/' /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/ui/code/layout.js
    
### Custom packages and settings to Gnome
elif [ $desktop == "gnome" ] ; then
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
fi

### Clear
sudo pacman -Scc; orphan=$(sudo pacman -Qtdq) && sudo pacman -Rns $orphan;

### -- | nvidia tips | --
## nvidia settings: optirun nvidia-settings -c :8
## Steam (nvidia): LD_PRELOAD='/usr/lib/nvidia/libGL.so' optirun %command%