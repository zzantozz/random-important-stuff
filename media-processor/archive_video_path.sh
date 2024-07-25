#!/bin/bash

[ -f "$1" ] || {
	echo "Give the path of a file in the amazon backup sync dir to find in the archive dir."
	exit 1
}

BASENAME=$(basename "$1")
ARCHIVEPATH=`find /mnt/d/archive/pics -name "$BASENAME"`
[ -z "$ARCHIVEPATH" ] && {
	echo "No matching archive file found for $1" >&2
	exit 1
}
[ `echo "$ARCHIVEPATH" | wc -l` = "1" ] || {
	echo "More than one matching archive file found for $1" >&2
	exit 1
}

AMAZONSHA=`sha1sum -b "$1" | cut -d ' ' -f 1`
ARCHIVESHA=`sha1sum -b "$ARCHIVEPATH" | cut -d ' ' -f 1`
[ "$AMAZONSHA" = "$ARCHIVESHA" ] || {
	echo "SHA1 mismatch. Abort! File: $1" >&2
	exit 1
}

echo "$ARCHIVEPATH"
