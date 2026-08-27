#!/data/data/com.termux/files/usr/bin/bash
# Install the official Termux autobuilds apt key (5A897D96E57CF20C).
# Does NOT rewrite sources.list. Does NOT disable signature checks.
set -euo pipefail

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="${KIT_DIR}/keys/termux-autobuilds.gpg"
DST="${PREFIX}/etc/apt/trusted.gpg.d/termux-autobuilds.gpg"
EXPECT_SHA="21c385d5a30107453bd60582d64e2f6e5f5ce11e340ac05e57f943f9c0235420"
EXPECT_FPR="CC72CF8BA7DBFA0182877D045A897D96E57CF20C"

die() { printf 'error %s\n' "$*" >&2; exit 1; }

KEY_URL="https://raw.githubusercontent.com/termux/termux-packages/master/packages/termux-keyring/termux-autobuilds.gpg"
if [[ ! -f "$SRC" ]]; then
  mkdir -p "$(dirname "$SRC")"
  command -v curl >/dev/null || die "curl missing; cannot fetch Termux autobuilds key"
  echo "fetching Termux autobuilds key"
  curl -fsSL -o "$SRC" "$KEY_URL" || die "could not download $KEY_URL"
fi
command -v sha256sum >/dev/null || die "sha256sum missing"

GOT="$(sha256sum "$SRC" | awk '{print $1}')"
[[ "$GOT" == "$EXPECT_SHA" ]] || die "key sha256 mismatch (got $GOT)"

if command -v gpg >/dev/null 2>&1; then
  FPR="$(gpg --show-keys --with-colons "$SRC" 2>/dev/null | awk -F: '/^fpr:/{print $10; exit}')"
  [[ "$FPR" == "$EXPECT_FPR" ]] || die "key fingerprint mismatch (got ${FPR:-empty})"
  echo "gpg fingerprint OK: $FPR"
else
  echo "gpg not installed; sha256 OK. fingerprint check skipped."
fi

mkdir -p "${PREFIX}/etc/apt/trusted.gpg.d"
cp -f "$SRC" "$DST"
chmod 644 "$DST"
echo "installed $DST"

echo "==== apt-get update (signature check still on) ===="
apt-get update
echo "==== key install PASS ===="
echo "Next: bash install.sh"
