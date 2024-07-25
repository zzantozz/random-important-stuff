#!/bin/bash -e

[ -f "$1" ] || {
	echo "First argument should be the path to a video for processing."
	exit 1
}

DATE=unknown

# See if ffmpeg knows.
RAWTS=`ffmpeg -i "$1" -dump 2>&1 | grep creation_time | head -1`
[[ $RAWTS =~ creation_time\ +:\ +([0-9]{4}-[0-9]{2}-[0-9]{2})[:\ T] ]] && {
	DATE=${BASH_REMATCH[1]}
}

# Try a series of known filename patterns. Figure these out by trial and error
BASENAME=$(basename "$1")
[[ $BASENAME =~ ^([0-9]{8})_[0-9]{6}\. ]] && {
	NOCOLONS=${BASH_REMATCH[1]}
	Y=${NOCOLONS:0:4}
	M=${NOCOLONS:4:2}
	D=${NOCOLONS:6:2}
	DATE="$Y-$M-$D"
}
[[ $BASENAME =~ ^PXL_([0-9]{8})_[0-9]{9}\. ]] && {
	NOCOLONS=${BASH_REMATCH[1]}
	Y=${NOCOLONS:0:4}
	M=${NOCOLONS:4:2}
	D=${NOCOLONS:6:2}
	DATE="$Y-$M-$D"
}
[[ $BASENAME =~ ^VID_([0-9]{8})_[0-9]{6}\. ]] && {
	NOCOLONS=${BASH_REMATCH[1]}
	Y=${NOCOLONS:0:4}
	M=${NOCOLONS:4:2}
	D=${NOCOLONS:6:2}
	DATE="$Y-$M-$D"
}
[[ $BASENAME =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2})\ [0-9]{2}\.[0-9]{2}\.[0-9]{2}\. ]] && {
	DATE=${BASH_REMATCH[1]}
}
[[ $1 =~ from\ 2008\ dvd/([0-9]{1,2})-([0-9]{1,2})-([0-9]{2})/MOV ]] && {
	M=`printf "%02d" ${BASH_REMATCH[1]}`
	D=`printf "%02d" ${BASH_REMATCH[2]}`
	Y=${BASH_REMATCH[3]}
	DATE="20$Y-$M-$D"
}
[[ $1 =~ from\ 2008\ dvd/([0-9]{1,2})-([0-9]{1,2})-([0-9]{2})\ nicola/MOV ]] && {
	M=`printf "%02d" ${BASH_REMATCH[1]}`
	D=`printf "%02d" ${BASH_REMATCH[2]}`
	Y=${BASH_REMATCH[3]}
	DATE="20$Y-$M-$D"
}
[[ $1 =~ archive/pics/([0-9]{4}-[0-9]{2}) ]] && {
	DATE=${BASH_REMATCH[1]}-01
}

# Check if we found a good date
[[ $DATE =~ ^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$ ]] && {
	echo "$DATE"
} || {
	echo "Couldn't find valid date. Got $DATE for:" >&2
	echo "  $1" >&2
	exit 1
}
