import SwiftUI

struct UsageView: View {
    @EnvironmentObject private var store: AtelierStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Usage")
                            .font(.title3.weight(.semibold))
                        Text("Cost, token, model, and runtime records from Boop model calls.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button {
                        Task { await store.loadUsage() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.plain)
                    .help("Refresh")
                }

                if store.isLoadingUsage && store.usageRecords.isEmpty && store.usageSummary == nil {
                    ProgressView("Loading usage...")
                        .frame(maxWidth: .infinity, minHeight: 240)
                } else if store.usageRecords.isEmpty && store.usageSummary == nil {
                    EmptyStateView(
                        title: "No usage records",
                        message: "Boop will add rows here after model calls run through the agent backend."
                    )
                    .frame(maxWidth: .infinity, minHeight: 260)
                } else {
                    UsageSummarySection(summary: store.usageSummary, records: store.usageRecords)
                    UsageSourceSection(summary: store.usageSummary)
                    UsageRecordsSection(records: store.usageRecords)
                }
            }
            .padding(24)
        }
        .scrollContentBackground(.hidden)
        .task {
            if store.usageRecords.isEmpty && store.usageSummary == nil {
                await store.loadUsage()
            }
        }
    }
}

private struct UsageSummarySection: View {
    let summary: UsageSummary?
    let records: [UsageRecord]

    private var totalTokens: Int {
        records.reduce(0) { $0 + $1.inputTokens + $1.outputTokens }
    }

    private var averageDuration: Double {
        guard !records.isEmpty else { return 0 }
        let total = records.reduce(0) { $0 + $1.durationMs }
        return total / Double(records.count)
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 12)], spacing: 12) {
            MetricTile(
                title: "Total cost",
                value: AtelierFormatters.currency(summary?.totalCost ?? records.reduce(0) { $0 + $1.costUsd }),
                footnote: "\(summary?.rowCount ?? records.count) scanned rows",
                systemImage: "creditcard"
            )
            MetricTile(
                title: "Recent tokens",
                value: AtelierFormatters.compactNumber(totalTokens),
                footnote: "Input plus output",
                systemImage: "sum"
            )
            MetricTile(
                title: "Model calls",
                value: AtelierFormatters.compactNumber(records.count),
                footnote: "Recent records loaded",
                systemImage: "cpu"
            )
            MetricTile(
                title: "Avg duration",
                value: AtelierFormatters.duration(milliseconds: averageDuration),
                footnote: "Recent calls",
                systemImage: "timer"
            )
        }
    }
}

private struct UsageSourceSection: View {
    let summary: UsageSummary?

    private var rows: [UsageSourceRow] {
        (summary?.bySource ?? [:])
            .map { UsageSourceRow(source: $0.key, summary: $0.value) }
            .sorted { $0.summary.costUsd > $1.summary.costUsd }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("By Source")
                .font(.headline)

            if rows.isEmpty {
                Text("No source summary loaded.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            } else {
                VStack(spacing: 8) {
                    ForEach(rows) { row in
                        HStack(spacing: 10) {
                            SoftPill(text: row.sourceLabel)
                            Text(AtelierFormatters.currency(row.summary.costUsd))
                                .font(.callout.weight(.semibold))
                                .monospacedDigit()

                            Spacer()

                            Label(AtelierFormatters.compactNumber(row.summary.inputTokens + row.summary.outputTokens), systemImage: "sum")
                            Label("\(row.summary.count)", systemImage: "number")
                        }
                        .font(.caption)
                        .padding(12)
                        .background(AtelierColors.softFill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
        }
    }
}

private struct UsageRecordsSection: View {
    let records: [UsageRecord]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Calls")
                .font(.headline)

            if records.isEmpty {
                Text("No recent calls loaded.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            } else {
                VStack(spacing: 10) {
                    ForEach(records) { record in
                        UsageRow(record: record)
                    }
                }
            }
        }
    }
}

private struct UsageRow: View {
    let record: UsageRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                SoftPill(text: record.source.replacingOccurrences(of: "-", with: " "))
                Text(record.model)
                    .font(.callout.weight(.medium))
                    .lineLimit(1)
                Spacer()
                Text(AtelierFormatters.currency(record.costUsd))
                    .font(.callout.weight(.semibold))
                    .monospacedDigit()
            }

            HStack(spacing: 14) {
                if let runtime = record.runtime {
                    Label(runtime.capitalized, systemImage: "cpu")
                }
                if let billingMode = record.billingMode {
                    Label(billingMode.replacingOccurrences(of: "-", with: " "), systemImage: "creditcard")
                }
                Label(AtelierFormatters.compactNumber(record.inputTokens + record.outputTokens), systemImage: "sum")
                Label(AtelierFormatters.duration(milliseconds: record.durationMs), systemImage: "timer")
                Spacer()
                Text(AtelierFormatters.relativeTime(milliseconds: record.createdAt))
            }
            .font(.caption)
            .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(AtelierColors.softFill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct UsageSourceRow: Identifiable {
    let source: String
    let summary: UsageSourceSummary

    var id: String { source }

    var sourceLabel: String {
        source.replacingOccurrences(of: "-", with: " ")
    }
}
