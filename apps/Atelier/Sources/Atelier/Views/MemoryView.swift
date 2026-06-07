import SwiftUI

struct MemoryView: View {
    @EnvironmentObject private var store: AtelierStore

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                title: "Memory",
                subtitle: "\(store.memories.count) active records"
            )

            Divider()

            if store.isLoadingMemory {
                ProgressView("Loading memory…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if store.memories.isEmpty {
                EmptyStateView(
                    title: "No active memory loaded",
                    message: "Start Boop and refresh after it has written memories to Convex."
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(store.memories) { memory in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(memory.tier.capitalized)
                            Text(memory.segment.capitalized)
                            Text(String(format: "%.2f", memory.importance))
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)

                        Text(memory.content)
                            .textSelection(.enabled)

                        Text("Created \(AtelierFormatters.shortDate(milliseconds: memory.createdAt))")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .toolbar {
            Button {
                Task { await store.loadMemory() }
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
        }
        .task {
            if store.memories.isEmpty {
                await store.loadMemory()
            }
        }
    }
}
