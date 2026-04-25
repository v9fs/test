# UROOT.md

Lookaside notes for how **u-root init** behaves in the `v9fs/docker` initrd we boot in this repo.

Per `AGENTS.md`, this is based on **implementation evidence**, not on secondary docs.

## What the `v9fs/docker` initrd actually contains

From inspecting `/home/v9fs-test/initrd.cpio` inside the `ghcr.io/v9fs/docker:latest` image:

- `init` is a **symlink** to `bbin/cpud`
- `bbin/cpud`, `bbin/gosh`, and `bbin/init` are **symlinks** to `bb`
- `bbin/bb` is the big u-root “busybox” ELF containing applets (including `init`)
- `bin/sh` and `bin/defaultsh` are **symlinks** to `../bbin/gosh`
- there is **no** `bin/mount`, `bin/sed`, etc as standalone files; those operations must come from u-root applets (usually invoked via `/bbin/bb <applet> ...`)

This is why any init/uinit script we provide must avoid assuming a traditional userspace.

## How u-root decides what to run after `/init`

The u-root `init` implementation (upstream) tries executables in order:

- `/inito` (original init, if present)
- `/bbin/uinit`
- `/bin/uinit`
- `/buildbin/uinit`
- `/bin/defaultsh`
- `/bin/sh`

Source of truth:

- u-root `init` linux flow: `cmds/core/init/init_linux.go`
  - `osInitGo()` builds the command list above.
  - `cmdline.GetUinitArgs()` reads `uroot.uinitargs`.

## Kernel command-line flags u-root reads

u-root parses `/proc/cmdline` and provides helpers for specific keys:

- **`uroot.uinitargs`**: a shell-lexed string turned into argv for the `uinit` program.
  - Implementation: `pkg/cmdline.(*CmdLine).GetUinitArgs()` calls `shlex.Argv(uinitargs)`.
- **`uroot.initflags`**: a string parsed as a flag-map (used for init-time options like `systemd`).
  - Implementation: `pkg/cmdline.(*CmdLine).GetInitFlagMap()`.

Source of truth:

- `pkg/cmdline/cmdline.go` (functions `GetUinitArgs`, `GetInitFlagMap`, parsing rules)

## How we hook guest tests into this

We patch the base initrd to include an executable **`/bin/uinit`** that:

- uses `/bbin/bb` applets for `mount`, `sync`, `poweroff`, etc
- mounts the QEMU 9p export (`hostshare`) at `/mnt/9`
- runs `/mnt/9/test/scripts/v9fs-guest-run <tests>`
- syncs and powers off

This avoids rebuilding u-root and avoids relying on external tools inside the initrd.

