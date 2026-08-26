# v9fs test harness

Test code and GitHub Actions for exercising the Linux **9p (v9fs)** client.

Kernel source under test is the git **mirror** [v9fs/linux](https://github.com/v9fs/linux) (no CI workflows there; see [#15](https://github.com/v9fs/test/issues/15)). All regression orchestration lives in **this** repository.

Prior harness snapshot: tag `rework-take-1` / `old/rework-take-1/` (historical only).

## How tests run

Guest-direct: QEMU arm64 + virtio-9p export of the container root, initrd mounts `hostshare`, then a Debian chroot runs the suite **inside the guest** (no SSH).

```bash
docker pull ghcr.io/v9fs/docker:latest
# Place arm64 Image at ./kernel/.build/arch/arm64/boot/Image
# (or: gh release download kernel-latest -p Image -D kernel/.build/arch/arm64/boot)
make docker-smoke
```

Logs: `logs/<timestamp>/qemu.log`, `guest.log`, `guest.exitcode`, `dmesg.log`.

Other suites (same Docker + Image):

```bash
docker run --rm --privileged --user 0:0 \
  -e KERNELBUILD=/workspaces/kernel/.build \
  -v "$PWD:/home/v9fs-test/test" \
  -v "$PWD/kernel:/workspaces/kernel" \
  -v "$PWD/tmp:/workspaces/tmp" \
  -w /home/v9fs-test/test \
  ghcr.io/v9fs/docker:latest \
  bash -lc "./scripts/v9fs-run-tests smoke"
```

Suites: `smoke`, `fsx`, `postmark`, `dbench`, `diod-regression`, `fstest`, `qemu-9p2000`, `qemu-9p2000.u`, `qemu-9p2000.L`, `qemu-9p2000.L-none`, `diod-9p2000.L`.

### Issue #3: `tail -f` vs server-side append (standalone)

[v9fs/linux#3](https://github.com/v9fs/linux/issues/3): `tail -f` on a 9p file never sees data appended on the **server** (host export / diod backing store). This unit test is **not** on the CI matrix so it can be iterated on alone.

```bash
# No kernel, no Docker: proves inotify/stat/tail watchers work on a local file.
make tail-follow-selftest

# Already have a 9p mount? Watch the client path, append to the export:
./scripts/v9fs-tail-follow observe \
  --watched /mnt/9p/log --export /export/log --cache none --server diod

# Full virtio-9p repro (and diod inside the guest if packaged):
# needs arm64 Image at ./kernel/.build/arch/arm64/boot/Image
make docker-tail-follow
```

The report (`logs/tail-follow.report.json`) is a cache × method matrix (`inotify`, `fstat_size`, `fd_read`, `stat_size`, `tail`, `reopen`) so a kernel fix can be scored against the options in the issue (drop inotify so tail polls, getattr on open files, TTL revalidate, …). Each case includes a `note` that maps the pattern onto those options. `cache=loose` live-follow is XFAIL; `cache=none`/`mmap`/`readahead` live-follow is required and currently expected to FAIL on mainline (that is the #3 repro). Do not add this suite to `.github/workflows/ci.yml` until those required cells go green.

`make docker-tail-follow` boots extra virtio-9p channels (`tf-none`, `tf-readahead`, `tf-mmap`, `tf-loose`) so each cache mode is a distinct mount — `hostshare` is already `/` in the guest and cannot be remounted. `DOCKER=podman make docker-tail-follow` works when the docker socket is unavailable.

## GitHub Actions

Kernel **build** and **test** are separate. Images are GitHub Release assets (not GHCR).

| Workflow | File | When |
| --- | --- | --- |
| **Sync torvalds/linux** | `.github/workflows/sync-torvalds-linux.yml` | Every 6h + manual. Fast-forwards `v9fs/linux` `upstream`, tracks new **v6+** tags, publishes the newest tag as `kernel-<tag>` + `kernel-latest`. Also publishes maintainer refs when their SHA changed (`upstream`→`kernel-main`, `ericvh/for-next`→`kernel-for-next`, `fixes/next`→`kernel-fixes`). |
| **Publish Linux kernel** | `.github/workflows/linux-kernel-publish.yml` | Manual, `repository_dispatch`, or `gh workflow run` from sync. Builds arm64 `Image` on `ubuntu-24.04-arm` with 9p options enabled (`NET_9P_FD`, virtio, ACL, …). |
| **Harness CI** | `.github/workflows/ci.yml` | Push, manual, or `workflow_run` after a successful publish. Downloads `kernel-latest` by default and runs the suite matrix. |
| **Kconfig compile sweep** | `.github/workflows/kconfig-compile.yml` | Manual (weekly cron can be enabled later). Compile-only 9p kconfig flavors; no QEMU. |

Dashboard: wiki [Regression-Dashboard](https://github.com/v9fs/test/wiki/Regression-Dashboard). Per-run `results.json` / `diff-report.md` attach to the `kernel-latest` release when `V9FS_LINUX_SYNC_TOKEN` is set.

### Kernel Images

| Release tag | Meaning |
| --- | --- |
| `kernel-latest` | Floating tip (newest v6+ tag Image) |
| `kernel-v*` | Image for that kernel tag |
| `kernel-main` | `v9fs/linux` `upstream` (torvalds master) |
| `kernel-for-next` | `ericvh/for-next` |
| `kernel-fixes` | `fixes/next` |

Example: `https://github.com/v9fs/test/releases/download/kernel-latest/Image`

### Secrets

- `V9FS_LINUX_SYNC_TOKEN` — Contents write on `v9fs/linux`, Actions + Contents on `v9fs/test` (sync, publish chaining, wiki, attach reports).

Do **not** add `.github` workflows to `v9fs/linux`.

## Repo hygiene

- Active work: `main` (PRs). `CHANGES.md` / `TODO.md` for each change set.
- Do not commit `logs/`, `kernel/`, `tmp/`, generated initrds.
- Guest-direct only; `old/rework-take-1/` SSH/`cpu` helpers are unsupported.
