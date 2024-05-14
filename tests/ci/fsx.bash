#!/bin/bash -e

# fails
#fsx/fsx -N 1000 -W $PATH_MNTDIR/testfile
#fsx/fsx -N 1000 -R $PATH_MNTDIR/testfile

# passes with mmap disabled
if $TESTBIN/fsx/fsx -N 1000 -R -W -H $PATH_MNTDIR/testfile > $LOG.log 2>&1; then
    echo "SUCCESS"
else
    echo "FAIL"
fi
