#!/data/data/com.termux/files/usr/bin/bash
# Install `ubuntu` / `cua` on Termux PATH.
# Phone Downloads is noexec: never exec kit scripts; always `bash file`.
# A child `bash install-shortcuts.sh` cannot change the parent shell PATH,
# so the wrapper is written into $PREFIX/bin (already on PATH).
set -euo pipefail

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
HOME="${HOME:-/data/data/com.termux/files/home}"
KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN="${HOME}/.local/bin"
TARGET="${KIT_DIR}/enter-ubuntu.sh"
MARKER="# --- Cursor Ubuntu (Termux kit) ---"

die() { printf 'error: %s\n' "$*" >&2; exit 1; }

[[ -f "$TARGET" ]] || die "Missing $TARGET. Recopy the kit, then re-run."
[[ -f "${KIT_DIR}/host-proot-login.sh" ]] || die "Missing ${KIT_DIR}/host-proot-login.sh"

write_wrapper() {
  local dest="$1"
  cat > "$dest" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
PREFIX="\${PREFIX:-/data/data/com.termux/files/usr}"
mkdir -p "\$PREFIX/tmp"
export TMPDIR="\$PREFIX/tmp"
export PROOT_NO_SECCOMP=1
exec bash $(printf '%q' "${KIT_DIR}/host-proot-login.sh") -- /bin/bash -l
EOF
  chmod +x "$dest"
}

mkdir -p "$BIN"
write_wrapper "${BIN}/ubuntu"
ln -sfn "${BIN}/ubuntu" "${BIN}/cua"
write_wrapper "${PREFIX}/bin/ubuntu"
ln -sfn "${PREFIX}/bin/ubuntu" "${PREFIX}/bin/cua"

bashrc="${HOME}/.bashrc"
if [[ ! -f "$bashrc" ]] || ! grep -q "$MARKER" "$bashrc" 2>/dev/null; then
  cat >> "$bashrc" <<'EOF'
# --- Cursor Ubuntu (Termux kit) ---
export PATH="${HOME}/.local/bin:${PATH}"
# --- end Cursor Ubuntu ---
EOF
fi

if [[ ! -f "${HOME}/.bash_profile" ]] || ! grep -q '\.bashrc' "${HOME}/.bash_profile" 2>/dev/null; then
  cat >> "${HOME}/.bash_profile" <<'EOF'
# --- Cursor Ubuntu (Termux kit) ---
[ -f "${HOME}/.bashrc" ] && . "${HOME}/.bashrc"
# --- end Cursor Ubuntu ---
EOF
fi

echo "ok  ${PREFIX}/bin/ubuntu"
echo "    bash ${KIT_DIR}/host-proot-login.sh -- /bin/bash -l"
echo "ok  cua -> ubuntu"
echo
echo "Type:  ubuntu"
echo "If agent is command not found inside Ubuntu:"
echo "  bash ${KIT_DIR}/apply-agent-path.sh"
echo "Inside Ubuntu, type:  agent"
echo "Do not type agent at the normal Termux ~ $ prompt."
echo "Do not run kit scripts with ./  — Downloads is noexec. Use bash."
