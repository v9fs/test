## TODO

- Extend smoke test into a small suite (create/rename/unlink, fsync, directory traversal, large file IO).
- Add benchmark stages (fsx, postmark, dbench) to guest-direct CI.
- Decide whether to adopt a u-root/u-root+cpu initramfs for richer tooling distribution.
- Wire `v9fs/linux` to trigger `repository_dispatch` into `linux-kernel-publish.yml`.

## TODO

- Decide whether to keep `ubuntu-latest` runners or switch back to self-hosted for KVM acceleration.
- Remove or clearly fence legacy SSH-based helpers (`test.bash`, `scripts/cpu`) if they are no longer part of the supported workflow.