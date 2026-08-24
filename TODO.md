## TODO

- Extend smoke test into a small suite (create/rename/unlink, fsync, directory traversal, large file IO).
- Add benchmark stages (fsx, postmark, dbench) to guest-direct CI.
- Add a diod regression suite stage (guest-direct) to exercise the kernel v9fs client.
- Decide whether to adopt a u-root/u-root+cpu initramfs for richer tooling distribution.
- Configure repo/org secret `V9FS_LINUX_SYNC_TOKEN` (Contents write on `v9fs/linux`, Actions + Contents on `v9fs/test` for publish chaining and wiki/`results.json` attach).
- After Image publish, harness `workflow_run` builds tip report + wiki summary table (`Regression-Dashboard`).
- Retarget “linux pushes trigger test” work (#6) to sync/orchestrate from this repo.

## TODO

- Decide whether to keep `ubuntu-latest` runners or switch back to self-hosted for KVM acceleration.
- Remove or clearly fence legacy SSH-based helpers (`test.bash`, `scripts/cpu`) if they are no longer part of the supported workflow.
