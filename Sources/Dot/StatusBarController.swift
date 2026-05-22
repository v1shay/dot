import AppKit
import Combine
import SwiftUI

@MainActor
final class StatusBarController: NSObject {
    private let store: NoteStore
    private let statusItem: NSStatusItem
    private let popover = NSPopover()
    private var cancellables = Set<AnyCancellable>()

    init(store: NoteStore) {
        self.store = store
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()
    }

    func install() {
        statusItem.autosaveName = "com.v1shay.Dot.statusItem"
        statusItem.isVisible = true
        configureButton()
        configurePopover()
        observeStore()
        updateButton()
    }

    private func configureButton() {
        guard let button = statusItem.button else {
            return
        }

        button.target = self
        button.action = #selector(togglePopover(_:))
        button.image = NSImage(systemSymbolName: "circle.fill", accessibilityDescription: "Dot")
        button.image?.isTemplate = true
        button.imagePosition = .imageLeading
        button.font = .systemFont(ofSize: NSFont.systemFontSize, weight: .medium)
        button.lineBreakMode = .byTruncatingTail
        button.toolTip = "Dot"
    }

    private func configurePopover() {
        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = NSSize(width: 320, height: 360)
        popover.contentViewController = NSHostingController(
            rootView: DotPopoverView(store: store)
                .frame(width: 320, height: 360)
        )
    }

    private func observeStore() {
        store.$note
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateButton()
            }
            .store(in: &cancellables)

        store.$currentIndex
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateButton()
            }
            .store(in: &cancellables)
    }

    private func updateButton() {
        guard let button = statusItem.button else {
            return
        }

        button.title = " " + store.menuBarTitle
        button.toolTip = store.currentLine
        statusItem.length = min(max(button.intrinsicContentSize.width + 8, 34), 180)
        statusItem.isVisible = true
    }

    @objc private func togglePopover(_ sender: NSStatusBarButton) {
        statusItem.isVisible = true

        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
