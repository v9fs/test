#!/bin/bash -e

if ${TESTBIN}/dbench/dbench -t 60 -c ${TESTBIN}/dbench/client.txt -D $PATH_MNTDIR 64 >logs/dbench.$STAMP.log 2>logs/dbench.$STAMP.err; then
    echo "SUCCESS"
else
    echo "FAIL"
fi
