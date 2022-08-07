#!/bin/sh
if [[ -z $1 ]]; then
        echo "no action defined"
        exit 1
fi

if [[ $1 == 'update' ]]; then
        exec sudo /update_package.py
elif [[ $1 == 'build' ]]; then
        sudo pacman --noconfirm -Syu
        exec /build.py
fi
