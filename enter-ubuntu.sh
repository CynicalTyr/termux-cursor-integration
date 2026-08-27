#!/data/data/com.termux/files/usr/bin/bash
# Daily: same as the working paste. host-proot-login.sh -- /bin/bash -l
# Do not type `agent` at the normal Termux prompt.
set -euo pipefail

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "${PREFIX}/tmp"
export TMPDIR="${PREFIX}/tmp"
export PROOT_NO_SECCOMP=1
exec bash "${KIT_DIR}/host-proot-login.sh" -- /bin/bash -l
