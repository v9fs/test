#!/bin/bash -e

# fails
#fsx/fsx -N 1000 -W $PATH_MNTDIR/testfile
#fsx/fsx -N 1000 -R $PATH_MNTDIR/testfile

# passes with mmap disabled
if $TESTBIN/fsx/fsx -N 1000 $PATH_MNTDIR/testfile >logs/fsx-mmap.$STAMP.log 2>logs/fsx-mmap.$STAMP.err; then
    echo "SUCCESS"
else
    echo "FAIL"
fi