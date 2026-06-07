import SwiftUI

struct MainRailView: View {
    @Binding var selection: AtelierRoute

    private var primaryTabs: [AtelierMainTab] {
        AtelierMainTab.allCases.filter { $0 != .settings }
    }

    var body: some View {
        VStack(spacing: 12) {
            RailLogo()
                .padding(.top, 46)
                .padding(.bottom, 4)

            ForEach(primaryTabs) { tab in
                RailTabButton(
                    tab: tab,
                    isSelected: selection.mainTab == tab,
                    action: { select(tab) }
                )
            }

            Spacer()

            RailTabButton(
                tab: .settings,
                isSelected: selection.mainTab == .settings,
                action: { select(.settings) }
            )
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AtelierColors.rail)
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        .shadow(color: .black.opacity(0.10), radius: 14, x: 0, y: 8)
    }

    private func select(_ tab: AtelierMainTab) {
        guard let firstRoute = tab.routes.first else { return }
        selection = firstRoute
    }
}

private struct RailLogo: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.white)
            Image(systemName: "sparkles")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(AtelierColors.rail)
        }
        .frame(width: 34, height: 34)
        .accessibilityLabel("Atelier")
    }
}

private struct RailTabButton: View {
    let tab: AtelierMainTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: tab.systemImage)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 38, height: 38)
                .foregroundStyle(isSelected ? .white : .white.opacity(0.68))
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                            .fill(.white.opacity(0.14))
                    }
                }
                .contentShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
        }
        .buttonStyle(.plain)
        .help(tab.title)
        .accessibilityLabel(tab.title)
    }
}

struct SubtabSidebarView: View {
    @EnvironmentObject private var store: AtelierStore

    let mainTab: AtelierMainTab
    @Binding var selection: AtelierRoute

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(mainTab.title)
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.horizontal, 18)
                .padding(.top, 22)
                .padding(.bottom, 14)

            ForEach(mainTab.sections) { section in
                if let title = section.title {
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 18)
                        .padding(.top, 12)
                        .padding(.bottom, 6)
                }

                VStack(spacing: 3) {
                    ForEach(section.routes) { route in
                        SubtabRow(
                            route: route,
                            count: countText(for: route),
                            isSelected: selection == route,
                            action: { selection = route }
                        )
                    }
                }
                .padding(.horizontal, 10)

                if section.id != mainTab.sections.last?.id {
                    Divider()
                        .overlay(AtelierColors.separator)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                }
            }

            Spacer()

            BackendMiniStatus()
                .padding(14)
        }
        .frame(maxHeight: .infinity)
        .background(AtelierColors.windowBackground)
    }

    private func countText(for route: AtelierRoute) -> String? {
        switch route {
        case .chat:
            store.messages.isEmpty ? nil : "\(store.messages.count)"
        case .activity:
            nil
        case .memory:
            "\(store.memories.count)"
        case .automations:
            "\(store.automations.filter(\.enabled).count)"
        case .connections:
            "\(store.toolkits.filter { !$0.connections.isEmpty }.count)"
        case .status:
            store.backendState.label
        case .settings:
            nil
        }
    }
}

private struct SubtabRow: View {
    let route: AtelierRoute
    let count: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: route.systemImage)
                    .font(.system(size: 13, weight: .medium))
                    .frame(width: 18)
                    .foregroundStyle(.secondary)

                Text(route.title)
                    .font(.callout)
                    .foregroundStyle(.primary)

                Spacer()

                if let count {
                    Text(count)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
            }
            .padding(.horizontal, 10)
            .frame(height: 30)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(AtelierColors.selectedSubtab)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct BackendMiniStatus: View {
    @EnvironmentObject private var store: AtelierStore

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                StatusDot(state: store.backendState)
                Text(store.backendState.label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    Task { await store.refreshBackendStatus() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .help("Refresh backend status")
            }

            if let runtime = store.runtimeConfig {
                Text("\(runtime.runtime) · \(runtime.model)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
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
