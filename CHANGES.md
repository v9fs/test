## Unreleased

- Start `rework` branch workflow and add baseline project docs (`README.md`, `CHANGES.md`, `TODO.md`).
- Add Docker + QEMU environment for local macOS runs and align GitHub Actions to use it.
- Run the suite **inside the QEMU guest** via initrd cmdline flags (`v9fs.run=1`, `v9fs.tests`, …) and a small guest runner (`scripts/v9fs-guest-run`), avoiding SSH/host port forwarding.
- Stabilize 9p exports for guest tests by bind-mounting the workspace/kernel/tmp/testbins under `/workspaces/share` (`scripts/v9fs-run-tests`).
- Give nightly/on-demand log artifacts **unique names** so parallel jobs do not collide on `actions/upload-artifact`.
- Ignore common local build outputs (`kernel/`, `tmp/`, generated initrd/pid files) in `.gitignore`.
- **CI workflow** (`.github/workflows/demand.yml`): run on **every `push`** as well as **manual** `workflow_dispatch`; default kernel checkout on push is `v9fs/linux` @ `ericvh/devel` (that repo’s default branch; there is no `master`) (manual runs still use the form defaults, e.g. `ericvh/for-next`).
- **Fix Actions**: align kernel `ref` with `v9fs/linux` (use `ericvh/devel` instead of non-existent `master` in CI and nightly checkouts).

