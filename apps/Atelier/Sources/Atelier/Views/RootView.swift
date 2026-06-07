import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: AtelierStore

    var body: some View {
        ZStack {
            AtelierColors.windowBackground
                .ignoresSafeArea()

            HStack(spacing: 0) {
                MainRailView(selection: $store.selectedRoute)
                    .frame(width: 58)
                    .padding(.leading, 8)
                    .padding(.top, 40)
                    .padding(.bottom, 8)

                SubtabSidebarView(mainTab: store.selectedRoute.mainTab, selection: $store.selectedRoute)
                    .frame(width: 240)

                ContentShellView(route: store.selectedRoute)
                    .padding(.trailing, 14)
                    .padding(.vertical, 14)
            }
            .ignoresSafeArea(.container, edges: .top)
        }
    }
}

private struct ContentShellView: View {
    let route: AtelierRoute

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            BreadcrumbView(route: route)

            DetailCard {
                DetailView(route: route)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.leading, 14)
    }
}

private struct BreadcrumbView: View {
    let route: AtelierRoute

    var body: some View {
        HStack(spacing: 7) {
            Text(route.mainTab.title)
                .foregroundStyle(.secondary)
            Image(systemName: "chevron.right")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.tertiary)
            Text(route.title)
                .foregroundStyle(.primary)
        }
        .font(.callout)
        .padding(.top, 2)
        .padding(.horizontal, 2)
    }
}

private struct DetailCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(AtelierColors.card)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AtelierColors.cardStroke, lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.03), radius: 18, x: 0, y: 10)
    }
}

private struct DetailView: View {
    let route: AtelierRoute

    var body: some View {
        switch route {
        case .chat:
            ChatView()
        case .activity:
            ActivityView()
        case .memory:
            MemoryView()
        case .automations:
            AutomationsView()
        case .connections:
            ConnectionsView()
        case .status:
            StatusView()
        case .settings:
            AppSettingsView()
        }
    }
}
