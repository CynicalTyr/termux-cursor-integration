"""Minimal helpers for Android remove-ai-watermarks text scripts."""

from __future__ import annotations

import json
import os
import sys
import tempfile
from pathlib import Path
from typing import Any

MAX_INPUT_BYTES = int(os.environ.get("WATERMARKS_MAX_INPUT_BYTES", str(256 << 20)))
MAX_STDIN_BYTES = int(os.environ.get("WATERMARKS_MAX_STDIN_BYTES", str(64 << 20)))
BINARY_SNIFF_BYTES = 64
TEXT_TOOL_ADVICE = ("Use media-edit / exiftool for images and video.",)


def eprint(*args: object) -> None:
    print(*args, file=sys.stderr)


def looks_binary(data: bytes) -> str | None:
    if b"\x00" in data[:BINARY_SNIFF_BYTES]:
        return "binary (NUL in prefix)"
    return None


def guard_binary(
    data: bytes,
    origin: str,
    *,
    allow_binary: bool = False,
    advice: tuple[str, ...] | None = None,
) -> None:
    if allow_binary:
        return
    kind = looks_binary(data)
    if kind is None:
        return
    eprint(f"refusing to treat {origin} as text: it looks like {kind}.")
    for line in advice or TEXT_TOOL_ADVICE:
        eprint(line)
    raise SystemExit(2)


def read_text_input(
    path: str | None,
    *,
    allow_binary: bool = False,
    advice: tuple[str, ...] | None = None,
) -> str:
    if path is None or path == "-":
        data = sys.stdin.buffer.read(MAX_STDIN_BYTES + 1)
        if len(data) > MAX_STDIN_BYTES:
            eprint(f"refusing stdin input larger than {MAX_STDIN_BYTES} bytes")
            raise SystemExit(2)
        guard_binary(data[:BINARY_SNIFF_BYTES], "stdin", allow_binary=allow_binary, advice=advice)
        return data.decode("utf-8", errors="surrogateescape")
    p = Path(path)
    size = p.stat().st_size if p.exists() else 0
    if size > MAX_INPUT_BYTES:
        eprint(f"refusing input larger than {MAX_INPUT_BYTES} bytes: {path}")
        raise SystemExit(2)
    data = p.read_bytes()
    guard_binary(data, str(path), allow_binary=allow_binary, advice=advice)
    return data.decode("utf-8", errors="surrogateescape")


def write_text_output(text: str, path: str | None) -> None:
    if path is None or path == "-":
        sys.stdout.write(text)
        if text and not text.endswith("\n"):
            sys.stdout.write("\n")
        return
    dest = Path(path)
    if dest.is_symlink():
        raise OSError(f"refusing to write through symlink: {dest}")
    dest.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp_name = tempfile.mkstemp(prefix=f".{dest.name}.", suffix=".tmp", dir=str(dest.parent))
    try:
        with os.fdopen(fd, "wb") as f:
            f.write(text.encode("utf-8", errors="surrogateescape"))
            f.flush()
            os.fsync(f.fileno())
        os.replace(tmp_name, dest)
    except BaseException:
        try:
            os.unlink(tmp_name)
        except OSError:
            pass
        raise


def emit_json(data: Any) -> None:
    json.dump(data, sys.stdout, indent=2, ensure_ascii=False)
    sys.stdout.write("\n")
