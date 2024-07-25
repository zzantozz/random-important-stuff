#!/bin/bash -e

# trying to automate photo handling for rotations, deletions, moves, etc
# files will be uploaded to amazon, downloaded to here, and rsynced to long-term archive
# need to keep records of previous views to recognize when a file is legitimately deleted or moved
# and reflect that in the archive
# i was working on just the archive dir, but need to include the intake dir
# not sure exactly what the workflow should be. need to do some testing with real photos

archive_dir="$(realpath "${ARCHIVE_DIR:-/mnt/d/archive}")"
tracker_dir="$(realpath "${TRACKER_DIR:-/home/ryan/archive-tracker}")"
cs_dir="$tracker_dir/checksums"
audit_dir="$tracker_dir/audits"
ts="$(date -Is)"

[ -d "$archive_dir" ] || {
	echo "Missing archive dir '$archive_dir'" >&2
	exit 1
}

mkdir -p "$cs_dir"
mkdir -p "$audit_dir"

last_cs_file="$(ls -tr "$cs_dir" | head -1)"

if [ -n "$last_cs_file" ]; then
	new_audit_file="$audit_dir/$ts"
	echo "Use previous checksums at $last_cs_file to create audit $new_audit_file"
	pushd "$archive_dir" > /dev/null
	hashdeep -vvvrlawk "$cs_dir/$last_cs_file" . > "$new_audit_file" || true
	popd > /dev/null

	echo "Process newly added files"
	cat "$new_audit_file" | grep ': No match$' | sed 's/: No match$//g'

	echo "Process moved files"

	echo "Process deleted files"
else
	echo "No old checksum files found, skipping update/delete detection."
fi

old_cs_files="$(ls -tr "$cs_dir" | tail +6)"

if [ -n "$old_cs_files" ]; then
	echo "Remove old checksum files"
	for f in $old_cs_files; do
		echo "  remove $cs_dir/$f"
		rm "$cs_dir/$f"
	done
else
	echo "Less than five old checksum files exist, skipping cleanup."
fi

old_audit_files="$(ls -tr "$audit_dir" | tail +6)"

if [ -n "$old_audit_files" ]; then
        echo "Remove old audit files"
        for f in $old_audit_files; do
                echo "  remove $audit_dir/$f"
                rm "$audit_dir/$f"
        done
else
        echo "Less than five old audit files exist, skipping cleanup."
fi

new_cs_file="$cs_dir/$ts"

echo "Build new checksum file at $new_cs_file"
pushd "$archive_dir" > /dev/null
hashdeep -lrc sha1 . > "$new_cs_file"
popd > /dev/null

