---
name: remove-ai-watermarks
description: >-
  Provenance-hygiene inspects and strips AI provenance marks from named
  files the operator owns on this phone: invisible Unicode (Layer A) in
  text, and EXIF/XMP/C2PA-style tags via ffmpeg/exiftool on a named photo
  or short clip. Use when the user asks to strip watermarks, remove Content
  Credentials, or clean AI metadata on a named path. Do not walk all of DCIM.
disable-model-invocation: false
compatibility: >-
  Ubuntu in F-Droid Termux; python3, ffmpeg, optionally exiftool.
metadata:
  status: "active"
  tags: "android,watermark,unicode,c2pa"
  last-reviewed: "2026-08-27"
---

# Remove AI watermarks (this phone)

Provenance hygiene for content the operator **owns or is authorized to process**.
Inspect first, then clean. Do not claim output is undetectable or human-written.

Read when needed:

- [references/ethics.md](references/ethics.md)
- [references/mark-classes.md](references/mark-classes.md)

```bash
SCRIPTS="${HOME}/.cursor/skills/remove-ai-watermarks/scripts"
python3 "$SCRIPTS/inspect_text.py" path.txt
python3 "$SCRIPTS/clean_text.py" path.txt -o path.cleaned.txt
```

If skills were copied but `$HOME` is not `/root`, use the absolute scripts path.

## Pre-flight

- Named files only. Do not audit all of `/storage/emulated/0/DCIM` or Pictures.
- Prefer sidecars (`*.cleaned.*`). In-place only when asked.
- Pixel-domain GPU inpainters and untrusted pip “unwatermark” clones are out of scope.
  Done when: ownership is stated and the refuse table applied.

## Refuse / still-clean

| User intent | Action |
| --- | --- |
| Own drafts: strip invisible Unicode, EXIF/XMP, container tags | Proceed |
| Academic fraud / “make this look human-written” | Refuse the deception |
| Walk the whole camera roll | Refuse; ask for names |
| Crawl a website to strip marks | Refuse |

## Workflow

1. Classify: text vs image vs video (named path).
   Done when: kind is stated.
2. **Text:** inspect then clean with the scripts above. Re-inspect.
   Done when: inspect report shows counts and the sidecar exists.
3. **Image/video:** `exiftool -s FILE` and/or `ffprobe`. Strip tags with
   **media-edit** sidecar commands (`-map_metadata -1`, `exiftool -all=`).
   Visible `delogo` only on a short named clip.
   Done when: sidecar exists; report separates verifiable vs best-effort.
4. Honesty: a stripped C2PA/EXIF block does not mean “no AI left.”
   Done when: the report uses those words if metadata was removed.

## Related skills

- **media-edit** ffmpeg/exiftool mechanics
- **file-edit** text files under Termux home or `/root`
- **android-storage** do not scan entire gallery trees
