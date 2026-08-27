#!/bin/sh
# Run INSIDE Ubuntu (root@localhost). Puts official agent on PATH for
# login shells (bash -l). Idempotent. Do not run this in stock Termux.
set -eu

HOME="${HOME:-/root}"
BASHRC="${HOME}/.bashrc"
PROFILE="${HOME}/.profile"
MARK="# --- Cursor Agent (Ubuntu-in-Termux) ---"

echo "==== ubuntu-agent-path ===="
echo "HOME=$HOME"
ls -l "${HOME}/.local/bin/agent" "${HOME}/.local/bin/cursor-agent" 2>/dev/null || {
  echo "error: agent not installed under ${HOME}/.local/bin" >&2
  ls -la "${HOME}/.local/bin" 2>/dev/null || true
  exit 1
}

if [ ! -f "$BASHRC" ] || ! grep -q "$MARK" "$BASHRC" 2>/dev/null; then
  echo "write $BASHRC"
  cat >> "$BASHRC" <<'EOF'
# --- Cursor Agent (Ubuntu-in-Termux) ---
export PATH="${HOME}/.local/bin:${PATH}"
export NO_OPEN_BROWSER=1
if [ -d /data/data/com.termux/files/home ]; then
  cd /data/data/com.termux/files/home
fi
# --- end Cursor Agent ---
EOF
else
  echo "ok $BASHRC already marked"
fi

if [ ! -f "$PROFILE" ] || ! grep -q "$MARK" "$PROFILE" 2>/dev/null; then
  echo "write $PROFILE"
  cat >> "$PROFILE" <<'EOF'
# --- Cursor Agent (Ubuntu-in-Termux) ---
export PATH="${HOME}/.local/bin:${PATH}"
export NO_OPEN_BROWSER=1
# --- end Cursor Agent ---
EOF
else
  echo "ok $PROFILE already marked"
fi

export PATH="${HOME}/.local/bin:${PATH}"
hash -r 2>/dev/null || true
echo "PATH=$PATH"
command -v agent
agent --version
echo "==== ubuntu-agent-path: PASS ===="
echo "Next: ubuntu   then   agent"
echo "Do not type agent at the normal Termux prompt."
