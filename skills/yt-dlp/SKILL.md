---
name: yt-dlp
description: >-
  Yt-dlp downloads operator-owned or public media on this phone with ffmpeg
  post-process. Use when the user asks to save a video or audio URL into
  Movies, Music, or Download, extract audio, list formats, or fix extractor
  errors. Do not mass-scrape channels or bypass DRM.
disable-model-invocation: false
compatibility: >-
  Ubuntu in F-Droid Termux; yt-dlp + ffmpeg on PATH.
metadata:
  status: "active"
  tags: "android,yt-dlp,ffmpeg"
  last-reviewed: "2026-08-27"
---

# yt-dlp on this phone

Download into **named** folders under `/storage/emulated/0`. Inspect first.
Do not bypass DRM, paywalls, or someone else’s private account.

Flags below match the official yt-dlp CLI (`-o` templates, `-P` paths,
`--cookies` Netscape file, `-x` audio extract, `--restrict-filenames`,
`--download-archive`, `--max-downloads`). Confirm with `yt-dlp --help` if
options look stale.

## Pre-flight

```bash
command -v yt-dlp
yt-dlp --version
command -v ffmpeg
```

If missing inside Ubuntu:

```bash
apt-get update
apt-get install -y ffmpeg python3-pip
pip3 install -U yt-dlp
```

Done when: `yt-dlp --version` and `ffmpeg -version` both print a version line.

Cookies: user-provided Netscape file under `/root/.config/yt-dlp/cookies.txt`
(`chmod 600`). Do **not** use `--cookies-from-browser` against Samsung Browser
or other apps’ `/data/data`. Never store cookies on `/storage/emulated/0`.

## Workflow

1. Confirm URL, destination folder, and whether audio-only or video.
   Done when: URL and dest are restated.
2. Simulate before a real download:

```bash
yt-dlp --simulate --print "%(title)s [%(id)s].%(ext)s" "URL"
yt-dlp --list-formats "URL"
```

Done when: title/id or format list is shown (or a clear extractor error).

3. Smallest real command. Quote URL and `-o`. Prefer `--restrict-filenames` on
   sdcard. Use `--no-overwrites`. For playlists add `--max-downloads` and
   optionally `--download-archive /root/.config/yt-dlp/archive.txt`.

Video to Movies:

```bash
yt-dlp -P "/storage/emulated/0/Movies" \
  -o "%(title)s [%(id)s].%(ext)s" \
  --restrict-filenames --no-overwrites \
  "URL"
```

Audio to Music (`-x` needs ffmpeg):

```bash
yt-dlp -x --audio-format mp3 --audio-quality 0 \
  -P "/storage/emulated/0/Music" \
  -o "%(title)s [%(id)s].%(ext)s" \
  --restrict-filenames --no-overwrites \
  "URL"
```

Generic files to Download if the user did not pick Movies/Music.

Done when: `yt-dlp --print after_move:filepath` or `ls` shows the file.

4. Do not paste verbose logs that contain cookies or account URLs; summarize.
   Done when: the user has the path, not a cookie dump.

## Refuse

| Intent | Action |
| --- | --- |
| DRM / paid stream / “rip Netflix” | Refuse |
| Entire channel with no cap | Require `--max-downloads` or a playlist range |
| Cookies file on shared storage | Move under `/root/.config/yt-dlp` first |
| Steal another app’s browser profile | Refuse |

## Related skills

- **android-storage** dest folders and noexec
- **media-edit** trim/convert after download
- **file-edit** config files under `/root/.config`
