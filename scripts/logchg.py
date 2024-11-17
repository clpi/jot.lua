#!/usr/bin/env python3

# encoding: utf-8

"""
Prepares changelog
"""

import os
from pathlib import Path
from datetime import datetime

TAG = os.environ["TAG"]
VER = TAG[1:]
CHG = Path("./../CHANGELOG.md")


def read_chglog() -> list[str]:
    result: list[str] = []
    with CHG.open() as cl:
        result = cl.readlines()
    return result


def write_chglog(lns: list[str]):
    with CHG.open("w") as cl:
        cl.writelines(lns)


def main():
    ins_i = -1
    lns = read_chglog()
    for i in range(len(lns)):
        ln = lns[i]
        if ln.startswith("## Unreleased"):
            ins_i = i + 1
        elif ln.startswith(f"## [v{VER}]"):
            print("CHANGELOG already updated")
            return
        elif ln.startswith("## [v"):
            break
    if ins_i < 0:
      raise RuntimeError("Couldn't find unreleased section")
    lns.insert(ins_i, "\n")
    lns.insert(ins_i + 1,
              f"## [v{VERSION}](https://github.com/clpi/word.lua/releases/tag/v{VERSION}) - "
              f"{datetime.now().strftime('%Y-%m-%d')}\n",

               )
    write_chglog(lns)
        # print(f"Readying CHANGELOG.md: {TAG}")



if __name__ == "__main__":
    main()
