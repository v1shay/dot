#!/usr/bin/env bash
set -euo pipefail

APP_NAME="Dot"
BUNDLE_ID="com.v1shay.Dot"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_APP="$ROOT_DIR/dist/$APP_NAME.app"
INSTALL_APP="/Applications/$APP_NAME.app"
LAUNCH_AGENT="$HOME/Library/LaunchAgents/$BUNDLE_ID.plist"

"$ROOT_DIR/script/build_and_run.sh" --build-only

pkill -x "$APP_NAME" >/dev/null 2>&1 || true
rm -rf "$INSTALL_APP"
ditto "$SOURCE_APP" "$INSTALL_APP"

mkdir -p "$(dirname "$LAUNCH_AGENT")"
cat >"$LAUNCH_AGENT" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$BUNDLE_ID</string>
  <key>ProgramArguments</key>
  <array>
    <string>$INSTALL_APP/Contents/MacOS/$APP_NAME</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>ProcessType</key>
  <string>Interactive</string>
  <key>StandardOutPath</key>
  <string>$HOME/Library/Logs/$APP_NAME.log</string>
  <key>StandardErrorPath</key>
  <string>$HOME/Library/Logs/$APP_NAME.log</string>
</dict>
</plist>
PLIST

launchctl bootout "gui/$(id -u)" "$LAUNCH_AGENT" >/dev/null 2>&1 || true
launchctl bootstrap "gui/$(id -u)" "$LAUNCH_AGENT"
launchctl kickstart -k "gui/$(id -u)/$BUNDLE_ID"

sleep 1
pgrep -x "$APP_NAME" >/dev/null
echo "$APP_NAME installed at $INSTALL_APP and registered with launchd."
