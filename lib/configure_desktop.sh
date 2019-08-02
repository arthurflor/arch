#!/bin/bash

graphics() {
	op_title="$de_op_msg"

	while (true) do
		de=$(dialog --separate-output --ok-button "$done_msg" --cancel-button "$cancel" --checklist "$environment_msg" 24 60 15 \
			"awesome"       	"$de9" OFF \
			"bspwm"			"$de13" OFF \
			"budgie"		"$de17" OFF \
			"cinnamon"      	"$de5" OFF \
			"deepin"		"$de14" OFF \
			"dwm"           	"$de12" OFF \
			"enlightenment" 	"$de7" OFF \
			"fluxbox"       	"$de11" OFF \
			"gnome-flashback"	"$de18" OFF \
			"gnome"         	"$de4" OFF \
			"i3"            	"$de10" OFF \
			"KDE plasma"    	"$de6" OFF \
			"lxde"          	"$de2" OFF \
			"lxqt"          	"$de3" OFF \
			"mate"          	"$de1" OFF \
			"openbox"       	"$de8" OFF \
			"windowmaker"		"$de15" OFF \
			"xfce4"         	"$de0" OFF \
			"xmonad"		"$de16" OFF 3>&1 1>&2 2>&3)
		if [ -z "$de" ]; then
			if (dialog --yes-button "$yes" --no-button "$no" --yesno "\n$desktop_cancel_msg" 10 60) then
				return
			fi
		else
			break
		fi
	done

	source "$lang_file"

	while read env
	  do
		case "$env" in
			"xfce4") 	start_term="exec startxfce4"
					DE+="xfce4 "
					
					if (dialog --yes-button "$yes" --no-button "$no" --yesno "\n$extra_msg0" 10 60) then
						DE+="xfce4-goodies "
					fi
			;;
			"budgie")	start_term="export XDG_CURRENT_DESKTOP=Budgie:GNOME ; exec budgie-desktop"
					DE+="budgie-desktop arc-icon-theme arc-gtk-theme elementary-icon-theme "
					
					if (dialog --yes-button "$yes" --no-button "$no" --yesno "\n$extra_msg6" 10 60) then
						DE+="gnome "
					fi
			;;
			"gnome")	start_term="exec gnome-session"
					DE+="gnome gnome-tweaks chrome-gnome-shell ffmpegthumbnailer system-config-printer "
					
					if (dialog --yes-button "$yes" --no-button "$no" --yesno "\n$extra_msg1" 10 60) then
						DE+="gnome-extra "
					fi
			;;
			"gnome-flashback")	start_term="export XDG_CURRENT_DESKTOP=GNOME-Flashback:GNOME ; exec gnome-session --session=gnome-flashback-metacity"
						DE+="gnome-flashback "
								
						if (dialog --yes-button "$yes" --no-button "$no" --yesno "\n$extra_msg1" 10 60) then
							DE+="gnome-backgrounds gnome-control-center gnome-screensaver gnome-applets sensors-applet "
						fi
			;;
			"mate")		start_term="exec mate-session"
			
					if (dialog --yes-button "$yes" --no-button "$no" --yesno "\n$extra_msg2" 10 60) then
						DE+="mate mate-extra gtk-engine-murrine "
					else
						DE+="mate gtk-engine-murrine "
					fi
			;;
			"KDE plasma")	start_term="exec startkde"
					
					if (dialog --defaultno --yes-button "$yes" --no-button "$no" --yesno "\n$extra_msg3" 10 60) then
						DE+="plasma-desktop sddm konsole dolphin plasma-nm plasma-pa libxshmfence kscreen sddm-kcm breeze-gtk kde-gtk-config user-manager kdeplasma-addons kinfocenter kwalletmanager plasma-browser-integration kaccounts-providers kate kcalc ark okular gwenview spectacle discover kdenetwork-filesharing kdegraphics-thumbnailers print-manager "

						if "$LAPTOP" ; then
							DE+="powerdevil "
						fi
					else
						DE+="plasma kde-applications "
					fi

					DE+="kdeconnect partitionmanager skanlite packagekit-qt5 qt5-imageformats ffmpegthumbs "
			;;
			"deepin")	start_term="exec startdde"
					DE+="deepin "
					
					if (dialog --yes-button "$yes" --no-button "$no" --yesno "\n$extra_msg4" 10 60) then
						DE+="deepin-extra "
					fi
 	 		;;
 	 		"xmonad")	start_term="exec xmonad"
					DE+="xmonad "
 	 				
 	 				if (dialog --yes-button "$yes" --no-button "$no" --yesno "\n$extra_msg5" 10 60) then
						DE="xmonad-contrib "
		                        fi
			;;
			"cinnamon")	DE+="cinnamon gnome-terminal file-roller p7zip zip unrar "
					start_term="exec cinnamon-session"
			;;
			"lxde")		start_term="exec startlxde"
					
					if (dialog --yes-button "$yes" --no-button "$no" --yesno "\n$gtk3_var" 10 60) then
						DE+="lxde-gtk3 "
						GTK3=true
					else
						DE+="lxde "
					fi		
			;;
			"lxqt")		start_term="exec startlxqt"
					DE+="lxqt oxygen-icons breeze-icons "
			;;
			"enlightenment") 	start_term="exec enlightenment_start"
						DE+="enlightenment terminology "
			;;
			"bspwm")	start_term="sxhkd & ; exec bspwm"
					DE+="bspwm sxhkd "
			;;
			"fluxbox")	start_term="exec startfluxbox"
					DE+="fluxbox "
			;;
			"openbox")	start_term="exec openbox-session"
					DE+="openbox "
			;;
			"awesome") 	start_term="exec awesome"
					DE+="awesome "
			;;
			"dwm") 		start_term="exec dwm"
					DE+="dwm "
			;;
			"i3") 		start_term="exec i3"
					DE+="i3 "
			;;
			"windowmaker")	start_term="exec wmaker"
					DE+="windowmaker "
					
					if (dialog --yes-button "$yes" --no-button "$no" --yesno "\n$extra_msg7" 10 60) then
						DE+="windowmaker-extra "
					fi
			;;
		esac
	done <<< $de

	while (true) do
		if "$VM" ; then
			case "$virt" in
				vbox) dialog --ok-button "$ok" --msgbox "\n$vbox_msg" 10 60
					GPU="virtualbox-guest-utils "
					if [ "$kernel" == "linux" ]; then
						GPU+="virtualbox-guest-modules-arch "
					else
						GPU+="virtualbox-guest-dkms "
					fi
	  			;;
	  			vmware)	dialog --ok-button "$ok" --msgbox "\n$vmware_msg" 10 60
					GPU="xf86-video-vmware xf86-input-vmmouse open-vm-tools net-tools gtkmm mesa mesa-libgl"
	  			;;
	  			hyper-v) dialog --ok-button "$ok" --msgbox "\n$hyperv_msg" 10 60
					GPU="xf86-video-fbdev mesa-libgl"
	  			;;
				*) dialog --ok-button "$ok" --msgbox "\n$vm_msg" 10 60
					GPU="xf86-video-fbdev mesa-libgl"
	  			;;
	  		esac
	  		break
	  	fi

		GPU=$(dialog --ok-button "$ok" --cancel-button "$cancel" --menu "$graphics_msg" 18 60 6 \
			"$default"		"$gr0" \
			"xf86-video-ati"	"$gr4" \
			"xf86-video-intel"	"$gr5" \
			"xf86-video-nouveau"	"$gr9" \
			"xf86-video-vesa"	"$gr1" \
			"bumblebee"		"$gr2 ->" 3>&1 1>&2 2>&3)
		ex="$?"

		if [ "$ex" -gt "0" ]; then
			if (dialog --yes-button "$yes" --no-button "$no" --yesno "$desktop_cancel_msg" 10 60) then
				return
			fi
		elif [ "$GPU" == "bumblebee" ]; then
			GPU="xf86-video-intel nvidia nvidia-utils nvidia-settings bumblebee"
			$enable_bumblebee=true
			break
		elif [ "$GPU" == "$default" ]; then
			GPU="$default_GPU mesa-libgl"
			break
		else
			GPU+=" mesa-libgl"
			break
		fi
	done

	DE+="$GPU xdg-user-dirs xorg-server xorg-apps xorg-xinit xterm ttf-dejavu ttf-liberation terminus-font adobe-source-han-sans-otc-fonts gvfs gvfs-smb gvfs-mtp pulseaudio pavucontrol pulseaudio-alsa alsa-utils "
	
	if [ "$net_util" == "networkmanager" ] ; then
		if (<<<"$DE" grep "plasma" &> /dev/null); then
			DE+="plasma-nm "
		else
			DE+="network-manager-applet "
		fi
	fi

	if (dialog --defaultno --yes-button "$yes" --no-button "$no" --yesno "\n$touchpad_msg" 10 60) then
		if (<<<"$DE" grep "gnome" &> /dev/null); then
			DE+="xf86-input-libinput "
		else
			DE+="xf86-input-synaptics "
		fi
	fi

	DM=$(dialog --ok-button "$ok" --cancel-button "$cancel" --menu "$dm_msg1" 13 64 4 \
		"gdm"		"$dm0" \
		"lightdm"	"$dm1" \
		"lxdm"		"$dm2" \
		"sddm"		"$dm3" 3>&1 1>&2 2>&3)

	if [ "$?" -eq "0" ]; then
		if [ "$DM" == "lightdm" ]; then
			DE+="$DM lightdm-gtk-greeter "
		elif [ "$DM" == "lxdm" ] && "$GTK3"; then
			DE+="${DM}-gtk3 "
		else
			DE+="$DM "
		fi
		enable_dm=true
	fi

	base_install+="$DE "
	desktop=true
}