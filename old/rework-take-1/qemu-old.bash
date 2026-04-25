#!/bin/bash

# ^a+x to terminate

export ARCH=${ARCH:-`uname -m`}
export KERNELBUILD=${KERNELBUILD:-"/workspaces/linux/.build-v6.5-rc1/"}
export INITRD=${INITRD:-"/home/v9fs-test/initrd.cpio"}
export LOG=${QEMULOG:-"/home/v9fs-test/qemu.log"}
export PIDFILE=${PIDFILE:-"/home/v9fs-test/qemu.pid"}

if test -f "${PIDFILE}"; then
    kill `cat ${PIDFILE}`
fi

if [ $ARCH == "aarch64" ]
then
    export QEMU="qemu-system-aarch64"
    export KERNEL="${KERNELBUILD}/arch/arm64/boot/Image"
    export MACHINE=virt
    export APPEND="earlycon console=ttyAMA0"
    export EXTRA=""
elif [ $ARCH == "x86_64" ]
then
    export QEMU="qemu-system-x86_64"
    export KERNEL="${KERNELBUILD}/arch/x86_64/boot/bzImage"
    export MACHINE=q35
    export APPEND="console=ttyS0"
    export EXTRA="-debugcon file:debug.log -global isa-debugcon.iobase=0x402"
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
    -serial file:${LOG} \
    -fsdev local,security_model=passthrough,id=fsdev0,path=/ \
    -device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare \
    -append "${APPEND}" \
    ${EXTRA} \
    -daemonize -display none -pidfile ${PIDFILE}

