#!/usr/bin/env bash
set -euo pipefail

ARCH="${ARCH:-$(uname -m)}"
KERNELBUILD="${KERNELBUILD:-/workspaces/kernel/.build}"
INITRD="${INITRD:-/home/v9fs-test/initrd.cpio}"
LOG="${QEMULOG:-/home/v9fs-test/qemu.log}"
PIDFILE="${PIDFILE:-/home/v9fs-test/qemu.pid}"
FSDEV_PATH="${FSDEV_PATH:-/workspaces/share}"

if test -f "${PIDFILE}"; then
  kill "$(cat "${PIDFILE}")" 2>/dev/null || true
fi

if [ "${ARCH}" = "aarch64" ]; then
  QEMU="qemu-system-aarch64"
  KERNEL="${KERNELBUILD}/arch/arm64/boot/Image"
  MACHINE="virt"
  APPEND="earlycon console=ttyAMA0"
  QEMUCPU="${QEMUCPU:-cortex-a57}"
  EXTRA=""
else
  echo "Unsupported ARCH=${ARCH} (expected aarch64)"
  exit 2
fi

exec ${QEMU} \
  -kernel "${KERNEL}" \
  -cpu "${QEMUCPU}" \
  -machine "${MACHINE}" \
  -smp 4 \
  -m 4096m \
  -initrd "${INITRD}" \
  -object rng-random,filename=/dev/urandom,id=rng0 \
  -device virtio-rng-pci,rng=rng0 \
  -device virtio-net-pci,netdev=n1 \
  -netdev user,id=n1,hostfwd=tcp:127.0.0.1:17010-:17010 \
  -serial "file:${LOG}" \
  -fsdev "local,security_model=none,writeout=immediate,id=fsdev0,path=${FSDEV_PATH}" \
  -device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare \
  -append "${APPEND} ${EXTRA_APPEND:-}" \
  ${EXTRA} \
  -daemonize -display none -pidfile "${PIDFILE}"

