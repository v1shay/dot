import Foundation

@MainActor
final class NoteStore: ObservableObject {
    @Published var note: String {
        didSet {
            defaults.set(note, forKey: Keys.note)
            clampCurrentIndex()
        }
    }

    @Published private(set) var currentIndex: Int {
        didSet {
            defaults.set(currentIndex, forKey: Keys.currentIndex)
        }
    }

    private let defaults: UserDefaults

    var lines: [String] {
        note
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    var currentLine: String {
        guard !lines.isEmpty else { return "Dot" }
        return lines[min(currentIndex, lines.count - 1)]
    }

    var menuBarTitle: String {
        let line = currentLine
        guard line.count > 18 else { return line }
        return String(line.prefix(17)) + "..."
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        note = defaults.string(forKey: Keys.note) ?? ""
        currentIndex = defaults.object(forKey: Keys.currentIndex) as? Int ?? 0
        clampCurrentIndex()
    }

    func advance() {
        guard !lines.isEmpty else {
            reset()
            return
        }

        currentIndex = (currentIndex + 1) % lines.count
    }

    func reset() {
        currentIndex = 0
    }

    func clear() {
        note = ""
        currentIndex = 0
    }

    private func clampCurrentIndex() {
        guard !lines.isEmpty else {
            currentIndex = 0
            return
        }

        if currentIndex >= lines.count {
            currentIndex = 0
        }
    }
}

private enum Keys {
    static let note = "dot.savedNote"
    static let currentIndex = "dot.currentLineIndex"
}
