#!/usr/bin/env python3

# encoding: utf-8

"""
Prepares release notes upon release
"""

import os

from packaging.version import parse
from enum import StrEnum
from pathlib import Path

TAG = os.environ["TAG"]


class MiscHeader(StrEnum):
    UNREL = "### Unreleased"


class Header(StrEnum):
    ADDED = "### Added"
    CHANGED = "### Changed"
    FIXED = "### Fixed"
    REMOVED = "### Removed"

    def addto(self, s: str) -> str:
        return self + s

    @staticmethod
    def match(ln: str):
        for h in Header:
            if ln.startswith(h.value):
                return h
        return None


def open_changelog() -> str:
    in_curr_sel = False
    curr_notes: list[str] = []
    chglog = Path("./../CHANGELOG.md")
    with chglog.open() as chg:
        for ln in chg:
            if ln.startswith("## "):
                if ln.startswith("## Unreleased"):
                    continue
                if ln.startswith(f"## [{TAG}]"):
                    in_curr_sel = True
                    continue
                break
            if in_curr_sel:
                if h := Header.match(ln):
                    ln = h.addto(":*\n")
                curr_notes.append(ln)
    assert curr_notes
    return "## What's new\n\n" + "".join(curr_notes).strip() + "\n"


def read_commits() -> str:
    new_v = parse(TAG)
    all_t = os.popen("git tag -l --sort=-v:refname").read().split("\n")
    last_t: str | None = None
    for t in all_t:
        if not t.strip():
            continue
        v = parse(t)
        if new_v.pre is None and v.pre is not None:
            continue
        if v < new_v:
            last_t = t
            break
    if last_t is not None:
        cmts = os.popen(f"git log {last_t}..{TAG} --oneline --first-parent").read()
    else:
        cmts = os.popen("git log --oneline --first-parents").read()
    return "## Commits\n\n" + cmts


def main():
    print(open_changelog())
    print(read_commits())


if __name__ == "__main__":
    main()
