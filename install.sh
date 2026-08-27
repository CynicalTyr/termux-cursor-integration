#!/data/data/com.termux/files/usr/bin/bash
# Cursor CLI on Android: F-Droid Termux + proot Ubuntu + official linux/arm64 agent.
# Not an official Anysphere Android product. Fail closed if agent --version fails.
set -euo pipefail

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
HOME="${HOME:-/data/data/com.termux/files/home}"
KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

die() { printf 'error: %s\n' "$*" >&2; exit 1; }

chmod +x "${KIT_DIR}"/*.sh 2>/dev/null || true

if [[ "${PREFIX}" != /data/data/com.termux/files/usr* ]] && [[ ! -d /data/data/com.termux/files/usr ]]; then
  die "Run this inside Termux on Android."
fi

if [[ "${TERMUX_VERSION:-}" == googleplay.* ]]; then
  die "Play Store Termux cannot run glibc Ubuntu for Cursor CLI. Uninstall it and install Termux from F-Droid: https://f-droid.org/packages/com.termux"
fi

echo "==== Cursor Agent kit ${KIT_DIR} ===="
echo "TERMUX_VERSION=${TERMUX_VERSION:-unknown}"
echo "arch=$(uname -m)"

if [[ ! -d "${HOME}/storage" ]]; then
  echo "No ~/storage yet. Grant Files access when asked, then re-run."
  echo "Running termux-setup-storage..."
  termux-setup-storage || true
fi

# Fresh F-Droid usually already has the repo key. Install ours only on NO_PUBKEY.
mkdir -p "${PREFIX}/tmp"
apt_out="$(mktemp "${PREFIX}/tmp/apt-update.XXXXXX")"
if ! apt-get update >"$apt_out" 2>&1; then
  if grep -q NO_PUBKEY "$apt_out"; then
    echo "apt missing Termux autobuilds key; installing kit key (signatures stay on)."
    bash "${KIT_DIR}/install-termux-autobuilds-key.sh"
  else
    cat "$apt_out"
    rm -f "$apt_out"
    die "apt-get update failed. Do not rewrite sources.list. Do not termux-change-repo unless you mean to."
  fi
else
  cat "$apt_out"
fi
rm -f "$apt_out"

bash "${KIT_DIR}/install-cursor-agent-proot.sh"
bash "${KIT_DIR}/apply-agent-path.sh"
bash "${KIT_DIR}/install-shortcuts.sh"
echo
echo "Install finished. Type:  ubuntu"
echo "Inside Ubuntu, type:  agent"
