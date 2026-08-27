---
name: prompt-craft
description: >-
  Prompt-craft writes effective prompts for the Ubuntu-in-Termux Cursor CLI.
  Use when the user asks how to prompt the phone agent, attach skills, set
  cwd versus HOME, or keep media/file tasks checkable.
disable-model-invocation: false
compatibility: >-
  Cursor CLI inside Ubuntu proot (F-Droid Termux).
metadata:
  status: "active"
  tags: "android,prompting,cursor-cli"
  last-reviewed: "2026-08-27"
---

# Prompting this phone agent

The CLI runs as **root inside Ubuntu**. `HOME` is `/root`. Termux `$HOME` is
a different tree. Shared storage is `/storage/emulated/0` and **noexec**.

## Prompt shape

1. **Goal** one sentence (download this URL, trim this clip, edit this script).
2. **Path** absolute, quoted if it has spaces.
3. **Done when** what you will see (`ls` path, duration, exit 0).
4. **Constraints** named file only; sidecar vs overwrite; dest folder.

Example:

```text
Trim the first 15 seconds of
"/storage/emulated/0/DCIM/Camera/20260827_120000.mp4"
Write sidecar "..._trim.mp4" in the same folder. Do not walk DCIM.
Done when: ffprobe shows ~15s on the sidecar.
```

## Skills

User skills live in `/root/.cursor/skills/`. Attach or name the skill
(`yt-dlp`, `media-edit`, `file-edit`) when the task matches. Do not expect
NAS skills (DSM, Docker, CodeGraph) to exist here.

Keep secrets out of the prompt. Point at a `chmod 600` file under `/root`.

## cwd vs HOME

- Start the agent from the directory you want as workspace, or state cwd in
  the prompt.
- Config and skills: `/root/.cursor/...` regardless of cwd.
- Gallery files: always pass `/storage/emulated/0/...`, not `~/Pictures`
  (Ubuntu `~` is `/root`).

## Related skills

- **android-storage** path map
- **new-skill** write another skill instead of a long prompt
- **skill-sentinel** vet a skill you pasted in
