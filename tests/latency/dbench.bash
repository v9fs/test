#!/bin/bash -e

if ${TESTBIN}/dbench/dbench -t 60 -c ${TESTBIN}/dbench/client.txt -D $PATH_MNTDIR 1 >$LOG.log 2>&1; then
    echo "SUCCESS"
    # now we need to parse it and add it to results?
    parser/dbench.py $FSTAB $REF 1 $NUMCPU $LOG.log results/dbench-latency.csv
else
    echo "FAIL"
fi
