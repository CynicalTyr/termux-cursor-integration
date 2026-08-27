# Termux autobuilds apt key

`install-termux-autobuilds-key.sh` uses a local `termux-autobuilds.gpg` when
present, otherwise it downloads the official Termux autobuilds key from
`termux/termux-packages` (`packages/termux-keyring/termux-autobuilds.gpg`).

`install-termux-autobuilds-key.sh` checks:

- SHA-256 `21c385d5a30107453bd60582d64e2f6e5f5ce11e340ac05e57f943f9c0235420`
- fingerprint `CC72CF8BA7DBFA0182877D045A897D96E57CF20C` when `gpg` is present

`install.sh` copies this file only when `apt-get update` reports `NO_PUBKEY`.
It does not rewrite `sources.list` and does not disable signature checks.

If Termux rotates the key, update the file from upstream and the two pins
in `install-termux-autobuilds-key.sh` together.
