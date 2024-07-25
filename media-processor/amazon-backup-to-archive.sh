#!/bin/bash

# Scans the amazon pics backup dir to make sure everything in it exists in the archive.

export scan_dir="/mnt/d/amazon-drive/Amazon Drive/Backup/DESK/D/archive/pics"
export archive_dir="/mnt/d/archive/pics"

check() {
  amazon_file="$1"
#  echo "Test $amazon_file"
  echo -n .
  amazon_hash="$(sha1sum < "$amazon_file")"
  # First, check for a file at the same path. This should be the most frequent case, and it'll be fast.
  rel_path="${amazon_file#$scan_dir}"
  [[ "$rel_path" = /* ]] && rel_path=${rel_path:1}
  archive_file="$archive_dir/$rel_path"
#  echo "  should be at $archive_file"
  if [ -f "$archive_file" ]; then
    archive_hash="$(sha1sum < "$archive_file")"
    if [ "$amazon_hash" = "$archive_hash" ]; then
#      echo "  found it where expected"
      found_match=true
    fi
  fi
  if [ -z "$found_match" ]; then
#    echo "  not where it was expected"
    # If looking at the same relative path fails, do a general search by size and then verify by checksum
    size=$(wc --bytes < "$amazon_file")
    size_matches=$(find "$archive_dir" -size "${size}c")
    if [ -n "$size_matches" ]; then
      local IFS=$'\n'
      for candidate_file in $size_matches; do
        candidate_hash="$(sha1sum < "$candidate_file")"
        if [ "$amazon_hash" = "$candidate_hash" ]; then
#          echo "  found size+hash match: $candidate_file"
           found_match=true
	   break
        fi
      done
    fi
  fi
  if [ -z "$found_match" ]; then
#    echo "  no matches at all!"
    echo "No archive match found for '$amazon_file'"
  fi
}
export -f check

find "$scan_dir" -type f -print0 | xargs -0 -I {} bash -c 'check "{}"'

