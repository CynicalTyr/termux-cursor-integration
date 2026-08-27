---
name: android-storage
description: >-
  Android-storage maps Termux home, Ubuntu /root, and /storage/emulated/0
  folders (DCIM, Download, Movies, Music, Pictures, Documents). Use when the
  user mentions sdcard, shared storage, noexec Downloads, Samsung gallery
  paths, or Cursor CLI cwd vs HOME.
disable-model-invocation: false
compatibility: >-
  F-Droid Termux Ubuntu proot, Samsung /storage/emulated/0.
metadata:
  status: "active"
  tags: "android,paths,termux"
  last-reviewed: "2026-08-27"
---

# Android storage map

The Cursor CLI runs **inside Ubuntu** (`root@localhost`). Termux is the host.
Treat these as three trees, not one Linux desktop home.

## Trees

| Tree | Path | Use |
| --- | --- | --- |
| Ubuntu HOME | `/root` | Agent config, `/root/.cursor`, `/root/.local/bin/agent`, secrets (`chmod 600`) |
| Termux HOME | `/data/data/com.termux/files/home` | Termux scripts, `.ssh` for Termux, kit copies if not on sdcard |
| Shared storage | `/storage/emulated/0` | Camera, Downloads, Movies, Music, Pictures. **noexec** |

Do not edit `/data/data/<other-package>`, `/system`, `/vendor`, or `/apex`.

## Shared folders (user listing)

Prefer these under `/storage/emulated/0`:

- `DCIM` camera and screenshots (named files only; do not walk the whole tree)
- `Download` kit zips, exports (run with `bash script.sh`, never `./script.sh`)
- `Movies`, `Music`, `Pictures`, `Documents`, `Podcasts`, `Recordings`, `Audiobooks`
- App folders (`Samsung`, `Qfile`, `Mp3Cutter`, …) only when the user names a file

Quoted names with spaces: `'AiDrive US'`, `'Video To Audio'`, `'New Text Document.txt'`.

## noexec

Shared storage does not execute binaries or `chmod +x` scripts. Always:

```bash
bash /storage/emulated/0/Download/some-script.sh
```

Copy skills and scripts you will execute into `/root` or Termux `$HOME`.

## Workflow

1. Decide which tree the file belongs in (Ubuntu config vs Termux vs gallery).
   Done when: the absolute path is stated.
2. Quote paths with spaces; confirm the parent exists (`ls -ld`).
   Done when: `ls` shows the parent.
3. Write secrets only under `/root` or Termux home, never under `/storage/emulated/0`.
   Done when: mode is `600` if a secret file was created.

## Related skills

- **file-edit** how to change files in those trees
- **yt-dlp** / **media-edit** Movies, Music, DCIM
- **prompt-craft** cwd vs HOME in prompts
