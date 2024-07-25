#!/bin/bash
DIR=/home/ryan/backup-manager
J_FAILURES_FILE=$DIR/j-failures
[ -f $J_FAILURES_FILE ] && J_FAILURES=`cat $J_FAILURES_FILE`
[ -z "$J_FAILURES" ] && J_FAILURES=0

function notify {
  if [ -z "$1" ]; then
    echo Misuse of \'notify\' function\; must supply one arg
    exit 1
  fi
  if [ $1 -eq 0 ]; then
    cat $DIR/success-header $DIR/single-backup-log | /usr/sbin/sendmail zzantozz@gmail.com
  else
    cat $DIR/failure-header $DIR/single-backup-log | /usr/sbin/sendmail zzantozz@gmail.com
  fi
}

function notify_j_failure {
  if [ -z "$1" ]; then
    echo "Misuse of notify_j_failures; must supply one arg"
    exit 1
  fi
  echo $1 > $J_FAILURES_FILE
}

rm -f $DIR/single-backup-log

EXIT_CODES=0

for DEST in "192.168.1.103:/media/plex-media/archive" ; do
  DEST_EXIT_CODES=0
  TRACK_FAILURES=true
  [ $DEST = "/mnt/j" -a $J_FAILURES -lt 90 ] && TRACK_FAILURES=false
  $TRACK_FAILURES || echo "Disregarding failures because only $J_FAILURES consecutive backups to j: have failed." >> $DIR/single-backup-log 2>&1

  echo "======================================================" >> $DIR/single-backup-log 2>&1
  echo "Backing up archive dir to $DEST" >> $DIR/single-backup-log 2>&1
  date >> $DIR/single-backup-log
  echo "======================================================" >> $DIR/single-backup-log 2>&1
  { time rsync --stats --archive --backup --backup-dir archive-backup --delete --exclude **/Thumbs.db /mnt/d/archive $DEST; } &>> $DIR/single-backup-log
  DEST_EXIT_CODES=$((DEST_EXIT_CODES + $?))

  echo "======================================================" >> $DIR/single-backup-log 2>&1
  echo "Backing up projects dir to $DEST" >> $DIR/single-backup-log 2>&1
  date >> $DIR/single-backup-log
  echo "======================================================" >> $DIR/single-backup-log 2>&1
  { time rsync --stats --archive --delete --exclude-from $DIR/projects-exclusions /mnt/d/dev/projects $DEST; } &>> $DIR/single-backup-log
  DEST_EXIT_CODES=$((DEST_EXIT_CODES + $?))

  echo "======================================================" >> $DIR/single-backup-log 2>&1
  echo "Backing up pw db to $DEST" >> $DIR/single-backup-log 2>&1
  date >> $DIR/single-backup-log
  echo "======================================================" >> $DIR/single-backup-log 2>&1
  # Assumes a "kpdb" dir already exists because it's easier to do that than figure out how to create it here
  rsync -av /mnt/d/Dropbox/Private\ family\ stuff/kp209.kdbx "$DEST/kpdb/database-$(date +%Y-%m-%dT%H-%M-%S).kdbx" &>> $DIR/single-backup-log
  DEST_EXIT_CODES=$((DEST_EXIT_CODES + $?))

  [ $DEST = "/mnt/j" -a $DEST_EXIT_CODES -ne 0 ] && notify_j_failure $((J_FAILURES + 1))
  [ $DEST = "/mnt/j" -a $DEST_EXIT_CODES -eq 0 ] && rm -f $J_FAILURES_FILE
  $TRACK_FAILURES && EXIT_CODES=$((EXIT_CODES + DEST_EXIT_CODES))
done

# Below is the old code that backed up each dir to each dest. With a third destination (my cloud server),
# the rule of three applies, so attempting to migrate to a for loop. Below kept for posterity until I
# work out any kinks.

#echo "===========================" >> $DIR/single-backup-log 2>&1
#echo "Backing up archive dir to k" >> $DIR/single-backup-log 2>&1
#date >> $DIR/single-backup-log
#echo "===========================" >> $DIR/single-backup-log 2>&1
#{ time rsync --stats --archive --backup --backup-dir archive-backup --delete --exclude **/Thumbs.db /mnt/d/archive /mnt/k; } &>> $DIR/single-backup-log
#BACKUP1=$?
#
#echo "============================" >> $DIR/single-backup-log 2>&1
#echo "Backing up projects dir to k" >> $DIR/single-backup-log 2>&1
#date >> $DIR/single-backup-log
#echo "============================" >> $DIR/single-backup-log 2>&1
#{ time rsync --stats --archive --delete --exclude-from $DIR/projects-exclusions /mnt/d/dev/projects /mnt/k; } &>> $DIR/single-backup-log
#BACKUP2=$?
#
#echo "===========================" >> $DIR/single-backup-log 2>&1
#echo "Backing up archive dir to j" >> $DIR/single-backup-log 2>&1
#date >> $DIR/single-backup-log
#echo "===========================" >> $DIR/single-backup-log 2>&1
#{ time rsync --stats --archive --backup --backup-dir archive-backup --delete --exclude **/Thumbs.db /mnt/d/archive /mnt/j; } &>> $DIR/single-backup-log
#BACKUP3=$?
#
#echo "============================" >> $DIR/single-backup-log 2>&1
#echo "Backing up projects dir to j" >> $DIR/single-backup-log 2>&1
#date >> $DIR/single-backup-log
#echo "============================" >> $DIR/single-backup-log 2>&1
#{ time rsync --stats --archive --delete --exclude-from $DIR/projects-exclusions /mnt/d/dev/projects /mnt/j; } &>> $DIR/single-backup-log
#BACKUP4=$?
#
cat $DIR/single-backup-log >> $DIR/backup.log
notify $EXIT_CODES
