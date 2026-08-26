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
