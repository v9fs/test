## Unreleased

- Start diod sharness servers via `unixsocketroot` and fix guest hostname/sudo `!fqdn` so non-root `v9fs` mounts are reliable.
- Run diod sharness as non-root user `v9fs` (so ACCESS_SINGLE / `--runas` negatives work); per-test `timeout` via automake `LOG_COMPILER` instead of one outer suite timeout.
- Refresh diod XFAIL baseline for tip `v7.2` (access/umount residuals); tee `make check` so timeout still yields a parseable suite log for XFAIL eval.
- Build-in `NET_9P_FD` (and `UNIX`) on published Images so diod-regression `trans=unix` mounts work; arm64 defconfig left FD as `=m` while virtio was forced `=y`.
- Fix `v9fs-ci-report` heredoc quoting so tip/wiki markdown renders correctly.
- Harness CI: default to `kernel-latest`, run on successful kernel publish (`workflow_run`), emit `results.json`/diff, update wiki `Regression-Dashboard`, and attach results to `kernel-latest`.
- Add `scripts/v9fs-ci-report` and `scripts/v9fs-newest-v6-tag` (kernel-aware tip ordering: `v7.2` > `v7.2-rc7`).
- Tag policy: track only new **v6+** tags; build/publish/test only the **single newest** v6+ tag; also refresh floating **`kernel-latest`** release alias alongside `kernel-<tag>`.
- Fix sync workflow: ensure fork `master` exists before `gh repo sync`, then FF canonical `upstream` (merge-upstream 404'd without `master`).
- Revise `sync-torvalds-linux.yml` to use `gh repo sync` for `master` objects, fast-forward canonical `upstream`, and sync only newly missing recent `v*` tags (no full torvalds tag mirror).
- Add `sync-torvalds-linux.yml`: cron/`workflow_dispatch` mirrors `torvalds/linux` `master` → `v9fs/linux` `upstream` and newly seen `v*` tags from `v9fs/test` only (no CI files in the kernel tree; see #15). New tags can trigger `linux-kernel-publish.yml` via `gh workflow run` using `V9FS_LINUX_SYNC_TOKEN`.
- Clean-slate rework started; prior implementation preserved under `old/rework-take-1/` (tag `rework-take-1`).
- Rebuild harness (take 2): minimal Docker+QEMU guest-direct smoke test that mounts a 9p export and validates basic filesystem operations.
- Add GitHub Actions:
  - `linux-kernel-publish.yml` to build/publish arm64 `Image` as a release asset
  - `ci.yml` to download `Image` and run the smoke harness in CI
