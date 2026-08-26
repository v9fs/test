# v9fs test harness

Test code and GitHub Actions for exercising the Linux **9p (v9fs)** client.

Kernel source under test is the git **mirror** [v9fs/linux](https://github.com/v9fs/linux). That repo is mirror-only: **no CI workflows there** ([#15](https://github.com/v9fs/test/issues/15)). All regression orchestration lives in **this** repository.

Prior harness snapshot (not used by CI): tag `rework-take-1` / `old/rework-take-1/`.

## How tests run

Guest-direct: QEMU arm64 + virtio-9p export of the container root, initrd mounts `hostshare`, then a Debian chroot runs the suite **inside the guest** (no SSH).

```bash
docker pull ghcr.io/v9fs/docker:latest
# Place arm64 Image at ./kernel/.build/arch/arm64/boot/Image
# (or: gh release download kernel-latest -p Image -D kernel/.build/arch/arm64/boot)
make docker-smoke
```

Logs land under `./logs/<timestamp>/` (`qemu.log`, `guest.log`, `guest.exitcode`).

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

Harness matrix suites: `smoke`, `fsx`, `postmark`, `dbench`, `diod-regression`, `qemu-9p2000.L`.

## GitHub Actions

Kernel **build** and **test** are separate. Images are GitHub Release assets (`Image` on a `kernel-*` tag). GitHub-hosted runners (`ubuntu-24.04-arm` for build/test, `ubuntu-latest` for sync/report).

| Workflow | File | When |
| --- | --- | --- |
| **Sync torvalds/linux** | `.github/workflows/sync-torvalds-linux.yml` | Every 6h + manual. Fast-forwards `v9fs/linux` `upstream`, tracks new **v6+** tags, and can `gh workflow run` publish for the newest tag (`kernel-<tag>` + `kernel-latest`). |
| **Publish Linux kernel** | `.github/workflows/linux-kernel-publish.yml` | Manual `workflow_dispatch`, or `gh workflow run` from sync. Optional `repository_dispatch` (`publish-kernel-image`) for emergencies — **not** fired from `v9fs/linux`. Builds arm64 `Image` with 9p options enabled. |
| **Harness CI** | `.github/workflows/ci.yml` | Push, manual, or `workflow_run` after a successful publish. Downloads `kernel-latest` by default. |

There are no `demand.yml` or `nightly.yml` workflows. Those names were from the take-1 harness and only existed as a snapshot under `old/rework-take-1/` (removed).

Dashboard: wiki [Regression-Dashboard](https://github.com/v9fs/test/wiki/Regression-Dashboard). Per-run `results.json` / `diff-report.md` attach to the `kernel-latest` release when `V9FS_LINUX_SYNC_TOKEN` is set.

### Kernel Images

| Release tag | Meaning |
| --- | --- |
| `kernel-latest` | Floating tip (newest published v6+ tag Image) |
| `kernel-v*` | Image for that kernel tag |
| `kernel-main` | `v9fs/linux` `upstream` (when published) |

Example: `https://github.com/v9fs/test/releases/download/kernel-latest/Image`

### Secrets

- `V9FS_LINUX_SYNC_TOKEN` — Contents write on `v9fs/linux`, Actions + Contents on `v9fs/test` (sync, publish chaining, wiki, attach reports).

Do **not** add `.github` workflows to `v9fs/linux`.

## Repo hygiene

- Active work: `main` (via PRs). Keep `CHANGES.md` and `TODO.md` updated.
- Do not commit `logs/`, `kernel/`, `tmp/`, generated initrds.
- Guest-direct only. SSH/`cpu` helpers under `old/rework-take-1/` are unsupported.
