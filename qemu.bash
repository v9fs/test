#!/bin/bash

# ^a+x to terminate

export ARCH=`uname -m`
export KERNEL="/tmp/Image"
export INITRD="/home/v9fs-test/initrd.cpio"

if [ $ARCH == "aarch64" ]
then
    export QEMU="qemu-system-aarch64"
    export KERNEL="/tmp/Image"
    export MACHINE=virt
    export EXTRA="-append \"earlycon console=ttyAMA0\""
elif [ $ARCH == "x86_64" ]
then
    export QEMU="qemu-system-x86_64"
    export KERNEL="/tmp/Image"
    export MACHINE=q35
    export EXTRA="-append \"console=ttyS0\" -debugcon file:debug.log -global isa-debugcon.iobase=0x402"
fi

${QEMU} -kernel \
    ${KERNEL} \
    -cpu  max \
    -machine ${MACHINE} \
    -s   \
    -smp 4 \
    -m 8192m \
    -initrd ${INITRD} \
    -object rng-random,filename=/dev/urandom,id=rng0 \
    -device virtio-rng-pci,rng=rng0 \
    -device virtio-net-pci,netdev=n1 \
    -netdev user,id=n1,hostfwd=tcp:127.0.0.1:17010-:17010,net=192.168.1.0/24,host=192.168.1.1 \
    -serial mon:stdio \
    -fsdev local,security_model=passthrough,id=fsdev0,path=/tmp \
    -device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare \
    ${EXTRA} \
    -nographic