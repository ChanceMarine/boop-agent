import SwiftUI

struct OverviewView: View {
    @EnvironmentObject private var store: AtelierStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if store.isLoadingDashboard && store.dashboardMetrics == nil {
                    ProgressView("Loading overview...")
                        .frame(maxWidth: .infinity, minHeight: 260)
                } else if let metrics = store.dashboardMetrics {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 12)], spacing: 12) {
                        MetricTile(
                            title: "Messages",
                            value: AtelierFormatters.compactNumber(metrics.messages),
                            footnote: "Saved chat history",
                            systemImage: "bubble.left.and.bubble.right"
                        )
                        MetricTile(
                            title: "Memory",
                            value: AtelierFormatters.compactNumber(metrics.memories.total),
                            footnote: "\(metrics.memories.permanent) permanent",
                            systemImage: "books.vertical"
                        )
                        MetricTile(
                            title: "Agents",
                            value: AtelierFormatters.compactNumber(metrics.agents.total),
                            footnote: "\(metrics.agents.running) running",
                            systemImage: "cpu"
                        )
                        MetricTile(
                            title: "Usage",
                            value: AtelierFormatters.currency(metrics.cost.total),
                            footnote: "\(AtelierFormatters.compactNumber(metrics.tokens.input + metrics.tokens.output)) tokens",
                            systemImage: "chart.line.uptrend.xyaxis"
                        )
                    }

                    if metrics.truncated {
                        SoftPill(text: "Showing latest \(AtelierFormatters.compactNumber(metrics.scanLimit)) rows", tone: .warning)
                    }
                } else {
                    EmptyStateView(title: "Overview unavailable", message: "Start Boop to load the latest summary.")
                        .frame(maxWidth: .infinity, minHeight: 260)
                }

                RecentWorkSection()
            }
            .padding(24)
        }
        .scrollContentBackground(.hidden)
        .task {
            await store.loadDashboard()
            await store.loadAgents()
        }
    }
}

private struct RecentWorkSection: View {
    @EnvironmentObject private var store: AtelierStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Work")
                .font(.headline)

            if store.agents.isEmpty {
                Text("No recent agents.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 8) {
                    ForEach(store.agents.prefix(5)) { agent in
                        HStack(spacing: 10) {
                            SoftPill(text: agent.status.capitalized, tone: tone(for: agent.status))
                            VStack(alignment: .leading, spacing: 3) {
                                Text(agent.name)
                                    .font(.callout.weight(.medium))
                                    .lineLimit(1)
                                Text(agent.task)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Text(AtelierFormatters.relativeTime(milliseconds: agent.startedAt))
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(12)
                        .background(AtelierColors.softFill, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
    }

    private func tone(for status: String) -> SoftPill.Tone {
        switch status {
        case "completed": .good
        case "failed", "cancelled": .bad
        case "running", "spawned": .warning
        default: .neutral
        }
    }
}
