#!/bin/bash -e

echo -e "\n\n"
date
echo " vvvvvvvvvvvvvvvvvvvvvvvvv"

backup_one() {
  SOURCE_PATH="$1"
  SOURCE_DIR=$(dirname "$SOURCE_PATH")
  RELATIVE_PATH=${SOURCE_PATH#/mnt/d/amazon-drive-sync/Amazon\ Drive/}
  DEST_DIR=/mnt/d/archive/amazon-drive-archive
  DEST_PATH="$DEST_DIR/$RELATIVE_PATH"
  echo -n "Copy '$SOURCE_PATH' to '$DEST_PATH'"
  mkdir -p "$(dirname "$DEST_PATH")"
  echo ' exit before copy'
  exit 1
  rsync -ac "$SOURCE_PATH" "$DEST_PATH" && echo " - copied" && rm "$SOURCE_PATH"
}

export -f backup_one

# Sync and remove videos because the fill up space
echo "Sync and remove videos"
find /mnt/d/amazon-drive-sync/ -type f ! -name "*.jpg" ! -name "desktop.ini" -exec bash -c 'backup_one "{}"' \;
echo "Videos done"

# Then just sync photos because there's unlimited free storage for them
echo -e "\nSync photos"
rsync -av /mnt/d/amazon-drive-sync/Amazon\ Drive/ /mnt/d/archive/amazon-drive-archive/
echo "Photos done"

echo " ^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
