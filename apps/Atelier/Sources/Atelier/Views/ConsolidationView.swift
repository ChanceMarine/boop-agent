import SwiftUI

struct ConsolidationView: View {
    @EnvironmentObject private var store: AtelierStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Consolidation")
                        .font(.title3.weight(.semibold))
                    Spacer()
                    Button {
                        Task { await store.loadConsolidation() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.plain)
                    .help("Refresh")
                }

                if store.isLoadingConsolidation && store.consolidationRuns.isEmpty {
                    ProgressView("Loading runs...")
                        .frame(maxWidth: .infinity, minHeight: 240)
                } else if store.consolidationRuns.isEmpty {
                    EmptyStateView(title: "No consolidation runs", message: "Memory cleanup runs will appear here.")
                        .frame(maxWidth: .infinity, minHeight: 260)
                } else {
                    VStack(spacing: 10) {
                        ForEach(store.consolidationRuns) { run in
                            ConsolidationRunRow(run: run)
                        }
                    }
                }
            }
            .padding(24)
        }
        .scrollContentBackground(.hidden)
        .task {
            if store.consolidationRuns.isEmpty {
                await store.loadConsolidation()
            }
        }
    }
}

private struct ConsolidationRunRow: View {
    let run: ConsolidationRun

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                SoftPill(text: run.status.capitalized, tone: tone)
                Text(run.trigger.capitalized)
                    .font(.callout.weight(.medium))
                Spacer()
                Text(AtelierFormatters.relativeTime(milliseconds: run.startedAt))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            HStack(spacing: 18) {
                Stat(label: "Proposed", value: run.proposalsCount)
                Stat(label: "Merged", value: run.mergedCount)
                Stat(label: "Pruned", value: run.prunedCount)
                Spacer()
            }

            if let notes = run.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(14)
        .background(AtelierColors.softFill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var tone: SoftPill.Tone {
        switch run.status {
        case "completed": .good
        case "failed": .bad
        case "running": .warning
        default: .neutral
        }
    }
}

private struct Stat: View {
    let label: String
    let value: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(value)")
                .font(.headline)
                .monospacedDigit()
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
