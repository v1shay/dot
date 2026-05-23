import SwiftUI

struct DotPopoverView: View {
    @ObservedObject var store: NoteStore
    @FocusState private var isEditorFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            HStack(spacing: 10) {
                noteList
                editor
            }

            footer
        }
        .padding(16)
        .background(.regularMaterial)
        .onAppear {
            isEditorFocused = true
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(nsImage: NSImage.dotLogo(size: NSSize(width: 30, height: 30)) ?? NSImage())
                .resizable()
                .frame(width: 30, height: 30)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(store.selectedNoteTitle)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text("\(store.notes.count) notes / \(store.lines.count) lines")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    private var noteList: some View {
        VStack(spacing: 8) {
            List(selection: $store.selectedNoteID) {
                ForEach(store.notes) { note in
                    Text(note.title)
                        .lineLimit(1)
                        .tag(note.id)
                }
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)

            HStack(spacing: 6) {
                Button {
                    store.addNote()
                    isEditorFocused = true
                } label: {
                    Image(systemName: "plus")
                }
                .help("New note")

                Button(role: .destructive) {
                    store.deleteSelectedNote()
                } label: {
                    Image(systemName: "trash")
                }
                .help("Delete note")
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .frame(width: 116)
    }

    private var editor: some View {
        TextEditor(text: Binding(
            get: { store.selectedNoteBody },
            set: { store.selectedNoteBody = $0 }
        ))
        .font(.system(.body, design: .rounded))
        .scrollContentBackground(.hidden)
        .focused($isEditorFocused)
        .padding(10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(.white.opacity(0.16))
        }
    }

    private var footer: some View {
        HStack(spacing: 8) {
            Button {
                store.reset()
            } label: {
                Label("Reset", systemImage: "backward.end.fill")
            }
            .buttonStyle(.bordered)
            .help("Return to the first line")

            Button(role: .destructive) {
                store.clear()
            } label: {
                Label("Clear", systemImage: "trash")
            }
            .buttonStyle(.bordered)
            .help("Delete the saved note")

            Spacer()

            Text("Option + ` cycle / Option + H hide")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .controlSize(.small)
    }
}
