#!/bin/bash -e

export SLEEP=${SLEEP:-1}
echo ""
echo " *** Amazon video cleanup - $(date)"

find /mnt/d/amazon-drive/ -iregex '.*\.\(mpg\|mov\|avi\|mp4\)' -mmin +120 -print0 | xargs -0 -I {} bash -c 'AMAZONFILE="{}" && ARCHIVEFILE=$(./archive_video_path.sh "$AMAZONFILE") && NEWHOME=$(./final_video_path.sh "$ARCHIVEFILE") && MOVECMD=(mv --no-clobber "$ARCHIVEFILE" "$NEWHOME") && CLEANUPCMD=(rm "$AMAZONFILE") && echo -e "${MOVECMD[@]} &&\n  ${CLEANUPCMD[@]}" && sleep $SLEEP && mkdir -p "$(dirname "$NEWHOME")" && "${MOVECMD[@]}" && "${CLEANUPCMD[@]}"'

echo " *** Done"
