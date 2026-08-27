# Security

- Never open issues that paste Cursor login URLs with tokens, cookies,
  `~/.ssh` keys, or `.env` values.
- This project is a **Termux + Ubuntu glue kit**, not a hosted service.
- Report a way to skip the `agent --version` gate, disable apt signatures,
  or aim the agent at another app’s `/data/data/<pkg>` or `/system` through
  GitHub private vulnerability reporting when it is enabled; otherwise an
  issue with a **redacted** repro.

Do not ask maintainers to add `[trusted=yes]`, rewrite `sources.list`, or
ship a stock-Termux installer. Those are the incidents this repo exists to
stop.

Maintainer contact for security: GitHub Security Advisories on this
repository (CynicalTyr).
