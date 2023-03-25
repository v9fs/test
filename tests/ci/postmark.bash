#!/bin/bash -e

PATH_POSTMARK=$TESTBIN/postmark/postmark
if (cd $PATH_MNTDIR >/dev/null
$PATH_POSTMARK <<EOT
set size 10 100000
set number 2000
set transactions 2000
show
run
quit
EOT
) > $LOG.log 2>&1; then
    echo "SUCCESS"
else
    echo "FAIL"
fi
