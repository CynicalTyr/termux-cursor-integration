---
name: new-skill
description: >-
  New-skill authors Cursor skills for the Ubuntu-in-Termux agent on this phone.
  Use when the user asks for a new skill, /new-skill, SKILL.md frontmatter,
  validate_skill.py, or skills under /root/.cursor/skills.
disable-model-invocation: false
compatibility: >-
  F-Droid Termux Ubuntu proot, Cursor CLI, HOME=/root.
metadata:
  status: "active"
  tags: "android,termux,skills"
  last-reviewed: "2026-08-27"
---

# New Skill Builder (Android / Termux Ubuntu)

Author skills for the **Cursor CLI agent running inside Ubuntu** (F-Droid Termux
proot). Do not paste Synology `/volume1` paths. Do not edit `skills-cursor/`.

Predictability: [references/AUTHORING.md](references/AUTHORING.md).

## 1. Before you begin

Gather or infer: purpose, scope, invocation mode, leading word, triggers,
domain knowledge the model would not infer, and output format.

Done when: purpose, location, and invocation mode are stated.

## 2. Where skills live

| Type | Path | Scope |
| --- | --- | --- |
| **Global (default)** | `/root/.cursor/skills/<name>/` | This Ubuntu CLI user |
| Termux project (opt-in) | `/data/data/com.termux/files/home/.cursor/skills/<name>/` | Explicit ask only |
| Forbidden | `/root/.cursor/skills-cursor/` | Cursor built-ins |

Shared storage (`/storage/emulated/0`) is for media and kit copies, not the
live skills tree (noexec, world-readable).

Layout:

```text
skill-name/
├── SKILL.md
├── scripts/
└── references/
```

## 3. Frontmatter

```yaml
---
name: skill-name-kebab
description: >-
  Leading-word does X on this phone. Use when the user asks about <triggers>.
disable-model-invocation: false
compatibility: >-
  F-Droid Termux Ubuntu proot, Cursor CLI.
---
```

`name` must match the folder. Description: leading word first; under 1024
characters. Prefer model-invoked (`false`) when sibling skills must reach it.

## 4. Creation workflow

1. Discovery: purpose, triggers, forbidden actions.
   Done when: those four are written down.
2. Design: kebab name, leading word, section outline.
   Done when: frontmatter draft exists.
3. Implementation: write under `/root/.cursor/skills/<name>/`.
   Done when: `SKILL.md` exists on disk.
4. Verification:

```bash
python3 /root/.cursor/skills/new-skill/scripts/validate_skill.py \
  /root/.cursor/skills/<name>
```

Done when: validator prints `OK` and exits 0.

Checklist:

- [ ] Frontmatter parses; `name` matches folder
- [ ] Steps end with **Done when:**
- [ ] No secret assignments outside code fences
- [ ] Scripts pass `bash -n` / `py_compile`
- [ ] Cross-link overlapping skills instead of duplicating runbooks

## 5. Minimal skeleton

```markdown
---
name: example-android-skill
description: >-
  Example-android-skill performs X on this phone. Use when the user asks for X
  or names /storage/emulated/0/Download.
disable-model-invocation: true
---

# Example Android Skill

## Pre-flight

- Agent HOME is `/root` inside Ubuntu.
- Named files only; do not walk all of DCIM.

## Workflow

1. Inspect current state.
   Done when: paths captured.
2. Apply the minimal change.
   Done when: diff is scoped.
3. Validate.
   Done when: listed commands exit 0.
```

## Related skills

- **skill-sentinel** vet before install
- **android-storage** path map
- **prompt-craft** how to attach skills in a prompt
