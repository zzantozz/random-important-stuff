#!/bin/bash -e

[[ $1 =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || {
	echo "Argument must be a date like YYYY-MM-DD. Got '$1'."
	exit 1
}
YEARMONTH="${1%-*}"

echo "/mnt/d/archive/home-video/$YEARMONTH"

