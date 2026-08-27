#!/usr/bin/env python3
"""Clean text Layer A (invisible Unicode / homoglyph spaces)."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from common import eprint, read_text_input, write_text_output  # noqa: E402
from text_unicode import clean_text  # noqa: E402


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("path", nargs="?", default="-")
    p.add_argument("-o", "--output")
    p.add_argument("--stats", action="store_true")
    p.add_argument("--json", action="store_true")
    p.add_argument("--nfkc", action="store_true")
    p.add_argument("--aggressive-homoglyphs", action="store_true")
    p.add_argument("--strip-emoji-glue", action="store_true")
    p.add_argument("--force-text", action="store_true")
    args = p.parse_args()
    text = read_text_input(args.path, allow_binary=args.force_text)
    cleaned, stats = clean_text(
        text,
        nfkc=args.nfkc,
        aggressive_homoglyphs=args.aggressive_homoglyphs,
        strip_emoji_glue=args.strip_emoji_glue,
    )
    write_text_output(cleaned, args.output)
    if args.json:
        eprint(json.dumps(stats, indent=2, ensure_ascii=False))
    elif args.stats:
        eprint(f"removed={stats['removed_count']} replaced={stats['replaced_count']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
