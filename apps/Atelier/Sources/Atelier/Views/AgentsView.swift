import SwiftUI

struct AgentsView: View {
    @EnvironmentObject private var store: AtelierStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Agents")
                        .font(.title3.weight(.semibold))
                    Spacer()
                    Button {
                        Task { await store.loadAgents() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.plain)
                    .help("Refresh")
                }

                if store.isLoadingAgents && store.agents.isEmpty {
                    ProgressView("Loading agents...")
                        .frame(maxWidth: .infinity, minHeight: 240)
                } else if store.agents.isEmpty {
                    EmptyStateView(title: "No agents yet", message: "Recent agent work will appear here.")
                        .frame(maxWidth: .infinity, minHeight: 260)
                } else {
                    VStack(spacing: 10) {
                        ForEach(store.agents) { agent in
                            AgentRow(agent: agent)
                        }
                    }
                }
            }
            .padding(24)
        }
        .scrollContentBackground(.hidden)
        .task {
            if store.agents.isEmpty {
                await store.loadAgents()
            }
        }
    }
}

private struct AgentRow: View {
    let agent: ExecutionAgent

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(agent.name)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                SoftPill(text: agent.status.capitalized, tone: tone)
            }

            Text(agent.task)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack(spacing: 12) {
                if let runtime = agent.runtime {
                    Label(runtime.capitalized, systemImage: "cpu")
                }
                Label(AtelierFormatters.compactNumber(agent.inputTokens + agent.outputTokens), systemImage: "sum")
                Label(AtelierFormatters.currency(agent.costUsd), systemImage: "creditcard")
                Spacer()
                Text(AtelierFormatters.relativeTime(milliseconds: agent.startedAt))
            }
            .font(.caption)
            .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(AtelierColors.softFill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var tone: SoftPill.Tone {
        switch agent.status {
        case "completed": .good
        case "failed", "cancelled": .bad
        case "running", "spawned": .warning
        default: .neutral
        }
    }
}
