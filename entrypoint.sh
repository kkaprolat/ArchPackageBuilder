#!/bin/sh
sudo pacman --noconfirm -Syu
exec "$@"
