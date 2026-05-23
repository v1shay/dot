<div align="center">

<img width="400" height="400" alt="ChatGPT Image May 21, 2026, 10_59_04 PM" src="https://github.com/user-attachments/assets/4ff2e3e8-028f-4769-83a3-5ccd8206d5c6" />

<<<<<<< Updated upstream
</div>
=======
## Behavior

- Lives in the menu bar only.
- Opens a small SwiftUI material popover from the menu bar item.
- Saves notes and the active line index in `UserDefaults`.
- Splits notes by non-empty lines.
- Shows the active line in the menu bar and truncates long text.
- Uses Option + ` to advance to the next line.
- Uses Option + H to hide or resurface Dot without quitting it.
- Provides Reset and Clear controls.

## Build and Run

Open the folder in Xcode, select the `Dot` executable scheme, and run it.

From Terminal or Codex, use:

```sh
./script/build_and_run.sh
```

The script builds with SwiftPM, stages `dist/Dot.app`, and launches it as a real macOS app bundle. If `/Applications/Dot.app` already exists, the script also replaces that installed copy before launching, so the permanent app stays in sync with source changes. Once launched, Dot keeps running independently of Xcode until you quit it or stop the process.

To install Dot permanently so it launches at login and launchd restarts it if it exits:

```sh
./script/install_permanent.sh
```

That copies `Dot.app` to `/Applications/Dot.app` and registers `~/Library/LaunchAgents/com.v1shay.Dot.plist` with `RunAtLoad` and `KeepAlive`.

## Hotkey Notes

The global hotkeys are registered with Carbon `RegisterEventHotKey`, so no Accessibility permission is normally required. If a shortcut does not work, another app may already own it; quit the conflicting app and relaunch Dot.

## Menu Bar Only

The app bundle sets `LSUIElement` in its generated `Info.plist`, and the app also uses accessory activation policy at launch. It should not appear as a normal Dock app.
>>>>>>> Stashed changes
