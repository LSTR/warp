#!/usr/bin/env bash
set -eo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_NAME="LstrWarp"
BUNDLE_PATH="$REPO_ROOT/target/debug/bundle/osx/${APP_NAME}.app"
INSTALL_PATH="/Applications/${APP_NAME}.app"

echo "==> Building ${APP_NAME}"
echo

# ── 1. Xcode CLT ──────────────────────────────────────────────────────────────
if ! xcode-select -p &>/dev/null; then
    echo "→ Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Re-run install.sh after Xcode CLT finishes installing."
    exit 1
fi

# ── 2. Homebrew ───────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
    echo "→ Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# ── 3. Rust ───────────────────────────────────────────────────────────────────
if ! command -v cargo &>/dev/null; then
    echo "→ Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
# Make sure cargo is on PATH for the rest of this script
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# ── 4. ARM64 Rust target ──────────────────────────────────────────────────────
rustup target add aarch64-apple-darwin 2>/dev/null || true

# ── 5. Homebrew dependencies ──────────────────────────────────────────────────
echo "→ Installing build dependencies..."
brew install pkgconf llvm protobuf 2>/dev/null || true

# ── 6. cargo-bundle ───────────────────────────────────────────────────────────
if [[ ! -f "$HOME/.cargo/bin/cargo-bundle" ]]; then
    echo "→ Installing cargo-bundle..."
    cargo install cargo-bundle \
        --git=https://github.com/burtonageo/cargo-bundle \
        --rev ae4c76e92c08774bf54ff077b1c52e3d1cd6c16d
fi

# ── 7. Build ──────────────────────────────────────────────────────────────────
echo "→ Building (this will take a while on first run)..."
cd "$REPO_ROOT/app"
cargo bundle --bin lstr-warp --no-default-features --features lstr

# ── 9. Install to /Applications ───────────────────────────────────────────────
echo "→ Installing to /Applications/..."
rm -rf "$INSTALL_PATH"
cp -r "$BUNDLE_PATH" "$INSTALL_PATH"

# ── 10. Code signing ──────────────────────────────────────────────────────────
# cargo bundle leaves the app ad-hoc (linker-signed) with an unstable identifier,
# so its cdhash changes on every build. macOS TCC keys privacy grants to the
# code-signing identity, so an ad-hoc app is treated as a brand-new app after
# each rebuild and re-prompts for Documents/Desktop access every time.
#
# Signing with a real certificate gives a designated requirement based on
# identifier + certificate instead of the cdhash, so the grants stick.
echo "→ Code signing..."
CODESIGN_ID="${CODESIGN_ID:-$(security find-identity -v -p codesigning 2>/dev/null \
    | grep "Apple Development" | head -1 | sed -E 's/.*"(.*)"$/\1/')}"

if [[ -n "$CODESIGN_ID" ]]; then
    codesign --force --identifier "dev.warp.${APP_NAME}" --timestamp=none \
        --sign "$CODESIGN_ID" "$INSTALL_PATH"
    echo "  signed with: $CODESIGN_ID"
else
    echo "  ⚠ No signing identity found — falling back to ad-hoc."
    echo "    macOS will re-ask for file-access permissions after every rebuild."
    codesign --force --identifier "dev.warp.${APP_NAME}" --sign - "$INSTALL_PATH"
fi

# ── 11. Launch ────────────────────────────────────────────────────────────────
echo
echo "Done! Launching ${APP_NAME}..."
open "$INSTALL_PATH"
