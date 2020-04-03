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
		echo "$dir" "${sed_script[$dir]}"
		src_files=$(find $dir -type f)
		dst_files=$(sed -E "${sed_script[$dir]}" <<<$src_files)
		echo "----------"
		echo "$src_files"
		echo "----------"
		echo "$dst_files"
		echo
	done
	break
done
