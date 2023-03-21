#!/bin/bash -e

# fails
#fsx/fsx -N 1000 -W $PATH_MNTDIR/testfile
#fsx/fsx -N 1000 -R $PATH_MNTDIR/testfile

# passes with mmap disabled
if $TESTBIN/fsx/fsx -N 1000 -R -W $PATH_MNTDIR/testfile >logs/fsx.$STAMP.log 2>logs/fsx.$STAMP.err; then
    echo "SUCCESS"
else
    echo "FAIL"
fi