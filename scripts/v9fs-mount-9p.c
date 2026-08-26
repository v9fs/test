/*
 * Minimal 9p mount helper for diod sharness under ACCESS_SINGLE.
 * util-linux mount(8) post-checks as euid 0 and fails when access=<uid>.
 * This calls mount(2) directly with no post-check.
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

static void
usage(const char *prog)
{
	fprintf(stderr,
		"usage: %s [-n] -t 9p -o OPTS SOURCE MNT\n", prog);
	exit(2);
}

int
main(int argc, char **argv)
{
	const char *opts = NULL;
	const char *source = NULL;
	const char *target = NULL;
	unsigned long flags = 0;
	int i;

	for (i = 1; i < argc; i++) {
		if (!strcmp(argv[i], "-n"))
			continue;
		if (!strcmp(argv[i], "-t")) {
			if (++i >= argc || strcmp(argv[i], "9p") != 0)
				usage(argv[0]);
			continue;
		}
		if (!strcmp(argv[i], "-o")) {
			if (++i >= argc)
				usage(argv[0]);
			opts = argv[i];
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
		fprintf(stderr, "%s: must run with CAP_SYS_ADMIN (use sudo)\n",
			argv[0]);
		return 1;
	}

	if (mount(source, target, "9p", flags, opts) < 0) {
		fprintf(stderr, "%s: mount %s -> %s (%s): %s\n",
			argv[0], source, target, opts, strerror(errno));
		return 1;
	}

	return 0;
}
