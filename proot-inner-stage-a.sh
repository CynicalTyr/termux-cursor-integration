#!/bin/sh
# Runs INSIDE proot Ubuntu (glibc). Official Cursor CLI install + agent --version.
# POSIX sh: guest bash has been unexecutable under proot on some Androids.
# Do not run this on stock Termux. Do not npm-install inside the agent tree.
set -eu

export DEBIAN_FRONTEND=noninteractive
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${HOME}/.local/bin:${PATH:-}"

echo "==== Stage A inner: uname / linker ===="
uname -s
uname -m
if [ ! -e /lib/ld-linux-aarch64.so.1 ] && [ ! -e /lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 ]; then
  echo "error: glibc linker /lib/ld-linux-aarch64.so.1 not found" >&2
  ls -l /lib/ld-linux-aarch64.so.1 /lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 2>&1 || true
  exit 1
fi
ls -l /lib/ld-linux-aarch64.so.1 /lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 2>/dev/null || true

echo "==== apt curl ca-certificates ===="
apt-get update -y
apt-get install -y curl ca-certificates

echo "==== official Cursor installer ===="
curl -fsSL https://cursor.com/install | bash

export PATH="${HOME}/.local/bin:${PATH}"
hash -r 2>/dev/null || true

echo "==== PATH / launchers ===="
echo "PATH=$PATH"
command -v agent || true
command -v cursor-agent || true
ls -l "${HOME}/.local/bin/agent" "${HOME}/.local/bin/cursor-agent" 2>/dev/null || true

echo "==== agent --version (gate) ===="
if command -v agent >/dev/null 2>&1; then
  agent --version
elif command -v cursor-agent >/dev/null 2>&1; then
  echo "agent not on PATH; trying cursor-agent --version"
  cursor-agent --version
else
  echo "error: neither agent nor cursor-agent on PATH after install" >&2
  ls -la "${HOME}/.local/bin" 2>/dev/null || true
  ls -la "${HOME}/.local/share/cursor-agent/versions" 2>/dev/null || true
  exit 1
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
if [ -f "${SCRIPT_DIR}/ubuntu-agent-path.sh" ]; then
  sh "${SCRIPT_DIR}/ubuntu-agent-path.sh"
fi

echo "==== Stage A inner: PASS ===="
