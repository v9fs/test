#!/usr/bin/env python3
"""Load expected/legacy.txt: known-legacy XFAIL vs unexpected regression."""

from __future__ import annotations

import argparse
import json
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Dict, List, Optional, Tuple

KINDS = frozenset({"bug", "unsupported"})
Key = Tuple[str, Optional[str], Optional[str]]


@dataclass(frozen=True)
class Expected:
    suite: str
    server: Optional[str]
    cache: Optional[str]
    kind: str
    issue: str
    note: str

    @property
    def suite_level(self) -> bool:
        return self.server is None and self.cache is None


def repo_root() -> Path:
    return Path(__file__).resolve().parent.parent


def legacy_path(root: Optional[Path] = None) -> Path:
    return (root or repo_root()) / "expected" / "legacy.txt"


def load(path: Optional[Path] = None) -> List[Expected]:
    p = path or legacy_path()
    if not p.is_file():
        return []
    out: List[Expected] = []
    for lineno, raw in enumerate(p.read_text(encoding="utf-8").splitlines(), 1):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split()
        if len(parts) < 4:
            raise ValueError(f"{p}:{lineno}: expected at least 4 fields: {raw}")
        tag = parts[0]
        if tag == "suite":
            if len(parts) < 4:
                raise ValueError(f"{p}:{lineno}: suite <name> <kind> <issue> [note]")
            name, kind, issue = parts[1], parts[2], parts[3]
            note = " ".join(parts[4:])
            server = cache = None
        elif tag == "cell":
            if len(parts) < 6:
                raise ValueError(
                    f"{p}:{lineno}: cell <suite> <server> <cache> <kind> <issue> [note]"
                )
            name, server, cache, kind, issue = (
                parts[1],
                parts[2],
                parts[3],
                parts[4],
                parts[5],
            )
            note = " ".join(parts[6:])
        else:
            raise ValueError(f"{p}:{lineno}: unknown tag {tag!r} (suite|cell)")
        if kind not in KINDS:
            raise ValueError(f"{p}:{lineno}: kind must be bug|unsupported, not {kind!r}")
        out.append(
            Expected(
                suite=name,
                server=server,
                cache=cache,
                kind=kind,
                issue=issue,
                note=note,
            )
        )
    return out


def lookup_cell(
    entries: List[Expected], suite: str, server: str, cache: str
) -> Optional[Expected]:
    for e in entries:
        if e.suite == suite and e.server == server and e.cache == cache:
            return e
    for e in entries:
        if e.suite == suite and e.suite_level:
            return e
    return None


def suite_entries(entries: List[Expected], suite: str) -> List[Expected]:
    return [e for e in entries if e.suite == suite]


def apply_expected(
    verdict: str, exp: Optional[Expected]
) -> Dict[str, object]:
    """Attach catalog metadata and remap FAIL→XFAIL / PASS+bug→XPASS."""
    extra: Dict[str, object] = {
        "issue": exp.issue if exp else "",
        "legacy_kind": exp.kind if exp else "",
        "legacy": bool(exp),
    }
    if exp is None:
        return extra
    if verdict == "FAIL":
        extra["verdict"] = "XFAIL"
        extra["required"] = False
    elif verdict == "PASS" and exp.kind == "bug":
        extra["verdict"] = "XPASS"
        extra["required"] = False
        extra["note_prefix"] = f"catalog expected fail ({exp.issue}); "
    else:
        extra["required"] = False
    return extra


def cmd_lookup(args: argparse.Namespace) -> int:
    entries = load()
    exp = lookup_cell(entries, args.suite, args.server, args.cache)
    print(json.dumps(asdict(exp) if exp else None, indent=2))
    return 0 if exp else 1


def cmd_suites(_args: argparse.Namespace) -> int:
    entries = load()
    by: Dict[str, List[dict]] = {}
    for e in entries:
        by.setdefault(e.suite, []).append(asdict(e))
    print(json.dumps(by, indent=2))
    return 0


def main(argv: Optional[List[str]] = None) -> int:
    p = argparse.ArgumentParser(description=__doc__)
    sub = p.add_subparsers(dest="cmd", required=True)
    lk = sub.add_parser("lookup", help="look up one cell")
    lk.add_argument("--suite", required=True)
    lk.add_argument("--server", required=True)
    lk.add_argument("--cache", required=True)
    lk.set_defaults(func=cmd_lookup)
    su = sub.add_parser("suites", help="dump catalog grouped by suite")
    su.set_defaults(func=cmd_suites)
    args = p.parse_args(argv)
    return int(args.func(args))


if __name__ == "__main__":
    raise SystemExit(main())
