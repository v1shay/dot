import SwiftUI

struct DotPopoverView: View {
    @ObservedObject var store: NoteStore
    @FocusState private var isEditorFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            TextEditor(text: $store.note)
                .font(.system(.body, design: .rounded))
                .scrollContentBackground(.hidden)
                .focused($isEditorFocused)
                .padding(10)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(.white.opacity(0.16))
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
            ZStack {
                Circle()
                    .fill(.primary.opacity(0.12))
                    .frame(width: 28, height: 28)
                Circle()
                    .fill(.primary)
                    .frame(width: 8, height: 8)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(store.currentLine)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text("\(store.lines.count) lines")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
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

            Text("Option + `")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(.thinMaterial, in: Capsule())
        }
        .controlSize(.small)
    }
}
