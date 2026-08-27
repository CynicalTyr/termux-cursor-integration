#!/data/data/com.termux/files/usr/bin/bash
# Stage A: official Cursor Agent inside proot Ubuntu (glibc).
# Gate: agent --version. Fail closed if that fails.
# Does not sed-patch cursor.com/install. Does not use Termux Node.
set -euo pipefail

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
HOME="${HOME:-/data/data/com.termux/files/home}"
KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
chmod +x "${KIT_DIR}"/*.sh
INNER="${KIT_DIR}/proot-inner-stage-a.sh"
DISTRO="ubuntu"
PD_ROOT_V5="${PREFIX}/var/lib/proot-distro/containers/${DISTRO}/rootfs"
PD_ROOT_V4="${PREFIX}/var/lib/proot-distro/installed-rootfs/${DISTRO}"
SKIP_PKG=0

if [[ -d "${HOME}/storage/downloads" ]]; then
  LOG="${LOG:-${HOME}/storage/downloads/cursor-agent-proot-stage-a.log}"
else
  LOG="${LOG:-${KIT_DIR}/cursor-agent-proot-stage-a.log}"
fi

BLUE=$'\033[0;34m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
RED=$'\033[0;31m'
NC=$'\033[0m'

step() { printf '%s->%s %s\n' "$BLUE" "$NC" "$*"; }
ok()   { printf '%sok%s %s\n' "$GREEN" "$NC" "$*"; }
warn() { printf '%s!%s %s\n' "$YELLOW" "$NC" "$*"; }
die()  { printf '%serror%s %s\n' "$RED" "$NC" "$*" >&2; exit 1; }

usage() {
  cat <<EOF
Usage: bash install-cursor-agent-proot.sh [--skip-pkg]

Installs Ubuntu via proot-distro if missing, then runs the official
Cursor installer INSIDE Ubuntu and prints agent --version.

Prefer: bash install.sh  (keys + this wrapper)

Log hint: $LOG  (this script does not tee; redirect if you want a file)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-pkg) SKIP_PKG=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown arg: $1" ;;
  esac
done

require_termux() {
  if [[ "${PREFIX}" != /data/data/com.termux/files/usr* ]] && [[ ! -d /data/data/com.termux/files/usr ]]; then
    die "This wrapper is for Termux on Android only."
  fi
  if [[ "${TERMUX_VERSION:-}" == googleplay.* ]]; then
    die "Play Store Termux cannot run this. Use F-Droid Termux: https://f-droid.org/packages/com.termux"
  fi
  local arch
  arch="$(uname -m)"
  [[ "$arch" == "aarch64" || "$arch" == "arm64" ]] || die "Need ARM64 (got: $arch). Official Cursor CLI is linux/arm64 only here."
  [[ -f "$INNER" ]] || die "Missing $INNER"
  [[ -f "${KIT_DIR}/host-proot-login.sh" ]] || die "Missing ${KIT_DIR}/host-proot-login.sh"
}

# proot-distro is Python. Install python only. Do not pkg upgrade the whole prefix
# (a 3.13 to 3.14 style upgrade has broken Termux environments).
ensure_python_for_proot_distro() {
  if command -v python3 >/dev/null 2>&1; then
    ok "python3: $(command -v python3)"
    return 0
  fi
  [[ "$SKIP_PKG" -eq 0 ]] || die "python3 missing and --skip-pkg set. pkg install python"
  step "pkg install python (proot-distro needs it)"
  pkg install -y python || die "pkg install python failed. Do not pkg upgrade the whole prefix."
  command -v python3 >/dev/null || die "python3 still missing after pkg install python"
}

ensure_proot_distro() {
  ensure_python_for_proot_distro
  if command -v proot-distro >/dev/null 2>&1; then
    ok "proot-distro: $(command -v proot-distro)"
    return 0
  fi
  [[ "$SKIP_PKG" -eq 0 ]] || die "proot-distro missing and --skip-pkg set."
  step "pkg install proot-distro (no sources.list rewrite)"
  pkg install -y proot-distro || die "pkg install proot-distro failed. Do not rewrite sources.list."
  command -v proot-distro >/dev/null || die "proot-distro still missing after pkg install"
}

ubuntu_rootfs() {
  if [[ -d "$PD_ROOT_V5" ]]; then
    printf '%s\n' "$PD_ROOT_V5"
    return 0
  fi
  if [[ -d "$PD_ROOT_V4" ]]; then
    printf '%s\n' "$PD_ROOT_V4"
    return 0
  fi
  return 1
}

ensure_ubuntu() {
  local root
  if root="$(ubuntu_rootfs)"; then
    ok "Ubuntu rootfs present: $root"
    return 0
  fi
  step "proot-distro install $DISTRO (large download)"
  proot-distro install "$DISTRO"
  if root="$(ubuntu_rootfs)"; then
    ok "Ubuntu rootfs present: $root"
    return 0
  fi
  die "Ubuntu install reported success but rootfs not found under containers/${DISTRO}/rootfs or installed-rootfs/${DISTRO}"
}

run_inner() {
  step "Ubuntu: official Cursor install + agent --version"
  mkdir -p "${PREFIX}/tmp" "${HOME}/tmp"
  export TMPDIR="${PREFIX}/tmp"
  export PROOT_NO_SECCOMP=1
  # Do not use `proot-distro login` to exec proot: Python os.execvpe after
  # fchdir(rootfs) is Errno 13 on some Android/Termux builds. Shell exec of
  # host proot works. host-proot-login.sh uses --get-proot-cmd (absolute --rootfs).
  bash "${KIT_DIR}/host-proot-login.sh" --bind "${KIT_DIR}:/mnt/cursor-kit" -- /bin/sh /mnt/cursor-kit/proot-inner-stage-a.sh
}

main() {
  require_termux
  echo "==== Stage A wrapper $(date -Iseconds 2>/dev/null || date) ===="
  echo "KIT_DIR=$KIT_DIR"
  echo "TERMUX uname: $(uname -s) $(uname -m)"
  echo "LOG hint: $LOG"
  ensure_proot_distro
  ensure_ubuntu
  run_inner
  echo "==== Stage A wrapper: PASS ===="
  echo "agent --version printed a version inside Ubuntu."
  echo "Daily: chmod +x ${KIT_DIR}/enter-ubuntu.sh; bash ${KIT_DIR}/enter-ubuntu.sh"
  echo "Do not run agent at the normal Termux prompt."
}

main "$@"
