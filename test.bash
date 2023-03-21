#!/bin/bash
export PATH_MNTDIR=/mnt/9
export TESTBIN=/home/v9fs-test/diod/tests/kern
export TIMESTAMP=`date +%s`
mkdir -p logs
for f in fstabs/*
do
  export STAMP=$(basename $f).$TIMESTAMP
  for t in tests/*
  do
    echo -n running test $t with fstab $f ...
    cpu --key /home/v9fs-test/.ssh/identity --fstab $f localhost $t
  done
done

echo Done
