import SwiftUI

struct StatusView: View {
    @EnvironmentObject private var store: AtelierStore

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(spacing: 10) {
                StatusDot(state: store.backendState)
                Text(store.backendState.label)
                    .font(.title3.weight(.semibold))

                Spacer()

                Button {
                    Task { await store.refreshBackendStatus() }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                StatusRow(label: "Boop", value: store.boopBaseURLString)
                StatusRow(label: "Convex", value: store.convexURLString)

                if let runtime = store.runtimeConfig {
                    StatusRow(label: "Runtime", value: runtime.runtime)
                    StatusRow(label: "Model", value: runtime.model)
                    StatusRow(label: "Billing", value: runtime.billingMode)
                }
            }

            if let error = store.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }

            Spacer()
        }
        .padding(24)
        .task {
            await store.refreshBackendStatus()
        }
    }
}

private struct StatusRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .foregroundStyle(.secondary)
                .frame(width: 76, alignment: .leading)
            Text(value)
                .textSelection(.enabled)
            Spacer()
        }
        .font(.callout)
    }
}
