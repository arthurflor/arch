#!/bin/bash

reboot_system() {
	op_title="$complete_op_msg"

	### Check if system is installed
	if "$INSTALLED" ; then
		while (true) do
			reboot_menu=$(dialog --nocancel --ok-button "$ok" --menu "$complete_msg" 16 60 7 \
				"$reboot0" "-" \
				"$reboot6" "-" \
				"$reboot2" "-" \
				"$reboot1" "-" \
				"$reboot4" "-" \
				"$reboot3" "-" 3>&1 1>&2 2>&3)

			case "$reboot_menu" in
				"$reboot0")
						umount -R "$ARCH"
						reset ; reboot ; exit
				;;
				"$reboot6")
						umount -R "$ARCH"
						reset ; poweroff ; exit
				;;
				"$reboot1")
						umount -R "$ARCH"
						reset ; exit
				;;
				"$reboot2")
						clear
						echo -e "$arch_chroot_msg"
						echo "/root" > /tmp/chroot_dir.var
						arch_chroot
						clear
				;;
				"$reboot3")
						add_user
				;;
				"$reboot4")
						clear ; less "$log" clear
				;;
			esac
		done
	else
		if (dialog --yes-button "$yes" --no-button "$no" --yesno "$not_complete_msg" 10 60) then
			umount -R "$ARCH"
			reset ; reboot ; exit
		fi
	fi
}

main_menu() {
	op_title="$menu_op_msg"
	while (true) do
		menu_item=$(dialog --nocancel --ok-button "$ok" --menu "$menu" 19 60 8 \
			"$menu13" "-" \
			"$menu0"  "-" \
			"$menu1"  "-" \
			"$menu2"  "-" \
			"$menu3"  "-" \
			"$menu5"  "-" \
			"$menu11" "-" \
			"$menu12" "-" 3>&1 1>&2 2>&3)

		case "$menu_item" in
			"$menu0")
					set_locale
			;;
			"$menu1")
					set_zone
			;;
			"$menu2")
					set_keys
			;;
			"$menu3")
					if "$mounted" ; then
						if (dialog --yes-button "$yes" --no-button "$no" --defaultno --yesno "\n$menu_err_msg3" 10 60); then
							mounted=false ; prepare_drives
						fi
					else
						prepare_drives
					fi
			;;
			"$menu5")
					if "$mounted" ; then
						prepare_base
						graphics
						install_base
						configure_system
						set_hostname
						add_user
						reboot_system
					elif (dialog --yes-button "$yes" --no-button "$no" --yesno "\n$install_err_msg1" 10 60) then
						prepare_drives
					fi
			;;
			"$menu11")
					reboot_system
			;;
			"$menu12")
					if (dialog --yes-button "$yes" --no-button "$no" --yesno "\n$menu_exit_msg" 10 60) then
						reset ; exit
					fi
			;;
			"$menu13")
					echo -e "alias arch=exit ; echo -e '$return_msg'" > /tmp/.zshrc
					clear
					ZDOTDIR=/tmp/ zsh
					rm /tmp/.zshrc
					clear
			;;
		esac
	done
}