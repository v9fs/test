#!/bin/bash -e

# setup chroot

mount -o bind /dev /mnt/9/dev
mount -o bind /sys /mnt/9/sys

# test mmap via ldconfig doesn't produce lots of errors

chroot /mnt/9 ldconfig -C /tmp/testldconfig.cache > $LOG.log 2>&1

if [ -s $LOG.log ]; then
    echo "FAIL"
else
    echo "SUCCESS"
fi
