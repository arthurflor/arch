#!/bin/bash

prepare_base() {
	op_title="$install_op_msg"

	while (true) do
		install_menu=$(dialog --ok-button "$ok" --cancel-button "$cancel" --menu "$install_type_msg" 17 69 8 \
			"Arch-Linux-Base" 		"$base_msg0" \
			"Arch-Linux-Base-Devel" 	"$base_msg1" \
			"Arch-Linux-Hardened"		"$hardened_msg0" \
			"Arch-Linux-Hardened-Devel"	"$hardened_msg1" \
			"Arch-Linux-LTS-Base" 		"$LTS_msg0" \
			"Arch-Linux-LTS-Base-Devel"	"$LTS_msg1" \
			"Arch-Linux-Zen"		"$zen_msg0" \
			"Arch-Linux-Zen-Devel"		"$zen_msg1" 3>&1 1>&2 2>&3)
		if [ "$?" -gt "0" ]; then
			if (dialog --defaultno --yes-button "$yes" --no-button "$no" --yesno "\n$exit_msg" 10 60) then
				main_menu
			fi
		else
			break
		fi
	done

	case "$install_menu" in
		"Arch-Linux-Base")
			base_install="linux-headers sudo " kernel="linux"
		;;
		"Arch-Linux-Base-Devel")
			base_install="base-devel linux-headers " kernel="linux"
		;;
		"Arch-Linux-Hardened")
			base_install="linux-hardened linux-hardened-headers sudo " kernel="linux-hardened"
		;;
		"Arch-Linux-Hardened-Devel")
			base_install="base-devel linux-hardened linux-hardened-headers " kernel="linux-hardened"
		;;
		"Arch-Linux-LTS-Base")
			base_install="linux-lts linux-lts-headers sudo " kernel="linux-lts"
		;;
		"Arch-Linux-LTS-Base-Devel")
			base_install="base-devel linux-lts linux-lts-headers " kernel="linux-lts"
		;;
		"Arch-Linux-Zen")
			base_install="linux-zen linux-zen-headers sudo " kernel="linux-zen"
		;;
		"Arch-Linux-Zen-Devel")
			base_install="base-devel linux-zen linux-zen-headers " kernel="linux-zen"
		;;
	esac

	while (true) do
		shell=$(dialog --ok-button "$ok" --cancel-button "$cancel" --menu "$shell_msg" 16 64 6 \
			"bash"  "$shell5" \
			"dash"	"$shell0" \
			"fish"	"$shell1" \
			"mksh"	"$shell2" \
			"tcsh"	"$shell3" \
			"zsh"	"$shell4" 3>&1 1>&2 2>&3)
		if [ "$?" -gt "0" ]; then
			if (dialog --defaultno --yes-button "$yes" --no-button "$no" --yesno "\n$exit_msg" 10 60) then
				main_menu
			fi
		else
			case "$shell" in
                bash) sh="/bin/bash" shell="bash-completion"
                ;;
				fish) 	sh="/bin/bash"
				;;
				zsh) 	shrc=$(dialog --ok-button "$ok" --cancel-button "$cancel" --menu "\n$shrc_msg" 13 65 4 \
								"$default"		"$shrc_msg1" \
								"grml-zsh-config"	"$shrc_msg4" \
								"$none"			"$shrc_msg3" 3>&1 1>&2 2>&3)
								if [ "$?" -gt "0" ]; then
									shrc="$default"
								fi

								sh="/usr/bin/$shell" shell="zsh zsh-syntax-highlighting"
								
								if [ "$shrc" == "grml-zsh-config" ]; then
									shell+=" grml-zsh-config zsh-completions"
								fi
				;;
				*) sh="/bin/$shell"
				;;
			esac

			base_install+="$shell "
			break
		fi
	done

	while (true) do
		net_util=$(dialog --ok-button "$ok" --cancel-button "$cancel" --menu "$wifi_util_msg" 13 64 3 \
			"networkmanager" 		"$net_util_msg1" \
			"netctl"			"$net_util_msg0" \
			"$none" "-" 3>&1 1>&2 2>&3)

		if [ "$?" -gt "0" ]; then
			if (dialog --defaultno --yes-button "$yes" --no-button "$no" --yesno "\n$exit_msg" 10 60) then
				main_menu
			fi
		else
			if [ "$net_util" == "netctl" ] || [ "$net_util" == "networkmanager" ]; then
				base_install+="$net_util dialog " enable_nm=true
			fi
			break
		fi
	done

	if [ "$arch" == "x86_64" ]; then
		if (dialog --yes-button "$yes" --no-button "$no" --yesno "\n\n$multilib_msg" 11 60) then
		    multilib=true
		    echo "$(date -u "+%F %H:%M") : Include multilib" >> "$log"
		fi
	fi

	if "$bluetooth" ; then
		base_install+="bluez bluez-utils bluez-tools bluez-plugins bluez-hid2hci bluedevil pulseaudio-bluetooth "
		enable_bt=true
	fi

	if "$enable_f2fs" ; then
		base_install+="f2fs-tools "
	fi

	if "$UEFI" ; then
		base_install+="efibootmgr "
	fi

	base_install+="pacman-contrib base-devel "
	base_install+="grub wireless_tools wpa_supplicant "
	base_install+="wget git p7zip unrar zip unzip "
	base_install+="ntfs-3g openssh sshfs net-tools neofetch "
	base_install+="cups cups-filters cups-pdf hplip "
}