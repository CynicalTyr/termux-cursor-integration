#!/data/data/com.termux/files/usr/bin/bash
# Read-only probe: F-Droid Termux + Ubuntu + Cursor agent.
set -u

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
HOME="${HOME:-/data/data/com.termux/files/home}"
KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
chmod +x "${KIT_DIR}"/*.sh 2>/dev/null || true
PD_V5="${PREFIX}/var/lib/proot-distro/containers/ubuntu/rootfs"
PD_V4="${PREFIX}/var/lib/proot-distro/installed-rootfs/ubuntu"

echo "=== host ==="
uname -a
echo "TERMUX_VERSION=${TERMUX_VERSION:-unset}"
echo "HOME=$HOME"
echo "PREFIX=$PREFIX"
echo "KIT_DIR=$KIT_DIR"

if [[ "${TERMUX_VERSION:-}" == googleplay.* ]]; then
  echo "FAIL: Play Store Termux. Use https://f-droid.org/packages/com.termux"
fi

echo
echo "=== Termux names (should be missing) ==="
command -v agent 2>&1 || echo "agent not on Termux PATH (expected)"
command -v cursor-agent 2>&1 || echo "cursor-agent not on Termux PATH (expected)"

echo
echo "=== ubuntu rootfs ==="
if [[ -d "$PD_V5" ]]; then
  echo "OK $PD_V5"
elif [[ -d "$PD_V4" ]]; then
  echo "OK $PD_V4"
else
  echo "MISSING. Run bash install.sh"
fi

echo
echo "=== tools ==="
for b in proot proot-distro python3 pkg; do
  if command -v "$b" >/dev/null 2>&1; then
    echo "OK $b $(command -v $b)"
  else
    echo "MISSING $b"
  fi
done

echo
echo "=== guest agent --version ==="
if [[ -x "${KIT_DIR}/host-proot-login.sh" ]] && command -v proot >/dev/null 2>&1; then
  mkdir -p "${PREFIX}/tmp"
  export TMPDIR="${PREFIX}/tmp"
  export PROOT_NO_SECCOMP=1
  bash "${KIT_DIR}/host-proot-login.sh" -- /bin/sh -c 'export PATH="$HOME/.local/bin:$PATH"; agent --version' \
    && echo "guest agent OK" \
    || echo "guest agent FAIL. install.sh or enter-ubuntu.sh"
else
  echo "skip (host-proot-login.sh or proot missing)"
fi
