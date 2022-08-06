#!/bin/bash
if [[ -z "$1" ]]; then
	echo 'no package name passed!'
	exit 1
fi

sudo git clone https://aur.archlinux.org/"$1".git "$1"_tmp
sudo mkdir -p "$1"
diff -qrN "$1" "$1"_tmp

# then check if diff is non-empty (i.e. there are changes)
# if there are, remove old directory and make tmp to new, else delete tmp

if ! diff -qrN "$1" "$1"_tmp ; then
	sudo rm -rf "$1"
	sudo mv "$1"_tmp "$1"
fi

cd "$1"
ls -lAh
