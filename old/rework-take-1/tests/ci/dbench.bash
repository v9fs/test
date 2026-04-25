#!/bin/bash -e

if ${TESTBIN}/dbench/dbench -t 60 -c ${TESTBIN}/dbench/client.txt -D $PATH_MNTDIR 64 >$LOG.log 2>&1; then
    echo "SUCCESS"
else
    echo "FAIL"
fi
