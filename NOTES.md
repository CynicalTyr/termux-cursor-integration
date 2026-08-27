# Keep Cursor agent alive on Android

These settings do not install `agent`. They keep a **working**
Ubuntu-in-Termux session from being killed. Use **Termux from F-Droid**:
https://f-droid.org/packages/com.termux

## Battery

Cursor Agent is a long-lived CPU process. OEM battery savers will sleep Termux.

1. Settings → Apps → Termux → Battery → **Unrestricted**.
2. Settings → Battery → Background usage limits / Never sleeping apps → add **Termux** (wording varies by OEM).
3. Disable Adaptive battery for Termux if that menu exists.

Samsung One UI: Settings → Battery and device care → Battery → Background usage limits → Never sleeping apps.

## Phantom processes (Android 14+)

If Termux prints `[Process completed (signal 9)]` during an agent run:

1. Settings → About phone → tap **Build number** seven times.
2. Settings → Developer options → enable **Disable child process restrictions**.
3. Reboot.

Keep Developer options enabled or that toggle can turn back off.

## Termux wakelock

While `agent` is running: pull down the Termux notification → **Acquire wakelock**.

Optional:

```bash
pkg install termux-api
termux-wake-lock
```

## Storage

```bash
termux-setup-storage
```

Then this kit can live under `~/storage/downloads/…`. Shared storage is **noexec**. Always `bash script.sh`, never `./script.sh`.

## agent: command not found

`agent` lives in Ubuntu `/root/.local/bin`. From Termux:

```bash
cd ~/storage/downloads/termux-cursor-integration
chmod +x apply-agent-path.sh host-proot-login.sh ubuntu-agent-path.sh
bash apply-agent-path.sh
```

Then `ubuntu` and `agent`. Do not type `agent` at the normal Termux prompt.

## Do not

- Run `curl https://cursor.com/install | bash` in stock Termux (glibc `node`, `e_type: 2`).
- Use Play Store Termux for this kit.
- `pkg upgrade` the whole prefix unless you accept a possible broken environment.
- Rewrite `sources.list` or disable apt signatures.
- Point agent at other apps’ `/data/data/<pkg>` or Android `/system`.
