import AppKit
import Combine
import SwiftUI

@MainActor
final class StatusBarController: NSObject {
    private let store: NoteStore
    private let statusItem: NSStatusItem
    private let popover = NSPopover()
    private var cancellables = Set<AnyCancellable>()
    private var isHiddenByUser = false

    init(store: NoteStore) {
        self.store = store
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()
    }

    func install() {
        isHiddenByUser = false
        statusItem.isVisible = true
        configureButton()
        configurePopover()
        observeStore()
        updateButton()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.forceVisible()
        }
    }

    private func configureButton() {
        guard let button = statusItem.button else {
            NSLog("Dot status item button missing")
            return
        }

        button.target = self
        button.action = #selector(togglePopover(_:))
        button.image = NSImage.dotLogo(size: NSSize(width: 18, height: 18))
        button.image?.isTemplate = false
        button.imagePosition = .imageLeading
        button.font = .systemFont(ofSize: NSFont.systemFontSize, weight: .bold)
        button.lineBreakMode = .byTruncatingTail
        button.toolTip = "Dot"
    }

    private func configurePopover() {
        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = NSSize(width: 460, height: 380)
        popover.contentViewController = NSHostingController(
            rootView: DotPopoverView(store: store)
                .frame(width: 460, height: 380)
        )
    }

    private func observeStore() {
        store.$notes
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

        button.title = " \(store.compactMenuBarTitle)"
        button.toolTip = store.currentLine
        statusItem.length = 104
        statusItem.isVisible = !isHiddenByUser
        NSLog("Dot status item visible=\(statusItem.isVisible) title=\(button.title)")
    }

    func forceVisible() {
        isHiddenByUser = false
        statusItem.isVisible = true
        updateButton()
        NSLog("Dot status item forced visible")
    }

    func toggleVisibility() {
        if statusItem.isVisible {
            isHiddenByUser = true
            popover.performClose(nil)
            statusItem.isVisible = false
            NSLog("Dot status item hidden")
        } else {
            forceVisible()
        }
    }

    @objc private func togglePopover(_ sender: NSStatusBarButton) {
        isHiddenByUser = false
        statusItem.isVisible = true

        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}

extension NSImage {
    static func dotLogo(size: NSSize? = nil) -> NSImage? {
        guard let url = Bundle.module.url(forResource: "dot-logo", withExtension: "png"),
              let image = NSImage(contentsOf: url) else {
            return nil
        }

        if let size {
            image.size = size
        }

        return image
    }
}
