#!/bin/bash -e

[ $# -eq 2 ] || {
	echo "Pass two args, like you would to mv. If the dest file is missing, the source will be moved."
	echo "If the dest file exists and has the same checksum as the source, the source will be deleted."
	echo "Otherwise, nothing will happen."
}

SRC="$1"
DEST="$2"

if [ -f "$SRC" ] && [ -f "$DEST" ]; then
	DESTSHA=$(cat "$DEST" | sha1sum)
	SRCSHA=$(cat "$SRC" | sha1sum)
	[ "$DESTSHA" = "$SRCSHA" ] && rm "$SRC"
else
	mv "$SRC" "$DEST"
fi

