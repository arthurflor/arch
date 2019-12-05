#!/bin/bash

set_keys() {
	op_title="$key_op_msg"

	while (true) do
		keyboard=$(dialog --nocancel --ok-button "$ok" --menu "$keys_msg" 14 60 5 \
		"$default" "$default Keymap" \
		"br-abnt2" "Brazilian" \
		"es" "Spanish" \
		"us" "United States" \
		"$other"       "$other-keymaps"		 3>&1 1>&2 2>&3)
		source "$lang_file"
    
		if [ "$keyboard" = "$other" ]; then
			keyboard=$(dialog --ok-button "$ok" --cancel-button "$cancel" --menu "$keys_msg" 18 60 11  $key_maps 3>&1 1>&2 2>&3)
			if [ "$?" -eq "0" ]; then
				break
			fi
		else
			break
		fi
	done

	localectl set-keymap "$keyboard"
	echo "$(date -u "+%F %H:%M") : Set keymap to: $keyboard" >> "$log"
}

set_locale() {
	op_title="$locale_op_msg"

	while (true) do
		LOCALE=$(dialog --nocancel --ok-button "$ok" --menu "$locale_msg" 12 60 6 \
		"pt_BR.UTF-8" "Brazil" \
		"es_ES.UTF-8" "Spanish" \
		"en_US.UTF-8" "United States" \
		"$other"       "$other-locale"		 3>&1 1>&2 2>&3)
    
		if [ "$LOCALE" = "$other" ]; then
			LOCALE=$(dialog --ok-button "$ok" --cancel-button "$cancel" --menu "$locale_msg" 18 60 11 $localelist 3>&1 1>&2 2>&3)
			if [ "$?" -eq "0" ]; then
				break
			fi
		else
			break
		fi
	done

	echo "$(date -u "+%F %H:%M") : Set locale to: $LOCALE" >> "$log"
}

set_zone() {
	op_title="$zone_op_msg"
	
	while (true) do
		ZONE=$(dialog --nocancel --ok-button "$ok" --menu "$zone_msg0" 18 60 11 $zonelist 3>&1 1>&2 2>&3)
		if (find /usr/share/zoneinfo -maxdepth 1 -type d | sed -n -e 's!^.*/!!p' | grep "$ZONE" &> /dev/null); then
			sublist=$(find /usr/share/zoneinfo/"$ZONE" -maxdepth 1 | sed -n -e 's!^.*/!!p' | sort | sed 's/$/ -/g' | grep -v "$ZONE")
			SUBZONE=$(dialog --ok-button "$ok" --cancel-button "$back" --menu "$zone_msg1" 18 60 11 $sublist 3>&1 1>&2 2>&3)
			if [ "$?" -eq "0" ]; then
				if (find /usr/share/zoneinfo/"$ZONE" -maxdepth 1 -type  d | sed -n -e 's!^.*/!!p' | grep "$SUBZONE" &> /dev/null); then
					sublist=$(find /usr/share/zoneinfo/"$ZONE"/"$SUBZONE" -maxdepth 1 | sed -n -e 's!^.*/!!p' | sort | sed 's/$/ -/g' | grep -v "$SUBZONE")
					SUB_SUBZONE=$(dialog --ok-button "$ok" --cancel-button "$back" --menu "$zone_msg1" 15 60 7 $sublist 3>&1 1>&2 2>&3)
					if [ "$?" -eq "0" ]; then
						ZONE="${ZONE}/${SUBZONE}/${SUB_SUBZONE}"
						break
					fi
				else
					ZONE="${ZONE}/${SUBZONE}"
					break
				fi
			fi
		else
			break
		fi
	done

	echo "$(date -u "+%F %H:%M") : Set timezone to: $ZONE" >> "$log"
}