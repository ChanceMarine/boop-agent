import SwiftUI

struct ChatView: View {
    @EnvironmentObject private var store: AtelierStore
    @State private var draft = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        if store.messages.isEmpty {
                            ChatEmptyState(draft: $draft)
                                .frame(maxWidth: .infinity, minHeight: 360)
                        } else {
                            ForEach(store.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 28)
                    .padding(.bottom, 18)
                }
                .onChange(of: store.messages) { _, messages in
                    guard let last = messages.last else { return }
                    withAnimation(.easeOut(duration: 0.22)) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }

            ComposerView(
                text: $draft,
                isSending: store.isSending,
                isEnabled: store.backendState.isOnline,
                send: sendDraft
            )
            .padding(.horizontal, 22)
            .padding(.bottom, 18)
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

private struct ChatEmptyState: View {
    @Binding var draft: String

    private let suggestions = [
        "What should I focus on today?",
        "Check what needs follow-up.",
        "Help me plan the next step."
    ]

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 54, height: 54)
                .background(AtelierColors.softFill, in: RoundedRectangle(cornerRadius: 16))

            VStack(spacing: 5) {
                Text("Start a conversation")
                    .font(.title3.weight(.semibold))
                Text("Ask Boop for help with anything you want to track or get done.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 8)], spacing: 8) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button(suggestion) {
                        draft = suggestion
                    }
                    .buttonStyle(.plain)
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(AtelierColors.softFill, in: Capsule())
                }
            }
        }
        .frame(maxWidth: 620)
        .padding()
    }
}

private struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if message.role == .user {
                Spacer(minLength: 120)
            } else {
                Avatar(systemImage: "sparkles")
            }

            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 6) {
                    Text(message.role == .user ? "You" : "Boop")
                        .font(.caption.weight(.semibold))
                    Text(message.createdAt.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Text(message.content)
                    .font(.callout)
                    .lineSpacing(3)
                    .textSelection(.enabled)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .foregroundStyle(.primary)
            .background(background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(stroke, lineWidth: 1)
            }
            .frame(maxWidth: 700, alignment: .leading)

            if message.role == .user {
                Avatar(systemImage: "person.fill")
            } else {
                Spacer(minLength: 120)
            }
        }
    }

    private var background: Color {
        message.role == .user ? Color.black.opacity(0.05) : Color.white
    }

    private var stroke: Color {
        message.role == .user ? Color.clear : AtelierColors.separator
    }
}

private struct Avatar: View {
    let systemImage: String

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.secondary)
            .frame(width: 26, height: 26)
            .background(AtelierColors.softFill, in: Circle())
    }
}

private struct ComposerView: View {
    @Binding var text: String
    let isSending: Bool
    let isEnabled: Bool
    let send: () -> Void

    private var canSend: Bool {
        isEnabled && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSending
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("Message Boop", text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...6)
                .font(.callout)
                .padding(.vertical, 7)
                .onSubmit {
                    if canSend { send() }
                }

            if !isEnabled {
                SoftPill(text: "Offline", tone: .bad)
                    .padding(.bottom, 4)
            }

            Button(action: send) {
                ZStack {
                    Circle()
                        .fill(canSend ? AtelierColors.rail : Color.black.opacity(0.08))
                    if isSending {
                        ProgressView()
                            .controlSize(.small)
                            .tint(.white)
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(canSend ? .white : .secondary)
                    }
                }
                .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.return, modifiers: [.command])
            .disabled(!canSend)
        }
        .padding(14)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white, lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.04), radius: 16, x: 0, y: 8)
    }
}
