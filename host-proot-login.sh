#!/data/data/com.termux/files/usr/bin/bash
# Start Ubuntu by exec'ing host proot FROM THE SHELL.
#
# `proot-distro login` does os.fchdir(rootfs) then os.execvpe(proot). That
# exec is Errno 13 on some Android/Termux builds (Play Termux in particular).
# This helper prints an argv with --rootfs=/abs/path and eval's it from bash.
#
# Usage:
#   bash host-proot-login.sh
#   bash host-proot-login.sh -- /bin/bash -l
#   bash host-proot-login.sh --bind "$KIT:/mnt/cursor-kit" -- /bin/sh /mnt/cursor-kit/proot-inner-stage-a.sh
set -euo pipefail

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
DISTRO="${DISTRO:-ubuntu}"
PD_ROOT_V5="${PREFIX}/var/lib/proot-distro/containers/${DISTRO}/rootfs"
PD_ROOT_V4="${PREFIX}/var/lib/proot-distro/installed-rootfs/${DISTRO}"

mkdir -p "${PREFIX}/tmp"
export TMPDIR="${PREFIX}/tmp"
export PROOT_NO_SECCOMP=1

BIND_SPECS=()
GUEST=()
saw_dd=0
while [[ $# -gt 0 ]]; do
  if [[ $saw_dd -eq 1 ]]; then
    GUEST+=("$1")
    shift
    continue
  fi
  case "$1" in
    --) saw_dd=1; shift ;;
    --bind)
      [[ $# -ge 2 ]] || { echo "error: --bind needs SRC or SRC:DST" >&2; exit 1; }
      BIND_SPECS+=("$2")
      shift 2
      ;;
    --bind=*)
      BIND_SPECS+=("${1#--bind=}")
      shift
      ;;
    *) echo "error: unknown arg $1 (put guest command after --)" >&2; exit 1 ;;
  esac
done
PD_BIND=()
RAW_BIND=()
for spec in "${BIND_SPECS[@]+"${BIND_SPECS[@]}"}"; do
  PD_BIND+=(--bind "$spec")
  RAW_BIND+=("--bind=$spec")
done
if [[ ${#GUEST[@]} -eq 0 ]]; then
  GUEST=(/bin/bash -l)
fi

rootfs=""
if [[ -d "$PD_ROOT_V5" ]]; then
  rootfs="$PD_ROOT_V5"
elif [[ -d "$PD_ROOT_V4" ]]; then
  rootfs="$PD_ROOT_V4"
else
  echo "error: Ubuntu rootfs missing. Run: bash install.sh" >&2
  exit 1
fi

if command -v proot-distro >/dev/null 2>&1; then
  printed=""
  if printed="$(proot-distro login "${PD_BIND[@]}" "$DISTRO" --get-proot-cmd -- "${GUEST[@]}" 2>/dev/null)" \
     && [[ -n "$printed" ]]; then
    eval "$printed"
    exit $?
  fi
fi

exec "${PREFIX}/bin/proot" \
  --kill-on-exit \
  --link2symlink \
  --change-id=0:0 \
  --rootfs="$rootfs" \
  --cwd=/root \
  --bind=/dev \
  --bind=/proc \
  --bind=/sys \
  "${RAW_BIND[@]}" \
  "${GUEST[@]}"
