#!/bin/sh
if [[ -z $1 ]]; then
        echo "no action defined"
        exit 1
fi

if [[ $1 == 'update' ]]; then
        exec sudo --preserve-env=GIT_PASSWORD /update_package.py
elif [[ $1 == 'build' ]]; then
        sudo pacman --noconfirm -Syu
        exec /build.py
elif [[ $1 == 'deploy' ]]; then
        exec /deploy.py
fi
