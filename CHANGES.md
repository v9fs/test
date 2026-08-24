## Unreleased

- Add `sync-torvalds-linux.yml`: cron/`workflow_dispatch` mirrors `torvalds/linux` `master` → `v9fs/linux` `upstream` and newly seen `v*` tags from `v9fs/test` only (no CI files in the kernel tree; see #15). New tags can trigger `linux-kernel-publish.yml` via `gh workflow run` using `V9FS_LINUX_SYNC_TOKEN`.
- Clean-slate rework started; prior implementation preserved under `old/rework-take-1/` (tag `rework-take-1`).
- Rebuild harness (take 2): minimal Docker+QEMU guest-direct smoke test that mounts a 9p export and validates basic filesystem operations.
- Add GitHub Actions:
  - `linux-kernel-publish.yml` to build/publish arm64 `Image` as a release asset
  - `ci.yml` to download `Image` and run the smoke harness in CI

