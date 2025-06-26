#!/bin/bash
set -e

ENC_PATH=/encrypted
DEC_PATH=/decrypted

ENC_FOLDERS=`find ${ENC_PATH} ! -path ${ENC_PATH} -maxdepth 1 -type d`

function sigterm_handler {
  echo "sending SIGTERM to child pid"
  kill -SIGTERM ${pids[@]}
  fuse_unmount
  echo "exiting container now"
  exit $?
}

function sighup_handler {
  echo "sending SIGHUP to child pid"
  kill -SIGHUP ${pids[@]}
  wait ${pids[@]}
}

function fuse_unmount {
  DEC_FOLDERS=`find ${DEC_PATH} ! -path ${DEC_PATH} -maxdepth 1 -type d`

  for DEC_FOLDER in $DEC_FOLDERS; do
    echo "Unmounting: fusermount $UNMOUNT_OPTIONS $DEC_FOLDER at: $(date +%Y.%m.%d-%T)"
    fusermount $UNMOUNT_OPTIONS $DEC_FOLDER
    rmdir $DEC_FOLDER
  done
}

trap sigterm_handler SIGINT SIGTERM
trap sighup_handler SIGHUP

unset pids
for ENC_FOLDER in $ENC_FOLDERS; do
  DEC_FOLDER=`echo "$ENC_FOLDER" | sed "s|^${ENC_PATH}|${DEC_PATH}|g"`
  mkdir -p $DEC_FOLDER

  if [ ! -f "${ENC_FOLDER}/gocryptfs.conf" ]; then
    gocryptfs -init -extpass 'printenv PASSWD' $ENC_FOLDER
  fi

  gocryptfs $MOUNT_OPTIONS -fg -extpass 'printenv PASSWD' $ENC_FOLDER $DEC_FOLDER & pids+=($!)
done
wait "${pids[@]}"

echo "gocryptfs crashed at: $(date +%Y.%m.%d-%T)"
fuse_unmount

exit $?
