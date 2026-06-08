import SwiftUI

struct DraftsView: View {
    @EnvironmentObject private var store: AtelierStore

    private var pendingCount: Int {
        store.drafts.filter { $0.status == "pending" }.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Drafts")
                            .font(.title3.weight(.semibold))
                        Text("Approval items Boop prepared before sending or taking action.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button {
                        Task { await store.loadDrafts() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.plain)
                    .help("Refresh")
                }

                if store.isLoadingDrafts && store.drafts.isEmpty {
                    ProgressView("Loading drafts...")
                        .frame(maxWidth: .infinity, minHeight: 240)
                } else if store.drafts.isEmpty {
                    EmptyStateView(
                        title: "No drafts",
                        message: "Drafted replies and approval items will appear here after Boop creates them."
                    )
                    .frame(maxWidth: .infinity, minHeight: 260)
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 12)], spacing: 12) {
                        MetricTile(
                            title: "Pending",
                            value: "\(pendingCount)",
                            footnote: "Waiting for review",
                            systemImage: "tray"
                        )
                        MetricTile(
                            title: "Recent drafts",
                            value: "\(store.drafts.count)",
                            footnote: "Latest rows loaded",
                            systemImage: "doc.text"
                        )
                    }

                    VStack(spacing: 10) {
                        ForEach(store.drafts) { draft in
                            DraftRow(draft: draft)
                        }
                    }
                }
            }
            .padding(24)
        }
        .scrollContentBackground(.hidden)
        .task {
            if store.drafts.isEmpty {
                await store.loadDrafts()
            }
        }
    }
}

private struct DraftRow: View {
    let draft: DraftRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                SoftPill(text: draft.status.capitalized, tone: tone)
                Text(draft.kind.capitalized)
                    .font(.callout.weight(.medium))
                Spacer()
                Text(AtelierFormatters.relativeTime(milliseconds: draft.createdAt))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Text(draft.summary)
                .font(.callout)
                .lineLimit(2)

            if !draft.payload.isEmpty {
                Text(draft.payload)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .lineLimit(4)
                    .textSelection(.enabled)
            }

            HStack(spacing: 12) {
                Label(AtelierFormatters.tail(draft.conversationId, count: 8) ?? draft.conversationId, systemImage: "bubble.left")
                Label(AtelierFormatters.tail(draft.draftId, count: 8) ?? draft.draftId, systemImage: "doc")
                if let decidedAt = draft.decidedAt {
                    Label(AtelierFormatters.relativeTime(milliseconds: decidedAt), systemImage: "checkmark.circle")
                }
                Spacer()
            }
            .font(.caption)
            .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(AtelierColors.softFill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var tone: SoftPill.Tone {
        switch draft.status {
        case "pending": .warning
        case "sent": .good
        case "rejected", "expired": .bad
        default: .neutral
        }
    }
}
