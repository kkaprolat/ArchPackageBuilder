#!/bin/bash
cd /aurdest
VCS_UPDATES=$(aur repo -l | aur vercmp -p <(aur srcver *-git) | sed 's/\s.*$//')

if [[ -z "$VCS_UPDATES" ]];
then
	echo 'No VCS updates available.'
else
	clear
	echo "VCS-Updates:"
	echo "$VCS_UPDATES"
	aur sync --upgrades --remove --format diff --noconfirm --nover-argv $VCS_UPDATES
fi
