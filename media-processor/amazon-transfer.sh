#!/bin/bash

date

cd /home/ryan/media-processor

echo "   ======"
echo "   VIDEOS"
echo "   ======"
find /mnt/d/amazon-drive/ -not -path '*/Backup/DESK/*' -iregex '.*\.\(mpg\|mov\|avi\|mp4\)' -mmin +10 -print0 | xargs -0 -I {} bash -c 'VIDEO="{}" && DATE=$(./date_of_video.sh "$VIDEO") && DEST=$(./video_folder_from_date.sh "$DATE") && BASENAME=$(basename "$VIDEO") && MOVECMD=(./safe-mv.sh "$VIDEO" "$DEST/$BASENAME") && echo "${MOVECMD[@]}" && mkdir -p "$DEST" && "${MOVECMD[@]}"'

pwd
echo ""
echo "   ===="
echo "   PICS"
echo "   ===="
find /mnt/d/amazon-drive/ -not -path '*/Backup/DESK/*' -not -path '*/Pictures/*/Screenshots/*' -regex '.*\.\(jpg\|png\)' -mmin +10 -print0 | xargs -0I {} bash -c 'FILE="{}" && DATE=$(./date_of_pic.sh "$FILE") && DEST=$(./pics_folder_from_date.sh "$DATE") && BASENAME=$(basename "$FILE") && [ ! -f "$DEST/$BASENAME" ] && CPCMD=(cp --no-clobber "$FILE" "$DEST/$BASENAME") && echo "${CPCMD[@]}" && mkdir -p "$DEST" && "${CPCMD[@]}"'
echo ""
