#!/bin/bash

conf="organiser.conf"
sleep_for=1
dir=""

dirs=()
cnt=0
declare -A sed_script

# Interpret configuration file
while IFS="" read -r line || [ -n "$line" ]; do

	# Match file rule
	if [[ "$line" =~ ^rule\ \"(.*)\"\ \"(.*)\"$ ]]; then
		if [[ "$dir" != "" ]]; then
			src=$(eval "echo \"${BASH_REMATCH[1]}\"")
			dst=$(eval "echo \"${BASH_REMATCH[2]}\"")
			sed_script[$dir]+="s/$src/$dst/; "
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
				printf "%s\n%s\n\n" "${src_files[i]}" "${dst_files[i]}"
			fi
		done

	done
	break
done
