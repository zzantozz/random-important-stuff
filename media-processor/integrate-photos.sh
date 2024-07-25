#!/bin/bash

# This takes a dir to scan as input, and for every file in it, checks if it already exists in the archive. If the file
# exists, the script deletes it. If not, it tries to move it to the appropriate archive location. Only works for photos
# right now.

usage() {
  echo "Recursively scan a directory of photos, and integrate them into the appropriate dated archive folders."
  echo ""
  echo "$0 [-hk] -d scan_dir" >&2
  echo ""
  echo "    -h"
  echo "        Show this help."
  echo ""
  echo "    -k"
  echo "        Don't do a dry run. Really do things. Without this, the script only prints what it WOULD do."
  echo ""
  echo "    -d scan_dir"
  echo "        Set the base directory to start scanning. This is required."
  exit 1
}

while getopts "hkd:" opt; do
  case $opt in
    h) usage;;
    k) dry_run=false;;
    d) scan_dir="$OPTARG";;
    *) usage;;
  esac
done

[ -n "$scan_dir" ] || usage

analyze_file() {
  file="$1" && \
  echo "Checking $file" && \
  dups=$(./find_dups.sh "$file") && \
  if [ -n "$dups" ]; then
    echo "  has dups: $dups"
    if [ -z "$dry_run" ]; then
      echo "  would delete, but it's a dry run"
    else
      echo "  deleting"
      rm "$file"
    fi
  else
    echo "  no dups"
    date_of_pic=$(./date_of_pic.sh "$file") && \
    archive_dir=$(./pics_folder_from_date.sh "$date_of_pic") && \
    if [ -z "$dry_run" ]; then
      echo "  would move to $archive_dir, but it's a dry run"
    else
      echo "  moving to $archive_dir"
      mkdir -p "$archive_dir" && mv --no-clobber "$file" "$archive_dir"
    fi
  fi
}
export -f analyze_file

find "$scan_dir" -type f -print0 | xargs -0 -I {} bash -c 'analyze_file "{}"'
