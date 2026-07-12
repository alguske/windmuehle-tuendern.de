#!/usr/bin/env bash
# Bootstrap a fresh environment (a Codex/CI sandbox, a new laptop) so agents and
# people can build and verify the site. Installs the pinned Zola binary and any
# Python fallback dep. Idempotent: safe to run repeatedly.
#
#   ./scripts/setup.sh
#
# Codex: run this as the environment "setup" command so the sandbox can execute
# `zola build` and the validators before opening a pull request.

set -euo pipefail

# Keep in lockstep with the version pinned in .github/workflows/*.yml.
ZOLA_VERSION="0.22.0"

install_zola() {
  if command -v zola >/dev/null 2>&1 && zola --version 2>/dev/null | grep -q "$ZOLA_VERSION"; then
    echo "zola $ZOLA_VERSION already present"
    return
  fi

  local triple url tmp dest
  case "$(uname -s)-$(uname -m)" in
    Linux-x86_64)   triple="x86_64-unknown-linux-gnu" ;;
    Linux-aarch64)  triple="aarch64-unknown-linux-gnu" ;;
    Darwin-arm64)   triple="aarch64-apple-darwin" ;;
    Darwin-x86_64)  triple="x86_64-apple-darwin" ;;
    *) echo "Unsupported platform $(uname -s)-$(uname -m); install Zola $ZOLA_VERSION manually from https://github.com/getzola/zola/releases" >&2; return 1 ;;
  esac

  url="https://github.com/getzola/zola/releases/download/v${ZOLA_VERSION}/zola-v${ZOLA_VERSION}-${triple}.tar.gz"
  tmp="$(mktemp -d)"
  echo "Downloading zola $ZOLA_VERSION ($triple)..."
  curl -fsSL "$url" | tar xz -C "$tmp"

  # Prefer a system dir when writable/sudo is available, else fall back to ~/.local/bin.
  if [ -w /usr/local/bin ]; then
    dest="/usr/local/bin"
    mv "$tmp/zola" "$dest/zola"
  elif sudo -n true 2>/dev/null; then
    dest="/usr/local/bin"
    sudo mv "$tmp/zola" "$dest/zola"
  else
    dest="$HOME/.local/bin"
    mkdir -p "$dest"
    mv "$tmp/zola" "$dest/zola"
    echo "Installed to $dest — make sure it is on your PATH."
  fi
  rm -rf "$tmp"
}

install_python_deps() {
  # validate-fuehrungen.py uses tomllib (Python 3.11+). Backfill with tomli on older.
  if ! python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 11) else 1)' 2>/dev/null; then
    python3 -m pip install --quiet tomli 2>/dev/null || echo "note: could not install tomli; use Python 3.11+ for scripts/validate-fuehrungen.py"
  fi
}

install_zola
install_python_deps

echo
echo "Verifying:"
zola --version
python3 --version
echo "Setup complete. Build: zola build   Preview: ./start-local.sh"
