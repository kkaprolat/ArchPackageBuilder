#!/bin/sh

REPO=/root/repo/
VIEWDB=/root/viewdb/
AURDEST=/root/aurdest/
clear
docker run --rm -it -v $REPO:/repo -v $VIEWDB:/viewdb -v $AURDEST:/aurdest aurbuilder bash -c '/update.sh'

# rsync/upload the repo
echo "Syncing to mirror..."
rsync -a --delete $REPO root@10.0.0.102:/srv/packages/custom
