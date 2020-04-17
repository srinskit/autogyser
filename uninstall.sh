exe_dir="$HOME/.local/bin"

echo -n "Install dir [$exe_dir]: "
read tmp
if [[ "$tmp" != "" ]]; then
	exe_dir=$tmp
fi
exe="$exe_dir""/autogyser"

rm "$exe"