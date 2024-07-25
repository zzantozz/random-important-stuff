#!/bin/bash -e

[ -f "$1" ] || {
	echo "First argument should be the path to a picture for processing."
	exit 1
}

DATE=unknown

# Try exif data. Most likely place to find it.
RAWTS=`exif --machine-readable --tag=0x0132 "$1" 2>/dev/null` && {
	# Timestamp like 2019:09:14 17:01:48, possibly repeated if it has duplicate tags
	COLONDATE=${RAWTS%% *}
	DATE=${COLONDATE//:/-}
}

# Try a series of known filename patterns. Figure these out by trial and error
BASENAME=$(basename "$1")
[[ $BASENAME =~ ^download_([0-9]{8})_[0-9]{6}\. ]] && {
	NOCOLONS=${BASH_REMATCH[1]}
	Y=${NOCOLONS:0:4}
	M=${NOCOLONS:4:2}
	D=${NOCOLONS:6:2}
	DATE="$Y-$M-$D"
}
[[ $BASENAME =~ ^IMG_([0-9]{8})_[0-9]{6}_[0-9]{3}\. ]] && {
	NOCOLONS=${BASH_REMATCH[1]}
	Y=${NOCOLONS:0:4}
	M=${NOCOLONS:4:2}
	D=${NOCOLONS:6:2}
	DATE="$Y-$M-$D"
}
[[ $BASENAME =~ ^IMG_([0-9]{8})_[0-9]{6}\. ]] && {
	NOCOLONS=${BASH_REMATCH[1]}
	Y=${NOCOLONS:0:4}
	M=${NOCOLONS:4:2}
	D=${NOCOLONS:6:2}
	DATE="$Y-$M-$D"
}
[[ $BASENAME =~ ^([0-9]{8})_[0-9]{6}\. ]] && {
	NOCOLONS=${BASH_REMATCH[1]}
	Y=${NOCOLONS:0:4}
	M=${NOCOLONS:4:2}
	D=${NOCOLONS:6:2}
	DATE="$Y-$M-$D"
}
[[ "$BASENAME" =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2})\ [0-9]{2}\.[0-9]{2}\.[0-9]{2}(-[0-9])?\. ]] && {
	DATE=${BASH_REMATCH[1]}
}

# Check if we found a good date
[[ $DATE =~ ^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$ ]] && {
	echo "$DATE"
} || {
	echo "Couldn't find valid date. Got $DATE for:" >&2
	echo "  $1" >&2
	exit 1
}
