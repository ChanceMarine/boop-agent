import SwiftUI

struct ActivityView: View {
    @EnvironmentObject private var store: AtelierStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    StatusDot(state: store.backendState)
                    Text(store.backendState.isOnline ? "Live" : "Offline")
                        .font(.title3.weight(.semibold))
                    Spacer()
                    Button {
                        Task { await refresh() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.plain)
                    .help("Refresh")
                }

                let items = activityItems
                if items.isEmpty {
                    EmptyStateView(title: "No recent activity", message: "Recent agent and workflow updates will appear here.")
                        .frame(maxWidth: .infinity, minHeight: 260)
                } else {
                    VStack(spacing: 8) {
                        ForEach(items) { item in
                            HStack(spacing: 10) {
                                Image(systemName: item.systemImage)
                                    .frame(width: 26, height: 26)
                                    .background(AtelierColors.softFill, in: Circle())
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(item.title)
                                        .font(.callout.weight(.medium))
                                        .lineLimit(1)
                                    Text(item.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                                Spacer()
                                Text(AtelierFormatters.relativeTime(milliseconds: item.createdAt))
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(12)
                            .background(AtelierColors.softFill, in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
            .padding(24)
        }
        .scrollContentBackground(.hidden)
        .task {
            await refresh()
        }
    }

    private var activityItems: [ActivityItem] {
        let agentItems = store.agents.prefix(8).map {
            ActivityItem(
                title: $0.name,
                subtitle: $0.status.capitalized,
                createdAt: $0.completedAt ?? $0.startedAt,
                systemImage: "cpu"
            )
        }
        let automationItems = store.automations.prefix(5).map {
            ActivityItem(
                title: $0.name,
                subtitle: $0.enabled ? "Enabled" : "Paused",
                createdAt: $0.lastRunAt ?? $0.createdAt,
                systemImage: "clock.arrow.circlepath"
            )
        }
        let consolidationItems = store.consolidationRuns.prefix(5).map {
            ActivityItem(
                title: "Consolidation",
                subtitle: $0.status.capitalized,
                createdAt: $0.completedAt ?? $0.startedAt,
                systemImage: "arrow.triangle.merge"
            )
        }
        let eventItems = store.memoryEvents.prefix(8).map {
            ActivityItem(
                title: $0.eventType,
                subtitle: $0.data.isEmpty ? "Memory event" : $0.data,
                createdAt: $0.createdAt,
                systemImage: "bolt.horizontal.circle"
            )
        }

        return (agentItems + automationItems + consolidationItems + eventItems)
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(12)
            .map { $0 }
    }

    private func refresh() async {
        await store.refreshBackendStatus()
        await store.loadAgents()
        await store.loadAutomations()
        await store.loadConsolidation()
        await store.loadEvents()
    }
}

private struct ActivityItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let createdAt: Double
    let systemImage: String
}
