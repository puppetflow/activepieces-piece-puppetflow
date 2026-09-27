#!/usr/bin/env bash
# Builds the self-contained Activepieces bundle for this piece.
#
# Activepieces pieces must be bundled with the tooling that lives in the
# activepieces monorepo (the @activepieces/* libraries are inlined into the
# bundle and are not published to npm). This script clones the monorepo at a
# pinned commit, drops this piece into packages/pieces/community/puppetflow,
# runs the official build, and copies the publishable artifact to ./dist.
#
# Usage: scripts/build.sh
# Env:   ACTIVEPIECES_REF   commit or tag of activepieces/activepieces to build against
#        ACTIVEPIECES_DIR   where to clone the monorepo (default: .activepieces)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ACTIVEPIECES_REF="${ACTIVEPIECES_REF:-d2b0b096695a60f7292f37dddcc8c1537db97a08}"
ACTIVEPIECES_DIR="${ACTIVEPIECES_DIR:-$ROOT/.activepieces}"
PIECE_NAME="puppetflow"
PIECE_DIR="$ACTIVEPIECES_DIR/packages/pieces/community/$PIECE_NAME"

log() { printf '\033[1;34m[build]\033[0m %s\n' "$*"; }

if [ ! -d "$ACTIVEPIECES_DIR/.git" ]; then
  log "Cloning activepieces/activepieces at $ACTIVEPIECES_REF"
  git init -q "$ACTIVEPIECES_DIR"
  git -C "$ACTIVEPIECES_DIR" remote add origin https://github.com/activepieces/activepieces.git
fi
git -C "$ACTIVEPIECES_DIR" fetch -q --depth 1 origin "$ACTIVEPIECES_REF"
git -C "$ACTIVEPIECES_DIR" checkout -q --force FETCH_HEAD
git -C "$ACTIVEPIECES_DIR" clean -qfd -e node_modules -e "packages/**/node_modules"

log "Copying piece sources into $PIECE_DIR"
rm -rf "$PIECE_DIR"
mkdir -p "$PIECE_DIR"
cp -R "$ROOT/src" "$PIECE_DIR/src"
cp "$ROOT/package.json" "$ROOT/tsconfig.json" "$ROOT/tsconfig.lib.json" "$ROOT/.eslintrc.json" "$PIECE_DIR/"

log "Registering the piece in tsconfig.base.json"
node - "$ACTIVEPIECES_DIR/tsconfig.base.json" "$PIECE_NAME" "$ROOT/package.json" <<'EOF'
const fs = require('fs');
const [file, pieceName, packageJsonPath] = process.argv.slice(2);
const json = JSON.parse(fs.readFileSync(file, 'utf8'));
const pkg = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
json.compilerOptions.paths[pkg.name] = [`packages/pieces/community/${pieceName}/src/index.ts`];
fs.writeFileSync(file, JSON.stringify(json, null, 2) + '\n');
EOF

log "Installing monorepo dependencies"
(cd "$ACTIVEPIECES_DIR" && bun install --ignore-scripts >/dev/null)

log "Building and bundling the piece"
(cd "$ACTIVEPIECES_DIR" && TS_NODE_TRANSPILE_ONLY=true npm run --silent build-piece "$PIECE_NAME")

log "Copying artifact to $ROOT/dist"
rm -rf "$ROOT/dist"
cp -R "$PIECE_DIR/dist" "$ROOT/dist"

log "Done"
ls -la "$ROOT/dist"
