# Phone skills pack

Skills for the **F-Droid Termux → Ubuntu proot → Cursor CLI** agent.
Ubuntu `$HOME` is `/root`. Copy this folder into the CLI user-skills tree.

## Install on the phone (inside Ubuntu)

Shared storage is **noexec**. Copy into `/root/.cursor/skills` before you
expect scripts to run as executables.

```bash
mkdir -p /root/.cursor/skills
cp -a /path/to/termux-cursor-integration/skills/. /root/.cursor/skills/
rm -f /root/.cursor/skills/README.md
ls /root/.cursor/skills
```

Kit files often land under Termux `~/storage/downloads/termux-cursor-integration/`.
Do **not** store cookies, SSH keys, or `.env` under `/storage/emulated/0`.

## What is in this pack

| Skill | When |
| --- | --- |
| **android-storage** | Paths: `/root`, Termux home, `/storage/emulated/0` |
| **yt-dlp** | Named downloads into Movies / Music / Download |
| **media-edit** | Named ffmpeg / exiftool edits (not whole DCIM) |
| **file-edit** | Scripts and text under Termux home or `/root` |
| **prompt-craft** | How to prompt this agent on the phone |
| **new-skill** | Author more skills; `scripts/validate_skill.py` |
| **skill-sentinel** | Vet a skill before install (T1–T8) |
| **remove-ai-watermarks** | Unicode / metadata hygiene on **named** files |

DSM, Docker, SMB, and NAS-only skills are not in this tree.

## Validate

```bash
python3 /root/.cursor/skills/new-skill/scripts/validate_skill.py /root/.cursor/skills/yt-dlp
```
