## Unreleased

- Clean-slate rework started; prior implementation preserved under `old/rework-take-1/` (tag `rework-take-1`).
- Rebuild harness (take 2): minimal Docker+QEMU guest-direct smoke test that mounts a 9p export and validates basic filesystem operations.
- Add GitHub Actions:
  - `linux-kernel-publish.yml` to build/publish arm64 `Image` as a release asset
  - `ci.yml` to download `Image` and run the smoke harness in CI

