#!/usr/bin/env python3
"""Validate a Cursor skill directory (frontmatter, line budget, scripts)."""
from __future__ import annotations

import re
import stat
import subprocess
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    yaml = None  # type: ignore[assignment]


def _parse_frontmatter_simple(block: str) -> dict[str, object]:
    """Minimal YAML subset when PyYAML is unavailable."""
    data: dict[str, object] = {}
    current_key: str | None = None
    folded: list[str] = []
    for raw in block.splitlines():
        line = raw.rstrip()
        if not line.strip():
            continue
        if line.startswith("  ") and current_key == "description":
            folded.append(line.strip())
            continue
        if ":" in line and not line.startswith(" "):
            if current_key == "description" and folded:
                data[current_key] = " ".join(folded)
                folded = []
            key, val = line.split(":", 1)
            key = key.strip()
            val = val.strip()
            if val in (">-", "|"):
                current_key = key
                folded = []
                data[key] = ""
            elif val.startswith('"') and val.endswith('"'):
                data[key] = val[1:-1]
                current_key = None
            elif val.startswith("'") and val.endswith("'"):
                data[key] = val[1:-1]
                current_key = None
            else:
                data[key] = val
                current_key = None
    if current_key == "description" and folded:
        data[current_key] = " ".join(folded)
    return data


def validate_skill(skill_dir: Path) -> int:
    skill_file = skill_dir / "SKILL.md"
    if not skill_file.is_file():
        print(f"ERROR: missing {skill_file}", file=sys.stderr)
        return 1

    text = skill_file.read_text(encoding="utf-8")
    match = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    if not match:
        print("ERROR: missing YAML frontmatter at top of SKILL.md", file=sys.stderr)
        return 1

    frontmatter = (
        yaml.safe_load(match.group(1)) or {}
        if yaml
        else _parse_frontmatter_simple(match.group(1))
    )
    if frontmatter.get("name") != skill_dir.name:
        print(
            f"ERROR: frontmatter name {frontmatter.get('name')!r} != folder {skill_dir.name!r}",
            file=sys.stderr,
        )
        return 1

    if len(text.splitlines()) >= 800:
        print("ERROR: SKILL.md must stay under 800 lines", file=sys.stderr)
        return 1

    if "skills-cursor" in str(skill_dir):
        print("ERROR: never install custom skills under skills-cursor", file=sys.stderr)
        return 1

    for key in ("name", "description"):
        if key not in frontmatter:
            print(f"ERROR: missing frontmatter field {key}", file=sys.stderr)
            return 1

    name = str(frontmatter["name"])
    if not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", name):
        print("ERROR: skill name must be kebab-case", file=sys.stderr)
        return 1

    desc = str(frontmatter.get("description", ""))
    if len(desc) > 1024:
        print("ERROR: description over 1024 chars", file=sys.stderr)
        return 1

    # Flag likely leaked assignments outside fenced code; allow documenting env names.
    scan = re.sub(r"```.*?```", "", text, flags=re.S)
    if re.search(r"(?i)(password|token|api[_-]?key|secret)\s*=\s*\S+", scan):
        print(
            "ERROR: possible secret assignment outside code fences in SKILL.md",
            file=sys.stderr,
        )
        return 1

    scripts_dir = skill_dir / "scripts"
    if scripts_dir.is_dir():
        for script in scripts_dir.rglob("*"):
            if not script.is_file():
                continue
            if "__pycache__" in script.parts or script.suffix == ".pyc":
                continue
            data = script.read_bytes()
            if b"\r\n" in data:
                print(f"ERROR: {script.name}: CRLF line endings", file=sys.stderr)
                return 1
            if data.startswith(b"\xef\xbb\xbf"):
                print(f"ERROR: {script.name}: UTF-8 BOM", file=sys.stderr)
                return 1
            if script.stat().st_mode & stat.S_IWOTH:
                print(f"ERROR: {script.name}: world-writable", file=sys.stderr)
                return 1
            executable = (script.stat().st_mode & (stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)) != 0
            first_line = data.splitlines()[0].decode("utf-8", "replace") if data else ""
            has_shebang = first_line.startswith("#!")
            if executable and not has_shebang:
                print(f"ERROR: {script.name}: executable scripts require a shebang", file=sys.stderr)
                return 1
            if script.suffix == ".py":
                subprocess.run([sys.executable, "-m", "py_compile", str(script)], check=True)
            elif script.suffix == ".sh":
                subprocess.run(["bash", "-n", str(script)], check=True)

    print(f"OK: {skill_dir.name}")
    return 0


def main() -> int:
    if len(sys.argv) != 2:
        print(f"usage: {sys.argv[0]} <skill-dir>", file=sys.stderr)
        return 2
    return validate_skill(Path(sys.argv[1]).resolve())


if __name__ == "__main__":
    raise SystemExit(main())
