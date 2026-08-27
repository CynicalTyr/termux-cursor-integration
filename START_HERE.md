# Termux + Cursor integration

**If you only open one file, open this one.**

This kit runs the **official Linux ARM64 Cursor CLI** (`agent`) inside **Ubuntu
in Termux**. Cursor does not ship an Android CLI or a Play/Galaxy app for
this. The Termux build that works is **F-Droid**:

https://f-droid.org/packages/com.termux

Verified on a Samsung S24 (aarch64): `agent` `2026.08.25-3e8eec8` inside
Ubuntu, working directory = Termux `$HOME` (`/data/data/com.termux/files/home`).

Play Store Termux (`TERMUX_VERSION=googleplay.*`) cannot exec glibc Ubuntu.
Play and F-Droid Termux share the id `com.termux` with different signatures;
they cannot be installed together.

## Who it helps

| Who | What they get |
| --- | --- |
| Phone operators who already live in Termux | `ubuntu` then `agent`, editing Termux `$HOME` |
| People who want Cursor CLI on aarch64 Android | Official installer inside Ubuntu, fail-closed if `agent --version` dies |
| Folks who also edit photos, video, or downloads | Optional skills under `skills/` for named files on `/storage/emulated/0` |

## Who should skip this

- Play Store Termux that you will not uninstall.
- 32-bit phones. The artifact this kit installs is `linux/arm64`.
- Anyone looking for an official Cursor Android product. This is unofficial glue.
- Termius or other SSH apps. Those talk to a remote box; they do not host `agent` on the phone.
- Workspaces under other apps’ `/data/data/<pkg>` or Android `/system`. Stay in Termux home.

## First success

Downloads is **noexec**. Always `bash script.sh`. Never `./script.sh`.

1. Install Termux from F-Droid (link above). Open it. Empty home on a fresh
   install is normal.

2. Storage:

```bash
termux-setup-storage
```

Tap Allow. Copy this repository onto the phone (USB, `scp`, or shared
storage). Example after storage is granted:

```bash
cd ~/storage/downloads/termux-cursor-integration
ls install.sh apply-agent-path.sh
```

If `cd` fails, `ls ~/storage/downloads` and use the real folder name.

3. Install once. Ubuntu is a large download. Wait for `Stage A inner: PASS`
   and a version string.

```bash
chmod +x install.sh apply-agent-path.sh ubuntu-agent-path.sh enter-ubuntu.sh host-proot-login.sh install-cursor-agent-proot.sh proot-inner-stage-a.sh install-termux-autobuilds-key.sh diagnose.sh install-shortcuts.sh
bash install.sh
```

If `apt-get update` reports `NO_PUBKEY`, `install.sh` installs
`keys/termux-autobuilds.gpg` and keeps signature checks on. If that still
fails, stop. Do not rewrite `sources.list`. Do not add `[trusted=yes]`.
Do not `pkg upgrade` the whole prefix unless you accept a possible broken
environment.

4. Put `ubuntu` on the Termux PATH:

```bash
chmod +x install-shortcuts.sh host-proot-login.sh
bash install-shortcuts.sh
hash -r
ubuntu
```

Wait for `root@localhost`. Then:

```bash
agent --version
export NO_OPEN_BROWSER=1
agent login
```

Open the URL on the phone, finish auth. `pwd` should be
`/data/data/com.termux/files/home`. Type `agent`. Type `exit` to leave Ubuntu.

If `agent` is missing inside Ubuntu, **exit** to Termux (`~ $`) and run:

```bash
cd ~/storage/downloads/termux-cursor-integration
chmod +x apply-agent-path.sh host-proot-login.sh ubuntu-agent-path.sh
bash apply-agent-path.sh
```

Then `ubuntu` again. Do not type `agent` at the normal Termux prompt.

Same steps with no markdown: **`PASTE.txt`**.

## Daily use

At the Termux prompt:

```text
ubuntu
```

Then `agent`. Workspace is Termux `$HOME`. Shared storage (`~/storage`,
`/storage/emulated/0`) is for media and kit copies, not the live skills tree.

To load the phone skills pack (inside Ubuntu):

```bash
mkdir -p /root/.cursor/skills
cp -a /data/data/com.termux/files/home/storage/downloads/termux-cursor-integration/skills/. /root/.cursor/skills/
rm -f /root/.cursor/skills/README.md
ls /root/.cursor/skills
```

Cookies, SSH keys, and `.env` stay under `/root` or Termux home (`chmod 600`).
Do not put them on `/storage/emulated/0`.

## Keep the session alive

OEM battery savers kill long `agent` runs. **`NOTES.md`** covers unrestricted
battery, never-sleeping apps, Android 14+ “Disable child process restrictions,”
and Termux wakelock.

## Fail closed

Stop if:

- You are on Play Termux.
- Guest `execve("/usr/bin/sh"): Permission denied` (that build cannot run Ubuntu).
- `agent --version` inside Ubuntu is non-zero.

Then Cursor CLI is not usable on that device. SSH to a Linux box, or Cursor
cloud agents in a browser, is a different job and does not edit Termux `$HOME`.

## Rollback

Inside Termux (removes Ubuntu; does not uninstall Termux):

```bash
proot-distro remove ubuntu
```

Agent files live in Ubuntu’s `/root/.local/share/cursor-agent`, so removing
the distro removes them.

## Next

- Layout and “why this shape”: [`README.md`](README.md)
- Battery / phantom process: [`NOTES.md`](NOTES.md)
- Skills for named media and files: [`skills/README.md`](skills/README.md)
