FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    cpio \
    curl \
    file \
    git \
    make \
    gcc \
    libc6-dev \
    python3 \
    qemu-system-arm \
    qemu-utils \
    rsync \
    time \
    util-linux \
    busybox-static \
  && rm -rf /var/lib/apt/lists/*

# Stable user/home matching harness assumptions.
RUN useradd -m -s /bin/bash v9fs-test \
  && mkdir -p /workspaces /workspaces/tmp \
  && chown -R v9fs-test:v9fs-test /home/v9fs-test /workspaces

COPY scripts/ /usr/local/bin/
RUN chmod +x /usr/local/bin/*

WORKDIR /home/v9fs-test/test

ENTRYPOINT ["/usr/local/bin/v9fs-entrypoint"]

