## TODO

- Configure/keep repo secret `V9FS_LINUX_SYNC_TOKEN` (Contents write on `v9fs/linux`, Actions + Contents on `v9fs/test` for publish chaining and wiki/`results.json` attach).
- Nightly/for-next/fixes Images and harness runs (#5). Mainline `upstream` SHA changes and new/missing newest v6+ tags now publish+test from sync (#6).
- QEMU serial / dmesg BUG+WARN scanning (#4): smoke + protocol suites enforce; grow `klog/allow.txt` before turning on fsx/dbench/diod.
- Legacy 9p2000 / 9p2000.u protocol cells (#10).
- pjdfstest / fstest (#7).
- Kconfig / cache-mode sweep (#8).
- Memory/ops metrics over time (#11).
- Dashboard history + optional bisection (#2).
- Shrink diod XFAIL: tip residuals cleared — t0011 ([test#31](https://github.com/v9fs/test/pull/31)), t0013 ([test#33](https://github.com/v9fs/test/pull/33)).
- u-root/cpu for richer guest tooling (optional).
