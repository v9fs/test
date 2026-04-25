## Unreleased

- Start `rework` branch workflow and add baseline project docs (`README.md`, `CHANGES.md`, `TODO.md`).
- Add Docker + QEMU environment for local macOS runs and align GitHub Actions to use it.
- Run the suite **inside the QEMU guest** via initrd cmdline flags (`v9fs.run=1`, `v9fs.tests`, …) and a small guest runner (`scripts/v9fs-guest-run`), avoiding SSH/host port forwarding.
- Stabilize 9p exports for guest tests by bind-mounting the workspace/kernel/tmp/testbins under `/workspaces/share` (`scripts/v9fs-run-tests`).
- Give nightly/on-demand log artifacts **unique names** so parallel jobs do not collide on `actions/upload-artifact`.
- Ignore common local build outputs (`kernel/`, `tmp/`, generated initrd/pid files) in `.gitignore`.
- **Split workflows**: add `.github/workflows/linux-kernel-publish.yml` to build/publish **`v9fs/linux`** arm64 `Image` on **`repository_dispatch`** (from linux) or **`workflow_dispatch`**, publishing to **GitHub Releases** (`kernel-main`, `kernel-nightly`, `kernel-<version>`, …) plus **GHCR** (`linux-<sha>` + release tag).
- **Harness CI** (`.github/workflows/demand.yml`, `.github/workflows/nightly.yml`) no longer builds the kernel; they **`gh release download`** the published `Image` (defaults: `kernel-main` / `kernel-nightly`) and run QEMU tests on **ARM64** runners.

