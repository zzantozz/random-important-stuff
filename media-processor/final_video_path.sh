#!/bin/bash

[[ -f "$1" && "$1" =~ ^/mnt/d/archive/pics/ ]] || {
	echo "Give the path of a video file in the pics archive to find where it should move to."
	exit 1
}

NEWHOME=`echo $1 | sed "s#/pics/#/home-video/#"`
[ -e "$NEWHOME" ] && {
	echo "New home already occupied. Check video at $NEWHOME" >&2
	exit 1
}
echo "$NEWHOME"
