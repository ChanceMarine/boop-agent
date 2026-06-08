import SwiftUI

struct EventsView: View {
    @EnvironmentObject private var store: AtelierStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Events")
                            .font(.title3.weight(.semibold))
                        Text("Memory writes, recalls, extraction, cleanup, and consolidation activity.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button {
                        Task { await store.loadEvents() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.plain)
                    .help("Refresh")
                }

                if store.isLoadingEvents && store.memoryEvents.isEmpty {
                    ProgressView("Loading events...")
                        .frame(maxWidth: .infinity, minHeight: 240)
                } else if store.memoryEvents.isEmpty {
                    EmptyStateView(
                        title: "No events yet",
                        message: "Once Boop writes, recalls, or consolidates memories, the event stream will appear here."
                    )
                    .frame(maxWidth: .infinity, minHeight: 260)
                } else {
                    VStack(spacing: 10) {
                        ForEach(store.memoryEvents) { event in
                            EventRow(event: event)
                        }
                    }
                }
            }
            .padding(24)
        }
        .scrollContentBackground(.hidden)
        .task {
            if store.memoryEvents.isEmpty {
                await store.loadEvents()
            }
        }
    }
}

private struct EventRow: View {
    let event: MemoryEventRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                SoftPill(text: event.eventType, tone: tone)

                if let conversationId = AtelierFormatters.tail(event.conversationId) {
                    Label(conversationId, systemImage: "bubble.left")
                }

                if let memoryId = AtelierFormatters.tail(event.memoryId) {
                    Label(memoryId, systemImage: "books.vertical")
                }

                if let agentId = AtelierFormatters.tail(event.agentId) {
                    Label(agentId, systemImage: "cpu")
                }

                Spacer()

                Text(AtelierFormatters.relativeTime(milliseconds: event.createdAt))
                    .foregroundStyle(.tertiary)
            }
            .font(.caption)

            if !event.data.isEmpty {
                Text(event.data)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .lineLimit(4)
                    .textSelection(.enabled)
            }
        }
        .padding(14)
        .background(AtelierColors.softFill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var tone: SoftPill.Tone {
        if event.eventType.contains("written") || event.eventType.contains("recalled") {
            return .good
        }
        if event.eventType.contains("consolidated") {
            return .warning
        }
        return .neutral
    }
}
