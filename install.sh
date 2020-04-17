exe_dir="$HOME/.local/bin"
conf_loc="$HOME/confs/autogyser.conf"

echo -n "Install dir [$exe_dir]: "
read tmp
if [[ "$tmp" != "" ]]; then
	exe_dir=$tmp
fi
exe="$exe_dir""/autogyser"

echo -n "Config location [$conf_loc]: "
read tmp
if [[ "$tmp" != "" ]]; then
	conf_loc=$tmp
fi

cat <<EOF >"$exe"
#!/bin/bash
$PWD/autogyser/main.sh $conf_loc
EOF

chmod +x "$exe"
