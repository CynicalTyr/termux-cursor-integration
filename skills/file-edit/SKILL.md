---
name: file-edit
description: >-
  File-edit changes scripts, configs, and text the operator owns on this
  phone. Use when the user asks to edit a file under Termux home, /root,
  or a named path on /storage/emulated/0. Never edit other apps under
  /data/data or Android /system.
disable-model-invocation: false
compatibility: >-
  Ubuntu in F-Droid Termux; Cursor CLI.
metadata:
  status: "active"
  tags: "android,files,termux"
  last-reviewed: "2026-08-27"
---

# File edits on this phone

Minimal diffs. Read the file, change what was asked, verify.

## Where writes are allowed

| Location | Typical files |
| --- | --- |
| `/root` | `.bashrc`, `.profile`, `.cursor/`, `.config/`, `.local/` |
| `/data/data/com.termux/files/home` | Termux scripts, Termux `.ssh`, kit copies |
| `/storage/emulated/0/...` | Named documents the user owns (quotes for spaces) |

Secrets (`id_rsa`, cookies, tokens): only under `/root` or Termux home,
`chmod 600`. Never on shared storage.

## Workflow

1. Confirm the absolute path and that it is not another package or `/system`.
   Done when: path is classified against the table above.
2. Read the current file (or state that it does not exist).
   Done when: contents or “missing” is known.
3. Apply the smallest edit. Preserve line endings (LF).
   Done when: the requested change is in the file.
4. For shell scripts on shared storage, tell the user to run `bash path`
   (noexec). For scripts in `/root` or Termux home, `chmod 700` is OK.
   Done when: how to run it is stated.
5. Do not create world-writable files (`chmod o+w`).
   Done when: `ls -l` is not `*w*` for other.

## Refuse

- `/data/data/<pkg>` except Termux (`com.termux`)
- `/system`, `/vendor`, `/apex`
- Drive-by rewrites of working `ubuntu` wrappers unless the user asked

## Related skills

- **android-storage** trees and noexec
- **prompt-craft** attach files in the prompt
- **new-skill** authoring under `/root/.cursor/skills`
