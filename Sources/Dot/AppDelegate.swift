import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let noteStore = NoteStore()
    private let hotKey = GlobalHotKey()
    private var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let statusBarController = StatusBarController(store: noteStore)
        statusBarController.install()
        self.statusBarController = statusBarController

        hotKey.register {
            self.noteStore.advance()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotKey.unregister()
    }
}
