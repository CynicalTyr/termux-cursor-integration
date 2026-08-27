#!/data/data/com.termux/files/usr/bin/bash
# From Termux: run ubuntu-agent-path.sh inside Ubuntu (Downloads is noexec).
set -euo pipefail

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INNER="${KIT_DIR}/ubuntu-agent-path.sh"

[[ -f "$INNER" ]] || { echo "error: missing $INNER" >&2; exit 1; }
[[ -f "${KIT_DIR}/host-proot-login.sh" ]] || { echo "error: missing host-proot-login.sh" >&2; exit 1; }

mkdir -p "${PREFIX}/tmp"
export TMPDIR="${PREFIX}/tmp"
export PROOT_NO_SECCOMP=1
bash "${KIT_DIR}/host-proot-login.sh" --bind "${KIT_DIR}:/mnt/cursor-kit" -- /bin/sh /mnt/cursor-kit/ubuntu-agent-path.sh
