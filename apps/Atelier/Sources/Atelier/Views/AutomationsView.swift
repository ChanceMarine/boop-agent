import SwiftUI

struct AutomationsView: View {
    @EnvironmentObject private var store: AtelierStore

    var body: some View {
        VStack(spacing: 0) {
            if store.isLoadingAutomations {
                ProgressView("Loading automations…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if store.automations.isEmpty {
                EmptyStateView(
                    title: "No automations yet",
                    message: "Create scheduled work from Boop, then use Atelier to monitor it."
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(store.automations) { automation in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(automation.name)
                                .font(.headline)
                            Spacer()
                            Text(automation.enabled ? "Enabled" : "Paused")
                                .font(.caption)
                                .foregroundStyle(automation.enabled ? .green : .secondary)
                        }
                        Text(automation.task)
                            .foregroundStyle(.primary)
                        HStack {
                            Text(automation.schedule)
                            Text("Next: \(AtelierFormatters.relativeTime(milliseconds: automation.nextRunAt))")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .task {
            if store.automations.isEmpty {
                await store.loadAutomations()
            }
        }
    }
}
