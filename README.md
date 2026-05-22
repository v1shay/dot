# Dot

Dot is a compact macOS menu bar app for cycling through lines from a saved note.

## Behavior

- Lives in the menu bar only.
- Opens a small SwiftUI material popover from the menu bar item.
- Saves the note and active line index in `UserDefaults`.
- Splits notes by non-empty lines.
- Shows the active line in the menu bar and truncates long text.
- Uses Option + ` to advance to the next line.
- Provides Reset and Clear controls.

## Build and Run

Open the folder in Xcode, select the `Dot` executable scheme, and run it.

From Terminal or Codex, use:

```sh
./script/build_and_run.sh
```

The script builds with SwiftPM, stages `dist/Dot.app`, and launches it as a real macOS app bundle. Once launched, Dot keeps running independently of Xcode until you quit it or stop the process.

## Hotkey Notes

The global hotkey is registered with Carbon `RegisterEventHotKey`, so no Accessibility permission is normally required. If Option + ` does not advance the line, another app may already own that shortcut; quit the conflicting app and relaunch Dot.

## Menu Bar Only

The app bundle sets `LSUIElement` in its generated `Info.plist`, and the app also uses accessory activation policy at launch. It should not appear as a normal Dock app.
