# v9fs test harness (clean-slate)

This branch is being reworked from a clean slate.

The previous implementation snapshot is preserved at:

- Git tag: `rework-take-1`
- Directory: `old/rework-take-1/`

## Current rebuild (take 2)

This repo now contains a **minimal 9p client smoke test harness**:

- QEMU runs an **arm64** Linux kernel `Image`
- QEMU exports a host directory via **virtio-9p**
- An initrd runs the smoke test **inside the guest** (no SSH)
- The test exercises basic filesystem operations on the 9p mount

### Local smoke run (Docker + QEMU)

1) Build the image:

```bash
docker pull ghcr.io/v9fs/docker:latest
```

2) Put a kernel `Image` at `./kernel/.build/arch/arm64/boot/Image`

3) Run the smoke test:

```bash
make docker-smoke
```

Logs land under `./logs/<timestamp>/` (QEMU serial is `qemu.log`; guest writes `guest.log` + `guest.exitcode`).

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

CI uses the same Docker + QEMU flow as local development, but **kernel builds are
published separately** from the harness tests:

1. A dedicated workflow builds `v9fs/linux` and publishes the arm64 `Image` to
   **GitHub Releases** (and GHCR).
2. The harness workflows download that published `Image` into `kernel/.build/arch/...`
   and run `v9fs-run-tests ...` with `--privileged` so the harness can bind-mount a
   stable 9p export root (`/workspaces/share`).

### Workflows


| Workflow | File | When it runs |
| -------- | ---- | ------------ |
| **Publish Linux kernel** | `.github/workflows/linux-kernel-publish.yml` | **`repository_dispatch`** from `v9fs/linux` (recommended) or **`workflow_dispatch`** here. Builds arm64 `Image`, uploads it to a release tag you choose (`kernel-main`, `kernel-nightly`, `kernel-<version>`, …), and pushes a GHCR bundle tagged by the **linux commit SHA** plus your release tag. |
| **CI (push and manual)** | `.github/workflows/demand.yml` | On **every push** (all branches), **manual** dispatch, or **`workflow_call`**. Downloads `Image` from the **`kernel-main`** release by default (override via `kernel_release`). |
| **Mainline** | `.github/workflows/nightly.yml` | **Daily** schedule + **manual** dispatch. Downloads `Image` from **`kernel-nightly`** by default (override via `kernel_release`). |

Because GitHub Actions cannot natively “watch” another repository’s pushes, the
`v9fs/linux` repo should call `repository_dispatch` on `v9fs/test` when branches change
(see the header comment in `linux-kernel-publish.yml` for an example payload).

### Kernel images as packages (GHCR)

Published kernels are also pushed to GitHub Packages (GHCR) as an OCI artifact:

- **Package**: `ghcr.io/v9fs/v9fs-test-kernel`
- **Tags**:
  - `linux-<kernel_commit_sha>` (immutable)
  - The **release tag** you passed (e.g. `kernel-main`, `kernel-nightly`, `kernel-6.12.0`)

```bash
oras pull ghcr.io/v9fs/v9fs-test-kernel:linux-<sha> -o .
tar -tzf kernel-image.tar.gz | head
```

### Kernel images as direct downloads (GitHub Releases)

The publish workflow uploads the **arm64** kernel `Image` as a stable release asset:

- **Rolling mainline**: `https://github.com/v9fs/test/releases/download/kernel-main/Image`
- **Rolling nightly**: `https://github.com/v9fs/test/releases/download/kernel-nightly/Image`
- **Versioned** (example): `https://github.com/v9fs/test/releases/download/kernel-6.12.0/Image`


Log artifact names (avoid collisions when jobs run in parallel):

- CI manual/push: `test-results-ci`, `test-results-latency`
- Nightly: `test-results-regression`, `test-results-latency`

