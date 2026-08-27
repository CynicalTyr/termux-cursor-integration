---
name: media-edit
description: >-
  Media-edit trims, converts, extracts audio, strips tags, or inspects a
  named photo or video on this phone with ffmpeg and exiftool. Use when the
  user names a file under DCIM, Pictures, Movies, Music, or Download. Do not
  batch-process the whole camera roll.
disable-model-invocation: false
compatibility: >-
  Ubuntu in F-Droid Termux; ffmpeg and optionally exiftool.
metadata:
  status: "active"
  tags: "android,ffmpeg,exiftool"
  last-reviewed: "2026-08-27"
---

# Photo and video edit (named files)

Work on **one path the user named** (or a short explicit list). Write sidecars
next to the original (`*_edit.mp4`, `*_edit.jpg`) unless asked to replace.

Install if needed: `apt-get install -y ffmpeg libimage-exiftool-perl`.

## Pre-flight

1. Resolve the absolute path (`/storage/emulated/0/DCIM/...`). Quote spaces.
   Done when: `ls -l -- "PATH"` succeeds.
2. Probe:

```bash
ffprobe -hide_banner "PATH"
exiftool -s "PATH"
```

Done when: duration/codec or EXIF summary is known (or tool missing is stated).

## Workflow (pick one)

**Trim copy (no re-encode when possible):**

```bash
ffmpeg -ss 00:00:05 -i "IN" -t 00:00:20 -c copy "OUT"
```

**Extract audio:**

```bash
ffmpeg -i "IN" -vn -acodec libmp3lame -q:a 2 "OUT.mp3"
```

**Resize video (re-encode):**

```bash
ffmpeg -i "IN" -vf "scale=1280:-2" -c:a copy "OUT"
```

**Strip container metadata (best-effort):**

```bash
ffmpeg -i "IN" -map_metadata -1 -c copy "OUT"
exiftool -all= -overwrite_original_in_place "OUT"
```

Visible logo burn-in (`delogo`) only on **short clips** the user named, not
feature-length files. Pixel-domain “AI watermark wipe” is out of scope.
Use **remove-ai-watermarks** for Unicode/C2PA/tags on named files.

Done when: `ls -l -- "OUT"` shows a new file and `ffprobe`/`exiftool` matches
the requested change.

## Refuse

| Intent | Action |
| --- | --- |
| Walk all of `DCIM` / `Pictures` / `Movies` | Refuse; ask for names |
| Overwrite originals with no backup | Prefer sidecars; `--overwrite` only if asked |
| Edit another app’s private `/data/data` media | Refuse |

## Related skills

- **android-storage** folder map
- **yt-dlp** acquire then edit
- **remove-ai-watermarks** provenance hygiene
