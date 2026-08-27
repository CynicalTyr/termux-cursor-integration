# Contributing

Regular collaborators: one repository, branches, pull requests. Forks are for
people who do not have push access.

1. Keep the public tree free of secrets, cookies, LAN IPs, and live operator
   paths. No `.env` values. No SSH keys. No Cursor session tokens.
2. Phone scripts stay POSIX-ish bash that Termux can run. Prefer short `echo`
   lines over huge heredocs (`pipefail: command not found` showed up when
   Termux wrapped a script).
3. Shared storage is noexec. Docs and wrappers must say `bash script.sh`.
4. After changing `skills/`, run:

```bash
python3 skills/new-skill/scripts/validate_skill.py skills/<name>
```

5. After changing `*.sh`:

```bash
bash -n install.sh apply-agent-path.sh ubuntu-agent-path.sh enter-ubuntu.sh \
  host-proot-login.sh install-cursor-agent-proot.sh proot-inner-stage-a.sh \
  install-termux-autobuilds-key.sh diagnose.sh install-shortcuts.sh
```

Do not expand this into a Cursor Android port, a Play Termux workaround, or a
Bionic `node` shim. Those already failed.

Issues: one problem per ticket. Feature ideas: who it helps, and the command
that would prove it on F-Droid Termux.
