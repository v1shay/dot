import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let noteStore = NoteStore()
    private let advanceHotKey = GlobalHotKey()
    private let visibilityHotKey = GlobalHotKey(signature: "DOT2", id: 2, keyCode: GlobalHotKey.hKeyCode)
    private var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let statusBarController = StatusBarController(store: noteStore)
        statusBarController.install()
        self.statusBarController = statusBarController
        NSLog("Dot launched")

        advanceHotKey.register {
            self.noteStore.advance()
            NSLog("Dot cycled to \(self.noteStore.currentLine)")
        }

        visibilityHotKey.register {
            self.statusBarController?.toggleVisibility()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        advanceHotKey.unregister()
        visibilityHotKey.unregister()
    }
}
