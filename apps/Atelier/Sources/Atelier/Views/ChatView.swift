import SwiftUI

struct ChatView: View {
    @EnvironmentObject private var store: AtelierStore
    @State private var draft = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    if store.messages.isEmpty {
                        EmptyStateView(
                            title: "Start a conversation",
                            message: "No messages in this thread yet."
                        )
                        .frame(maxWidth: .infinity, minHeight: 260)
                    } else {
                        ForEach(store.messages) { message in
                            MessageBubble(message: message)
                        }
                    }
                }
                .padding(24)
            }

            Rectangle()
                .fill(AtelierColors.separator)
                .frame(height: 1)

            ComposerView(
                text: $draft,
                isSending: store.isSending,
                isEnabled: store.backendState.isOnline,
                send: sendDraft
            )
            .padding()
        }
        .task {
            await store.refreshBackendStatus()
            await store.loadChatHistory()
        }
    }

    private func sendDraft() {
        let outgoing = draft
        draft = ""
        Task { await store.send(outgoing) }
    }
}

private struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == .user {
                Spacer(minLength: 80)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(message.role == .user ? "You" : "Boop")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(message.content)
                    .textSelection(.enabled)
            }
            .padding(12)
            .background(message.role == .user ? Color.accentColor.opacity(0.18) : Color.secondary.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .frame(maxWidth: 680, alignment: .leading)

            if message.role != .user {
                Spacer(minLength: 80)
            }
        }
    }
}

private struct ComposerView: View {
    @Binding var text: String
    let isSending: Bool
    let isEnabled: Bool
    let send: () -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            TextField("Message Boop…", text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...5)
                .padding(10)
                .background(.quaternary.opacity(0.45), in: RoundedRectangle(cornerRadius: 10))
                .onSubmit(send)

            Button(action: send) {
                if isSending {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Image(systemName: "arrow.up")
                }
            }
            .keyboardShortcut(.return, modifiers: [.command])
            .disabled(!isEnabled || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
        }
    }
}
