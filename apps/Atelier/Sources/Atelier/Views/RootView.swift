import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: AtelierStore

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $store.selectedRoute)
                .navigationSplitViewColumnWidth(min: 220, ideal: 250, max: 300)
        } detail: {
            DetailView(route: store.selectedRoute)
        }
    }
}

private struct DetailView: View {
    let route: AtelierRoute

    var body: some View {
        switch route {
        case .chat:
            ChatView()
        case .memory:
            MemoryView()
        case .automations:
            AutomationsView()
        case .connections:
            ConnectionsView()
        case .settings:
            AppSettingsView()
                .padding()
        }
    }
}
