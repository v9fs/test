/*
 * Minimal 9p mount helper for diod sharness under ACCESS_SINGLE.
 * util-linux mount(8) post-checks as euid 0 and fails when access=<uid>.
 * This calls mount(2) directly with no post-check.
 *
 * If options contain access=<uid>, setfsuid to that uid before mount so the
 * kernel session matches the ACCESS_SINGLE user (mounter may be root via sudo).
 *
 * Usage: v9fs-mount-9p [-n] -t 9p -o OPTS SOURCE MNT
 *   -n is accepted and ignored (compatibility with sharness mountcmd).
 */

#define _GNU_SOURCE
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/mount.h>
#include <sys/types.h>

/* setfsuid(2) is Linux-only; declare if headers omit it. */
extern int setfsuid(uid_t fsuid);

static void
usage(const char *prog)
{
	fprintf(stderr,
		"usage: %s [-n] -t 9p -o OPTS SOURCE MNT\n", prog);
	exit(2);
}

static uid_t
parse_access_uid(const char *opts)
{
	const char *p = opts;

	while (p && *p) {
		if (!strncmp(p, "access=", 7)) {
			p += 7;
			if (*p >= '0' && *p <= '9')
				return (uid_t)strtoul(p, NULL, 10);
			return (uid_t)-1;
		}
		p = strchr(p, ',');
		if (p)
			p++;
	}
	return (uid_t)-1;
}

int
main(int argc, char **argv)
{
	const char *opts = NULL;
	const char *source = NULL;
	const char *target = NULL;
	unsigned long flags = 0;
	uid_t access_uid;
	int i;

	for (i = 1; i < argc; i++) {
		if (!strcmp(argv[i], "-n"))
			continue;
		if (!strcmp(argv[i], "-t") || !strncmp(argv[i], "-t", 2)) {
			const char *fstype = argv[i][2] ? argv[i] + 2 : NULL;
			if (!fstype) {
				if (++i >= argc)
					usage(argv[0]);
				fstype = argv[i];
			}
			if (strcmp(fstype, "9p") != 0)
				usage(argv[0]);
			continue;
		}
		if (!strcmp(argv[i], "-o") || !strncmp(argv[i], "-o", 2)) {
			opts = argv[i][2] ? argv[i] + 2 : NULL;
			if (!opts) {
				if (++i >= argc)
					usage(argv[0]);
				opts = argv[i];
			}
			continue;
		}
		if (!source)
			source = argv[i];
		else if (!target)
			target = argv[i];
		else
			usage(argv[0]);
	}

	if (!opts || !source || !target)
		usage(argv[0]);

	if (geteuid() != 0) {
		fprintf(stderr, "%s: must run as root (use sudo)\n", argv[0]);
		return 1;
	}

	access_uid = parse_access_uid(opts);
	if (access_uid != (uid_t)-1) {
		/* Keep CAP_SYS_ADMIN as root euid; match ACCESS_SINGLE for VFS.
		 * setfsuid returns the previous fsuid (not -1) even on success.
		 */
		setfsuid(access_uid);
		if ((uid_t)setfsuid(access_uid) != access_uid) {
			fprintf(stderr, "%s: setfsuid(%u) did not stick\n",
				argv[0], (unsigned)access_uid);
			return 1;
		}
	}

	if (mount(source, target, "9p", flags, opts) < 0) {
		fprintf(stderr, "%s: mount %s -> %s (%s): %s\n",
			argv[0], source, target, opts, strerror(errno));
		return 1;
	}

	return 0;
}
