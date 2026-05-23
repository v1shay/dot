import Foundation

struct DotNote: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var body: String

    init(id: UUID = UUID(), title: String, body: String = "") {
        self.id = id
        self.title = title
        self.body = body
    }
}

@MainActor
final class NoteStore: ObservableObject {
    @Published var notes: [DotNote] {
        didSet {
            saveNotes()
            clampCurrentIndex()
            clampSelectedNote()
        }
    }

    @Published var selectedNoteID: DotNote.ID {
        didSet {
            defaults.set(selectedNoteID.uuidString, forKey: Keys.selectedNoteID)
            clampCurrentIndex()
        }
    }

    @Published private(set) var currentIndex: Int {
        didSet {
            defaults.set(currentIndex, forKey: Keys.currentIndex)
        }
    }

    private let defaults: UserDefaults

    var selectedNote: DotNote {
        notes.first { $0.id == selectedNoteID } ?? notes[0]
    }

    var selectedNoteTitle: String {
        selectedNote.title
    }

    var selectedNoteBody: String {
        get {
            selectedNote.body
        }
        set {
            let fallbackNumber = notes.count
            updateSelectedNote { note in
                note.body = newValue
                note.title = Self.title(for: newValue, fallbackNumber: fallbackNumber)
            }
        }
    }

    var lines: [String] {
        selectedNote.body
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

    var compactMenuBarTitle: String {
        let line = currentLine
        guard line != "Dot" else { return "DOT" }

        let trimmed = line
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        let firstWord = trimmed.split(whereSeparator: { $0.isWhitespace }).first.map(String.init) ?? "DOT"
        let source = firstWord.isEmpty ? "DOT" : firstWord
        let label = "\(min(currentIndex + 1, max(lines.count, 1))) \(source)"

        return label.count > 11 ? String(label.prefix(10)) + "..." : label
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let loadedNotes = Self.loadNotes(from: defaults)
        notes = loadedNotes
        let savedSelectedID = defaults.string(forKey: Keys.selectedNoteID).flatMap(UUID.init(uuidString:))
        selectedNoteID = savedSelectedID ?? loadedNotes[0].id
        currentIndex = defaults.object(forKey: Keys.currentIndex) as? Int ?? 0
        clampSelectedNote()
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

    func addNote() {
        let note = DotNote(title: "Untitled")
        notes.insert(note, at: 0)
        selectedNoteID = note.id
        currentIndex = 0
    }

    func deleteSelectedNote() {
        guard notes.count > 1 else {
            clear()
            return
        }

        notes.removeAll { $0.id == selectedNoteID }
        selectedNoteID = notes[0].id
        currentIndex = 0
    }

    func clear() {
        updateSelectedNote { note in
            note.body = ""
            note.title = "Untitled"
        }
        currentIndex = 0
    }

    private func updateSelectedNote(_ update: (inout DotNote) -> Void) {
        guard let index = notes.firstIndex(where: { $0.id == selectedNoteID }) else {
            return
        }

        update(&notes[index])
    }

    private func clampSelectedNote() {
        if notes.isEmpty {
            notes = [DotNote(title: "Untitled")]
        }

        if !notes.contains(where: { $0.id == selectedNoteID }) {
            selectedNoteID = notes[0].id
        }
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

    private func saveNotes() {
        guard let data = try? JSONEncoder().encode(notes) else {
            return
        }

        defaults.set(data, forKey: Keys.notes)
    }

    private static func loadNotes(from defaults: UserDefaults) -> [DotNote] {
        if let data = defaults.data(forKey: Keys.notes),
           let notes = try? JSONDecoder().decode([DotNote].self, from: data),
           !notes.isEmpty {
            return notes
        }

        let legacyNote = defaults.string(forKey: Keys.legacyNote) ?? ""
        return [DotNote(title: title(for: legacyNote, fallbackNumber: 1), body: legacyNote)]
    }

    private static func title(for body: String, fallbackNumber: Int) -> String {
        let title = body
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty } ?? ""

        if title.isEmpty {
            return fallbackNumber <= 1 ? "Untitled" : "Untitled \(fallbackNumber)"
        }

        return title.count > 32 ? String(title.prefix(31)) + "..." : title
    }
}

private enum Keys {
    static let notes = "dot.savedNotes"
    static let selectedNoteID = "dot.selectedNoteID"
    static let currentIndex = "dot.currentLineIndex"
    static let legacyNote = "dot.savedNote"
}
