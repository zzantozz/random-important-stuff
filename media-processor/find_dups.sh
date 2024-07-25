#!/bin/bash -e

[ -f "$1" ] || {
	echo "Pass the path to a file to check if it duplicates something in the archive."
	exit 1
}

[[ "$1" =~ ^/mnt/d/archive ]] && [[ ! "$1" =~ __integrate-me ]] && {
	echo "ERROR! You passed a file that's in the archive. Only compare non-archive files for dups."
	exit 1
}

SIZE=$(cat "$1" | wc --bytes)
SIZEMATCHES=$(find /mnt/d/archive -size ${SIZE}c -not -path "$1")
[ -z "$SIZEMATCHES" ] && {
	exit 0
}
INPUTHASH=$(sha1sum -b "$1" | cut -d ' ' -f 1)
for F in "$SIZEMATCHES"; do
	FHASH=$(sha1sum -b "$F" | cut -d ' ' -f 1)
	[[ "$FHASH" =~ "$INPUTHASH" ]] && {
		echo "$F"
	}
done
