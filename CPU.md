# CPU.md

Lookaside notes for **u-root/cpu** (`cpu` + `cpud`) as it relates to this repo and the `v9fs/docker` initrd.

Per `AGENTS.md`, treat **source code** as the authority.

## What `cpud` is

`cpud` is the “daemon side” of a Plan9-inspired `cpu` session. It can run:

- **as PID 1** (init + daemon)
- **as a daemon** (listening server that forks per-session cpuds)
- **as a per-session “remote”** process

Source of truth:

- `u-root/cpu` `cmds/cpud/main_linux.go` and `cmds/cpud/cpuddoc.go`

## `cpud` flags (server mode)

From `cmds/cpud/main_linux.go` and `cmds/cpud/cpuddoc.go`:

- `-hk`: host key file (host key)
- `-pk`: public key file (default `key.pub`)
- `-sp`: listen port (default `17010`)
- `-net`: network (default `tcp`)
- `-d`: debug prints
- `-klog`: log to kernel log instead of stdout
- `-register` / `-registerTO`: optional controller registration
- `-sleepBeforeServing`: delay before serving (useful when running as init)

## `cpud` “remote” mode and argument rules

In remote mode (invoked as `cpud -remote ...`) the accepted flag set is intentionally smaller, and the program expects remaining args to be the command to run.

Source of truth:

- `cmds/cpud/main_linux.go` (`if len(os.Args)>1 && os.Args[1] == "-remote"...` and the custom FlagSet)

## Relevance to `v9fs/docker`

The `v9fs/docker` base initrd’s `/init` is a symlink to `bbin/cpud` (and `bbin/cpud` is an applet of the `bb` binary).

For this repo’s harness, we are **not** depending on `cpu/cpud` features to run tests yet; we only rely on the u-root init sequence and the availability of `/bbin/bb` applets to implement `/bin/uinit` and mount 9p.

