#!/bin/bash

init() {
	aa_dir=$(dirname $(readlink -f "$0"))
	
	aa_lib="$aa_dir"/lib
	for file in $(ls "$aa_lib") ; do
		source "$aa_lib"/"$file"
	done

	aa_conf="$aa_dir"/etc/arch.conf
	source "$aa_conf"

	export lang_file="$aa_dir"/etc/arch-lang.conf
	source "$lang_file"
}

main() {
	### configure_connection.sh
	update_mirrors
	check_connection

	### configure_locale.sh
	set_keys
	set_locale
	set_zone

	### configure_device.sh
	prepare_drives

	### configure_base.sh
	prepare_base

	### configure_desktop.sh
	graphics

	### install_base.sh
	install_base

	### configure_system.sh
	configure_system
	set_hostname

	### configure_user.sh
	add_user

	### menus.sh
	reboot_system
}

init
main