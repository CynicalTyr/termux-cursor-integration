# Termux + Cursor integration

**If you only open one file, open [`START_HERE.md`](START_HERE.md).**

Unofficial kit: official Cursor CLI (`agent`, `linux/arm64`) inside Ubuntu
in **F-Droid Termux** (`proot-distro`). Not an Anysphere Android product.

https://f-droid.org/packages/com.termux

`agent` is missing from the normal Termux `~ $` PATH. It exists **inside
Ubuntu**. A login Ubuntu shell also omits `~/.local/bin` until
`ubuntu-agent-path.sh` has run.

## What this does

1. Install Ubuntu with `proot-distro` (if needed).
2. Inside Ubuntu, run `curl -fsSL https://cursor.com/install | bash`.
3. Gate: `agent --version` must print a version.
4. Write Ubuntu `~/.bashrc` / `~/.profile` so `agent` stays on PATH.
5. Daily: type `ubuntu`, then `agent`. Termux `$HOME` is
   `/data/data/com.termux/files/home` inside Ubuntu.

Fail closed if that version command fails. Do not install Cursor into stock
Termux. Do not swap in Termux Node or rebuild sqlite inside the agent tree.

## How this is different

`agent` runs on this phone: native `aarch64`, official Linux CLI, inside
Ubuntu in F-Droid Termux. The kernel is Android's. Ubuntu is a userspace
rootfs (`proot-distro`). There is no guest kernel, no emulated CPU, and
no RAM reserved for a second OS.

Daily path: `ubuntu`, then `agent`. Workspace is Termux `$HOME`. Shared
storage is **noexec**.

Leave this kit if the job is a guest Linux (QEMU or hardware virt),
Podman/Docker/LXC, or an X11 desktop. Userspace Ubuntu does not provide
those. SSH and cloud agents are a different job: they do not edit Termux
home. Installing Cursor into stock Termux is the glibc/`e_type: 2` path
this kit already refuses.

## Repository layout

| File | What it does | What you change it for |
| ---- | ------------ | ---------------------- |
| `START_HERE.md` | Human install, first login, fail-closed | Phone path to the kit folder |
| `PASTE.txt` | Same steps, no markdown | Copy-paste into Termux |
| `NOTES.md` | Battery, phantom processes, wakelock | OEM wording |
| `install.sh` | Key if needed, Ubuntu, official installer, PATH, `ubuntu` command | Rarely |
| `apply-agent-path.sh` | From Termux: Ubuntu PATH for `agent` | After “command not found” |
| `ubuntu-agent-path.sh` | Same PATH fix, runs inside Ubuntu | Same |
| `install-shortcuts.sh` | `$PREFIX/bin/ubuntu` and `cua` | If `ubuntu` is missing |
| `host-proot-login.sh` | Start Ubuntu via host `proot` | proot-distro Python exec failures |
| `install-cursor-agent-proot.sh` | Stage A wrapper | Installer URL |
| `proot-inner-stage-a.sh` | Official installer inside Ubuntu | Fail-closed gate |
| `install-termux-autobuilds-key.sh` | Official autobuilds apt key only | `NO_PUBKEY` |
| `keys/termux-autobuilds.gpg` | Optional local copy; otherwise fetched and SHA-256 pinned | Termux key rotation |
| `diagnose.sh` | Read-only probe | Support reports (redact paths you care about) |
| `skills/` | Cursor user skills for the Ubuntu agent | Named files on shared storage |

## Hardware / software

| Resource | Minimum |
| -------- | ------- |
| CPU | **aarch64**. Official artifact here is `linux/arm64`. |
| OS | Android + **F-Droid Termux**. Not Play Termux. |
| Disk | Room for an Ubuntu rootfs plus the agent (hundreds of MB, often more). |
| Network | Ubuntu packages and `cursor.com/install`. |
| Workspace | Termux `$HOME`. Shared storage is **noexec**. |

## Related

| Piece | Why |
| ----- | --- |
| F-Droid Termux | Only Termux build that ran glibc Ubuntu + official `agent` in testing. |
| Cursor Linux ARM64 CLI | What `cursor.com/install` drops into Ubuntu `/root/.local`. |
| `skills/` | Optional; yt-dlp, ffmpeg, file edits, skill authoring. Not DSM/Docker. |

## What others will discover (that demos hide)

These show up after someone else runs the kit on a real phone.

| Lens | In this kit |
| ---- | ----------- |
| Hidden principle | Shared storage (`/storage/emulated/0`, Downloads) is **noexec**. `chmod +x` there does not make a script runnable. Use `bash script.sh`. |
| Recurring pattern | `agent` lives in Ubuntu `/root/.local/bin`. Typing `agent` at Termux `~ $` will always miss. |
| Mental model | Play Termux and F-Droid Termux are different signatures on the same package id. Guest `Permission denied` on `/usr/bin/sh` means stop, not “try harder with `[trusted=yes]`”. |
| Feedback loop | Nested `bash -lc 'export PATH=...; exec bash'` hung in testing. Login command is `/bin/bash -l`. The `$PREFIX/bin/ubuntu` wrapper must `exec` `host-proot-login.sh`, not copy `enter-ubuntu.sh` into `$PREFIX/bin` (that makes `KIT_DIR` become `/usr/bin`). |
| Hidden incentive | `pkg upgrade` of the whole prefix and rewriting `sources.list` look like “fix apt.” They are how people brick Termux while chasing Cursor. |
| Leverage point | Termux battery unrestricted, never-sleeping apps, Android 14+ **Disable child process restrictions**, notification wakelock. Without those, `agent` dies with signal 9. |
| Asymmetry | Official installer **inside** Ubuntu: pass. Same curl in stock Termux: glibc `node`, `unexpected e_type: 2`. |
| Cause → effect | Login shell PATH omits `/root/.local/bin` until `ubuntu-agent-path.sh`. Symptom is `agent: command not found` after a “successful” install. |
| Second-order | Pointing the agent at another app’s `/data/data/<pkg>` or `/system` looks like a bigger workspace. This kit refuses that. Stay in Termux home. |
| Risk if copied blindly | Community gists that `npm i sqlite3` inside the agent tree, Bionic “install Cursor in Termux” scripts, and `[trusted=yes]` apt. Fail closed instead. |
| Guest vs userspace | A Linux VM on the phone is a second OS (guest kernel, extra RAM, often containers or a desktop). This kit is one kernel: Android’s. Do not size a VM next to `agent` and call it the same setup. |

## License

MIT. See `LICENSE`.

## Coffee and energy fund

If this kit got `agent` running on the phone and you want more of that kind of work, you can support CynicalTyr's coffee and energy fund. Suggestion only.

<a title="Donate with PayPal" href="https://www.paypal.me/ctmskm" target="_blank" rel="noopener"><img src="https://moosenet.lol/assets/images/paypal-logo.png" alt="PayPal" width="140" height="50" /></a><a title="Donate with CashApp" href="https://cash.app/$MooseMeNow" target="_blank" rel="noopener"><img src="https://moosenet.lol/assets/images/cashapp-logo.png" alt="Cash App" width="140" height="55" /></a> <a title="Donate with Venmo" href="https://venmo.com/MooseMeNow" target="_blank" rel="noopener"><img src="https://moosenet.lol/assets/images/venmo-logo-600x188.png" alt="Venmo" width="140" height="50" /></a>
