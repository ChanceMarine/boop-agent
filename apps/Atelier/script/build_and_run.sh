#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="Atelier"
DIST="$ROOT/dist"
BUNDLE="$DIST/$APP_NAME.app"
EXEC="$BUNDLE/Contents/MacOS/$APP_NAME"

VERIFY=false
OPEN_APP=true

for arg in "$@"; do
  case "$arg" in
    --verify) VERIFY=true ;;
    --no-open) OPEN_APP=false ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

pkill -x "$APP_NAME" 2>/dev/null || true

cd "$ROOT"
swift build -c debug

BIN="$(swift build -c debug --show-bin-path)/$APP_NAME"
rm -rf "$BUNDLE"
mkdir -p "$BUNDLE/Contents/MacOS" "$BUNDLE/Contents/Resources"
cp "$BIN" "$EXEC"

cat > "$BUNDLE/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>$APP_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>co.othlete.atelier</string>
  <key>CFBundleName</key>
  <string>$APP_NAME</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>LSMinimumSystemVersion</key>
  <string>14.0</string>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
</dict>
</plist>
PLIST

if "$OPEN_APP"; then
  /usr/bin/open -n "$BUNDLE"
fi

if "$VERIFY"; then
  sleep 1
  pgrep -x "$APP_NAME" >/dev/null
fi
