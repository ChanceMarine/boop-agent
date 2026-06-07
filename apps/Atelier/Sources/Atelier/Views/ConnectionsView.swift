import SwiftUI

struct ConnectionsView: View {
    @EnvironmentObject private var store: AtelierStore

    var connectedToolkits: [Toolkit] {
        store.toolkits.filter { !$0.connections.isEmpty }
    }

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                title: "Connections",
                subtitle: store.composioEnabled ? "\(connectedToolkits.count) connected toolkits" : "Composio disabled"
            )

            Divider()

            if store.isLoadingConnections {
                ProgressView("Loading connections…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if store.toolkits.isEmpty {
                EmptyStateView(
                    title: "No connection data",
                    message: "Start Boop with COMPOSIO_API_KEY configured, then refresh."
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(store.toolkits) { toolkit in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: toolkit.connections.isEmpty ? "link.badge.plus" : "link.circle.fill")
                            .foregroundStyle(toolkit.connections.isEmpty ? Color.secondary : Color.green)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(toolkit.displayName)
                                .font(.headline)
                            if let description = toolkit.description, !description.isEmpty {
                                Text(description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            if toolkit.connections.isEmpty {
                                Text("Not connected")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(toolkit.connections) { connection in
                                    Text(connection.displayLabel)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                        Spacer()

                        if let toolCount = toolkit.toolCount {
                            Text("\(toolCount) tools")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .toolbar {
            Button {
                Task { await store.loadConnections() }
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
        }
        .task {
            if store.toolkits.isEmpty {
                await store.loadConnections()
            }
        }
    }
}
