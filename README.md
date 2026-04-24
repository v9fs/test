# v9fs test harness

This repository contains **test code and scripts** for exercising the Linux **9p (v9fs)** filesystem.

The kernel source under test lives in the upstream repository:

- `https://github.com/v9fs/linux`

## What lives here

- **CI workflows**: automation to build/run tests against a chosen kernel revision
- **Test code**: focused repros and regression tests for v9fs behavior
- **Scripts**: helpers to run locally and/or in CI

## How we work in this repo

- **Development branch**: all active work happens on `rework`
- **Change log**: keep `CHANGES.md` updated for every change set
- **Work tracking**: keep `TODO.md` updated as items are added/removed

## Quick start

This repo intentionally does *not* vendor the kernel source. Most workflows/scripts will:

1. Fetch `github.com/v9fs/linux` (or a fork/branch you specify)
2. Build the kernel (or use a provided artifact)
3. Run the tests in this repository against that kernel

### Local (macOS) via Docker + QEMU

Clone the kernel repo beside this repo:

```bash
git clone https://github.com/v9fs/linux ../linux
```

Build the test environment image:

```bash
docker build -t v9fs-test-env:local .
```

Build the kernel once (and export it as a reusable artifact):

```bash
mkdir -p ./tmp ./kernel
docker run --rm --privileged \
  -v "$PWD:/home/v9fs-test/test" \
  -v "$PWD/../linux:/workspaces/linux" \
  -v "$PWD/kernel:/workspaces/kernel" \
  -v "$PWD/tmp:/workspaces/tmp" \
  -w /home/v9fs-test/test \
  v9fs-test-env:local \
  bash -lc "v9fs-build-kernel && v9fs-export-kernel /workspaces/linux /workspaces/linux/.build /workspaces/kernel"
```

Then run tests repeatedly without rebuilding the kernel:

```bash
mkdir -p ./tmp
docker run --rm --privileged \
  -e KERNELBUILD=/workspaces/kernel/.build \
  -v "$PWD:/home/v9fs-test/test" \
  -v "$PWD/kernel:/workspaces/kernel" \
  -v "$PWD/tmp:/workspaces/tmp" \
  -w /home/v9fs-test/test \
  v9fs-test-env:local \
  bash -lc "v9fs-run-tests short ci"
```

## How tests run (guest-direct)

`v9fs-run-tests` boots QEMU with an initrd that mounts the host-exported workspace
over **9p** and then runs the suite **inside the guest** (no SSH/port-forwarding).

The host-visible output is primarily the QEMU serial log:

- `logs/<timestamp>/qemu.log`

The guest mounts the repo at `/mnt/9/test` (see `scripts/v9fs-guest-run`).

## GitHub Actions

CI uses the same Docker + QEMU flow as local development:

1. Build the kernel in a container and upload `kernel-image`
2. Download that artifact into `kernel/.build/arch/...` for test jobs
3. Run `v9fs-run-tests ...` with `--privileged` so the harness can bind-mount a
   stable 9p export root (`/workspaces/share`)

Nightly uploads two log bundles with distinct artifact names:

- `test-results-regression`
- `test-results-latency`