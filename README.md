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
docker run --rm --privileged \
  -e KERNELBUILD=/workspaces/kernel/.build \
  -v "$PWD:/home/v9fs-test/test" \
  -v "$PWD/kernel:/workspaces/kernel" \
  -v "$PWD/tmp:/workspaces/tmp" \
  -w /home/v9fs-test/test \
  v9fs-test-env:local \
  bash -lc "v9fs-run-tests short ci"
```

Logs are written under `logs/`.
