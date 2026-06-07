import SwiftUI

struct SidebarView: View {
    @EnvironmentObject private var store: AtelierStore
    @Binding var selection: AtelierRoute

    var body: some View {
        List(selection: $selection) {
            Section("Atelier") {
                ForEach(AtelierRoute.allCases) { route in
                    Label(route.title, systemImage: route.systemImage)
                        .tag(route)
                }
            }

            Section("Backend") {
                HStack(spacing: 8) {
                    StatusDot(state: store.backendState)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.backendState.label)
                        if let runtime = store.runtimeConfig {
                            Text("\(runtime.runtime) · \(runtime.model)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Atelier")
        .toolbar {
            Button {
                Task { await store.refreshBackendStatus() }
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
        }
    }
}

struct StatusDot: View {
    let state: BackendState

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .accessibilityLabel(state.label)
    }

    private var color: Color {
        switch state {
        case .unknown: .yellow
        case .online: .green
        case .offline: .red
        }
    }
}
