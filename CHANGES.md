## Unreleased

- Start `rework` branch workflow and add baseline project docs (`README.md`, `CHANGES.md`, `TODO.md`).
- Add Docker + QEMU environment for local macOS runs and align GitHub Actions to use it.
- Run the suite **inside the QEMU guest** via initrd cmdline flags (`v9fs.run=1`, `v9fs.tests`, …) and a small guest runner (`scripts/v9fs-guest-run`), avoiding SSH/host port forwarding.
- Stabilize 9p exports for guest tests by bind-mounting the workspace/kernel/tmp/testbins under `/workspaces/share` (`scripts/v9fs-run-tests`).
- Give nightly/on-demand log artifacts **unique names** so parallel jobs do not collide on `actions/upload-artifact`.
- Ignore common local build outputs (`kernel/`, `tmp/`, generated initrd/pid files) in `.gitignore`.
- **CI workflow** (`.github/workflows/demand.yml`): run on **every `push`** as well as **manual** `workflow_dispatch`; kernel checkout defaults to **`v9fs/linux` @ `main`** (stable; manual dispatch can still override `ref`).
- **Fix Actions**: kernel `ref` pinned to **`main`** where defaults apply (push CI and nightly), avoiding volatile branches on `v9fs/linux`.
- Publish built kernel images to GitHub Packages (GHCR) as an OCI artifact (`ghcr.io/v9fs/v9fs-test-kernel`) tagged by commit SHA and `main`/`nightly`.

