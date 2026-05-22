import SwiftUI

@main
struct DotApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var noteStore = NoteStore()
    @StateObject private var hotKey = GlobalHotKey()

    var body: some Scene {
        MenuBarExtra {
            DotPopoverView(store: noteStore)
                .frame(width: 320, height: 360)
                .onAppear {
                    hotKey.register {
                        noteStore.advance()
                    }
                }
                .onDisappear {
                    hotKey.unregister()
                }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "circle.fill")
                    .font(.system(size: 8, weight: .semibold))
                Text(noteStore.menuBarTitle)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .menuBarExtraStyle(.window)
    }
}
