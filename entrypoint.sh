#!/bin/sh
sudo pacman --noconfirm -Syu
bash -c "$@"
