#!/bin/bash
export TESTS=${1:-smoke}
export PATH_MNTDIR=/mnt/9
export TESTBIN=/home/v9fs-test/diod/tests/kern
export TIMESTAMP=`date +%s`
mkdir -p logs/${TIMESTAMP}
export QEMULOG=logs/${TIMESTAMP}/qemu.log
export PIDFILE=/home/v9fs-test/qemu.pid
export QEMUSTATE=0
export CHECK=${2:-1}

cleanup() {
  if test -f "${QEMULOG}"; then
    echo === QEMU Log ===
    cat ${QEMULOG}
    echo === END QEMU Log ===
  fi
  # only kill qemu if we started it
  if [ $QEMUSTATE -eq 0 ]; then
    if test -f ${PIDFILE}; then
      kill `cat ${PIDFILE}`
    fi
  fi
}

if test -f ${PIDFILE}; then
  echo Qemu already running, trying to use it
  export QEMUSTATE=1
else
  echo Starting qemu
  /home/v9fs-test/test/qemu.bash
  sleep 5
fi

echo Starting tests ${TIMESTAMP}
for f in fstabs-${TESTS}/*
do
  ft=`basename $f`
  OLDIFS="$IFS"
  IFS='-' tokens=( $ft )
  IFS="$OLDIFS"
  mkdir -p logs/${TIMESTAMP}/${tokens[0]}/${tokens[1]}
  echo running configuration ${tokens[0]} ${tokens[1]} ....
  for t in tests/*
  do
    echo -n ...running test `basename $t .bash` ...
    export LOG=logs/${TIMESTAMP}/${tokens[0]}/${tokens[1]}/`basename $t .bash`
    /usr/bin/time -f %e -o $LOG.time cpu --key /home/v9fs-test/.ssh/identity --fstab $f localhost $t 
  done | tee logs/${TIMESTAMP}/${tokens[0]}/${tokens[1]}/results.log
  if [ $CHECK -eq 1 ]; then
    diff logs/${TIMESTAMP}/${tokens[0]}/${tokens[1]}/results.log good/${tokens[1]}/results.log
    error=$?
    if [ $error -eq 1 ]; then
      cleanup
      echo Configuration $f FAILED - exiting
      cat logs/${TIMESTAMP}/${tokens[0]}/${tokens[1]}/results.log
      exit 1
    fi
  fi
done

cleanup
echo tests ${TIMESTAMP} done
exit 0