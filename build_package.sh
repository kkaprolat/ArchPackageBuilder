#!/bin/bash
set -e

if [[ -z "$1" ]]; then
	echo 'no package name passed!'
	exit 1
fi

ls -lAh
pwd
git clone https://aur.archlinux.org/"$1".git "$1"_tmp
mkdir -p "$1"
diff -qrN "$1" "$1_tmp

# then check if diff is non-empty (i.e. there are changes)
# if there are, remove old directory and make tmp to new, else delete tmp

# if [[ -z $DIFF_OUTPUT ]]; then...
