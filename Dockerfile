FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    bc \
    bison \
    build-essential \
    ca-certificates \
    cpio \
    curl \
    file \
    flex \
    git \
    iproute2 \
    kmod \
    libelf-dev \
    libssl-dev \
    make \
    xfsprogs \
    openssh-client \
    python3 \
    qemu-system-arm \
    qemu-system-x86 \
    qemu-utils \
    rsync \
    time \
    util-linux \
    busybox-static \
    dropbear-bin \
    dbench \
    postmark \
    dwarves \
  && rm -rf /var/lib/apt/lists/*

# Build standalone `fsx` from FreeBSD source (works across Ubuntu arches).
RUN curl -fsSL https://raw.githubusercontent.com/freebsd/freebsd-src/main/tools/regression/fsx/fsx.c -o /tmp/fsx.c \
  && gcc -O2 -D_GNU_SOURCE -D_POSIX_C_SOURCE=200809L -include stdint.h -include time.h -Wall -Wextra /tmp/fsx.c -o /usr/local/bin/fsx \
  && rm -f /tmp/fsx.c

# Create a stable user/home matching existing scripts
RUN useradd -m -s /bin/bash v9fs-test \
  && mkdir -p /workspaces /workspaces/tmp \
  && mkdir -p /home/v9fs-test/.ssh \
  && chown -R v9fs-test:v9fs-test /home/v9fs-test /workspaces

# Provide a shared testbin layout compatible with existing scripts.
# These paths are reachable from the guest via 9p (mounted at /mnt/9).
RUN mkdir -p /home/v9fs-test/testbin/dbench /home/v9fs-test/testbin/postmark /home/v9fs-test/testbin/fsx \
  && cp -f /usr/bin/dbench /home/v9fs-test/testbin/dbench/dbench \
  && cp -f /usr/share/dbench/client.txt /home/v9fs-test/testbin/dbench/client.txt \
  && cp -f /usr/bin/postmark /home/v9fs-test/testbin/postmark/postmark \
  && cp -f /usr/local/bin/fsx /home/v9fs-test/testbin/fsx/fsx \
  && chown -R v9fs-test:v9fs-test /home/v9fs-test/testbin

COPY scripts/ /usr/local/bin/
RUN chmod +x /usr/local/bin/*

WORKDIR /home/v9fs-test/test

ENTRYPOINT ["/usr/local/bin/v9fs-entrypoint"]
