#!/bin/bash

conf="organiser.conf"
sleep_for=1
dir=""

dirs=()
cnt=0
declare -A sed_script

mk_parentdir() {
	mkdir -p "$1"
	rmdir "$1"
}

is_file_busy() {
	res=$(lsof -f -- "$1")
	if [[ "$res" == "" ]]; then
		return 0
	fi
	return 1
}

# Interpret configuration file
while IFS="" read -r line || [ -n "$line" ]; do

	# Match file rule
	if [[ "$line" =~ ^rule\ \"(.*)\"\ \"(.*)\"$ ]]; then
		if [[ "$dir" != "" ]]; then
			src=$(eval "echo \"${BASH_REMATCH[1]}\"")
			dst=$(eval "echo \"${BASH_REMATCH[2]}\"")
			sed_script[$dir]+="s/$src/$dst/;t; "
			((cnt++))
		fi

	# Match watch dir
	elif [[ "$line" =~ ^dir\ \"?([^\"]*)\"?$ ]]; then
		dir=$(eval "echo \"${BASH_REMATCH[1]}\"")
		sed_script[$dir]=""
		dirs+=($dir)

	# Match variables
	elif [[ "$line" =~ ^([^\ ]+)[\ ]*=[\ ]*(.+)$ ]]; then
		declare "${BASH_REMATCH[1]}"=$(eval echo ${BASH_REMATCH[2]})
	fi
done <$conf

while [[ true ]]; do
	for dir in "${dirs[@]}"; do
		echo ">>>" $dir ${sed_script[$dir]}

		find_data=$(find $dir -type f)
		IFS=$'\n' read -r -d '' -a src_files <<<$find_data
		sed_data=$(sed -E "${sed_script[$dir]}" <<<$find_data)
		IFS=$'\n' read -r -d '' -a dst_files <<<$sed_data

		for ((i = 0; i < ${#src_files[@]}; ++i)); do
			src=${src_files[i]}
			dst=${dst_files[i]}

			if [[ "$src" != "$dst" ]]; then
				printf "\nMove %s\nto %s\n" "$src" "$dst"
				is_file_busy "$src"
				if [[ $? == 1 ]]; then
					printf "(file is busy)\n"
					printf "y/[n]? "
					read action

					# Set to default
					if [[ "$action" != "y" ]]; then
						action="n"
					fi
				else
					printf "[y]/n? "
					read action

					# Set to default
					if [[ "$action" != "n" ]]; then
						action="y"
					fi
				fi
				
				if [[ "$action" == "y" ]]; then
					mk_parentdir "$dst"
					mv "$src" "$dst"
				fi
			fi
		done

	done
	break
done
