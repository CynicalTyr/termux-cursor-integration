#!/usr/bin/env python3
"""Inspect text for Layer A (invisible Unicode / homoglyph) carriers."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from common import emit_json, read_text_input  # noqa: E402
from text_unicode import human_report, inspect_text  # noqa: E402


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("path", nargs="?", default="-", help="Text file, or - for stdin")
    p.add_argument("--json", action="store_true")
    p.add_argument("--aggressive", action="store_true")
    p.add_argument("--strip-emoji-glue", action="store_true")
    p.add_argument("--force-text", action="store_true")
    args = p.parse_args()
    text = read_text_input(args.path, allow_binary=args.force_text)
    report = inspect_text(
        text, aggressive=args.aggressive, strip_emoji_glue=args.strip_emoji_glue
    )
    if args.json:
        emit_json(report.to_dict())
    else:
        print(human_report(report))
    return 0 if report.suspicious_total == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
