#!/bin/bash
export TESTS=${1:-smoke}
export PATH_MNTDIR=/mnt/9/workspaces/tmp
export TESTBIN=${TESTBIN:-/home/v9fs-test/diod/tests/kern}
export TIMESTAMP=`date +%s`
mkdir -p logs/${TIMESTAMP}
export QEMULOG=logs/${TIMESTAMP}/qemu.log
export PIDFILE=/home/v9fs-test/qemu.pid
export QEMUSTATE=0
export CHECK=${3:-1}
export TYPE=${2:-ci}

mkdir -p /workspaces/tmp
rm -rf /workspaces/tmp/*

if [ "$TYPE" = "ci" ]; then
	export CHECK=${3:-1}
else
	export CHECK=${3:-0}
fi

echo TYPE: ${TYPE} TESTS: ${TESTS}

cleanup() {
  #if test -f "${QEMULOG}"; then
  #  echo === QEMU Log ===
  #  cat ${QEMULOG}
  #  echo === END QEMU Log ===
  #fi
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
  sleep 2
fi

if test -f ${PIDFILE}; then
  QEMUPID=`cat ${PIDFILE}`
  QEMUCMDLINE=`ps -o command -www --noheaders $QEMUPID || true`
  set -- $QEMUCMDLINE
  if [ -n "${1}" ]; then
    $1 --version || true
  fi
  echo $QEMUCMDLINE
else
  echo "WARNING: QEMU pidfile not found at ${PIDFILE}"
fi

echo Waiting for guest SSH...
for i in $(seq 1 60); do
  if cpu --key /home/v9fs-test/.ssh/identity localhost uname -rm >/dev/null 2>&1; then
    echo "Guest SSH is up."
    break
  fi
  sleep 1
done

echo Starting tests ${TIMESTAMP}
cpu --key /home/v9fs-test/.ssh/identity localhost uname -rm
rm -f logs/current
ln -s ${TIMESTAMP} logs/current
for f in fstabs-${TESTS}/*
do
  ft=`basename $f`
  OLDIFS="$IFS"
  IFS='-' tokens=( $ft )
  IFS="$OLDIFS"
  mkdir -p logs/${TIMESTAMP}/${tokens[0]}/${tokens[1]}
  echo running configuration ${tokens[0]} ${tokens[1]} ....
  for t in tests/${TYPE}/*
  do
    echo -n ...running test `basename $t .bash` ...
    export LOG=logs/${TIMESTAMP}/${tokens[0]}/${tokens[1]}/`basename $t .bash`
    /usr/bin/time -f %e -o $LOG.time cpu --key /home/v9fs-test/.ssh/identity --fstab $f localhost $t 
  done | tee logs/${TIMESTAMP}/${tokens[0]}/${tokens[1]}/results.log
  if [ $CHECK -eq 1 ]; then
    diff -b logs/${TIMESTAMP}/${tokens[0]}/${tokens[1]}/results.log good/${tokens[1]}/results.log
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
echo tests ${TESTS} ${TYPE} ${TIMESTAMP} done
if [ -n "${QEMUPID:-}" ]; then
  kill ${QEMUPID} || true
fi
exit 0
