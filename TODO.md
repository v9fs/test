## TODO

- Enable weekly cron on `kconfig-compile.yml` once the compile flavors stay green (#8).
- Expand `fstest` from the mkdir/open/unlink/rename subset to full pjdfstest with a real `fstest/xfail.txt` (#7).
- Add `diod-9p2000` / `diod-9p2000.u` matrix cells once qemu legacy dialects are boringly green (#10).
- Wiki dashboard: history over time + dbench MB/s column from `metrics.json` (#2, #11).
- Automated git bisect on first fail vs last pass (#2).
- linux-next mirror/publish (optional; not on `v9fs/linux` today) (#5).
- Shrink diod XFAIL: `t0011-v9fs-allsquash`, `t0013-v9fs-acl` (follow-up to closed #9).
- u-root/cpu for richer guest tooling (optional).
