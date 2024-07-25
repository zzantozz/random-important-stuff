#!/bin/bash -e

function clean_one2 {
        set -e
	INPUTHASH=$(sha1sum -b "$1" | cut -d ' ' -f 1)
	MATCHLINE=$(grep "$INPUTHASH" archive-hashes) || {
		echo "$1 - no match on hash"
		return 0
	}
	MATCH=$(echo "$MATCHLINE" | head -1 | cut -c 43-)
	echo "$1 duplicated by $MATCH"
#	rm "$1"
}
export -f clean_one2

[ -n "$NOREBUILD" ] || echo "Build hash file of archive backup"
[ -n "$NOREBUILD" ] || time find /mnt/d/amazon-drive/Amazon\ Drive/Backup/DESK -type f -mmin +1 -exec sha1sum '{}' \; > archive-hashes
find /mnt/d/amazon-drive -not -path '/mnt/d/amazon-drive/Amazon Drive/Backup/*' -not -path '*/Pictures/*/Screenshots/*' -type f -mmin +600 -print0 | xargs -0I {} bash -c 'clean_one2 "{}"'
