import SwiftUI

struct ActivityView: View {
    @EnvironmentObject private var store: AtelierStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                StatusDot(state: store.backendState)
                Text(store.backendState.isOnline ? "Waiting for activity" : "Backend offline")
                    .font(.headline)
            }

            Text(activityMessage)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 460, alignment: .leading)

            if let error = store.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .textSelection(.enabled)
            }

            Spacer()
        }
        .padding(24)
        .task {
            await store.refreshBackendStatus()
        }
    }

    private var activityMessage: String {
        if store.backendState.isOnline {
            return "No live events yet."
        }

        return "Start Boop to load live activity."
    }
}
