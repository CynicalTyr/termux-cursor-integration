# Authoring vocabulary (Android Cursor CLI)

Load when designing or pruning skills for the Ubuntu-in-Termux agent.
`name` in frontmatter must match the skill folder name.

## Location

| Choice | Path | When |
| --- | --- | --- |
| **Global (default)** | `/root/.cursor/skills/<name>/` | Phone CLI user skills |
| Termux project (opt-in) | `/data/data/com.termux/files/home/.cursor/skills/<name>/` | Only on explicit ask |
| Forbidden | `/root/.cursor/skills-cursor/` | Cursor built-ins |

Do not write skills under `/storage/emulated/0` as the live copy (noexec, world-readable).

## Invocation

| Mode | `disable-model-invocation` | Use |
| --- | --- | --- |
| Model-invoked | `false` | Ambient discovery (paths, yt-dlp, media, files) |
| User-invoked | `true` | Destructive or rare slash-only workflows |

## Description

- Leading word first, then distinct triggers (paths, tool names, error strings).
- Under 1024 characters.
- One trigger per branch; collapse synonyms.

## Hierarchy

1. Ordered steps in `SKILL.md` with **Done when:** on each step.
2. Depth in `references/`.
3. Helpers in `scripts/` (`bash -n` / `py_compile`).
4. `SKILL.md` under 800 lines.

## Steering

Pair hard bans with what to do instead. Keep one meaning site (do not copy the
same rule into description and body).
