import SwiftUI

struct MainRailView: View {
    @Binding var selection: AtelierRoute
    let sidePaneRoute: AtelierRoute?
    let openPane: (AtelierRoute) -> Void

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
                    isPaneActive: sidePaneRoute?.mainTab == tab,
                    action: { select(tab) },
                    paneAction: { openPaneFor(tab) }
                )
            }

            Spacer()

            RailTabButton(
                tab: .settings,
                isSelected: selection.mainTab == .settings,
                isPaneActive: sidePaneRoute?.mainTab == .settings,
                action: { select(.settings) },
                paneAction: { openPaneFor(.settings) }
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

    private func openPaneFor(_ tab: AtelierMainTab) {
        guard let firstRoute = tab.routes.first else { return }
        openPane(firstRoute)
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
    let isPaneActive: Bool
    let action: () -> Void
    let paneAction: () -> Void

    @State private var isHovered = false
    @State private var isPaneHovered = false

    private var isExpanded: Bool {
        isHovered || isPaneHovered
    }

    private var showsPaneButton: Bool {
        isExpanded || isPaneActive
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: action) {
                ZStack {
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(backgroundOpacity)
                        .frame(width: isExpanded ? 42 : 38, height: isExpanded ? 42 : 38)

                    Image(systemName: tab.systemImage)
                        .font(.system(size: isExpanded ? 17 : 16, weight: .semibold))
                        .frame(width: 38, height: 38)
                        .foregroundStyle(isSelected ? .white : .white.opacity(isExpanded ? 0.88 : 0.68))
                }
                .frame(width: 50, height: 48)
                .contentShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                .scaleEffect(isExpanded ? 1.03 : 1)
            }
            .buttonStyle(.plain)

            PaneHoverButton(
                style: .rail,
                isVisible: showsPaneButton,
                action: paneAction,
                onHoverChange: { isPaneHovered = $0 }
            )
            .offset(x: -3, y: 3)
        }
        .frame(width: 50, height: 48)
        .onHover { hovered in
            isHovered = hovered
        }
        .help(tab.title)
        .accessibilityLabel(tab.title)
        .animation(.spring(response: 0.20, dampingFraction: 0.78), value: isExpanded)
        .animation(.easeOut(duration: 0.14), value: isSelected)
    }

    private var backgroundOpacity: Color {
        if isSelected {
            return .white.opacity(isExpanded ? 0.18 : 0.14)
        }
        return .white.opacity(isExpanded ? 0.09 : 0)
    }
}

private struct PaneHoverButton: View {
    let style: PaneHoverIcon.Style
    let isVisible: Bool
    let action: () -> Void
    let onHoverChange: (Bool) -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            PaneHoverIcon(style: style)
                .scaleEffect(isHovered ? 1.10 : 1)
                .rotationEffect(.degrees(isVisible ? 0 : -6))
        }
        .buttonStyle(.plain)
        .opacity(isVisible ? 1 : 0)
        .scaleEffect(isVisible ? 1 : 0.76)
        .allowsHitTesting(isVisible)
        .onHover { hovered in
            isHovered = hovered
            onHoverChange(hovered)
        }
        .help("Open in side pane")
        .animation(.spring(response: 0.18, dampingFraction: 0.78), value: isHovered)
        .animation(.spring(response: 0.20, dampingFraction: 0.82), value: isVisible)
    }
}

private struct PaneHoverIcon: View {
    let style: Style

    enum Style {
        case rail
        case sidebar
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(background)
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(stroke, lineWidth: 1)
                }
                .shadow(color: shadow, radius: 4, x: 0, y: 2)

            Image(systemName: "sidebar.right")
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(foreground)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    private var size: CGFloat {
        switch style {
        case .rail:
            18
        case .sidebar:
            21
        }
    }

    private var iconSize: CGFloat {
        switch style {
        case .rail:
            8
        case .sidebar:
            9
        }
    }

    private var cornerRadius: CGFloat {
        switch style {
        case .rail:
            5
        case .sidebar:
            6
        }
    }

    private var background: Color {
        switch style {
        case .rail:
            .white
        case .sidebar:
            .white.opacity(0.82)
        }
    }

    private var stroke: Color {
        switch style {
        case .rail:
            .white.opacity(0.20)
        case .sidebar:
            .black.opacity(0.06)
        }
    }

    private var shadow: Color {
        switch style {
        case .rail:
            .black.opacity(0.16)
        case .sidebar:
            .black.opacity(0.04)
        }
    }

    private var foreground: Color {
        switch style {
        case .rail:
            AtelierColors.rail
        case .sidebar:
            .secondary
        }
    }
}

struct SubtabSidebarView: View {
    @EnvironmentObject private var store: AtelierStore

    let mainTab: AtelierMainTab
    @Binding var selection: AtelierRoute
    let sidePaneRoute: AtelierRoute?
    let openPane: (AtelierRoute) -> Void

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
                            isPaneActive: sidePaneRoute == route,
                            action: { selection = route },
                            paneAction: { openPane(route) }
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
        case .overview:
            return nil
        case .chat:
            return store.messages.isEmpty ? nil : "\(store.messages.count)"
        case .agents:
            let running = store.agents.filter { $0.status == "running" || $0.status == "spawned" }.count
            return running > 0 ? "\(running)" : "\(store.agents.count)"
        case .activity:
            return nil
        case .events:
            return store.memoryEvents.isEmpty ? nil : "\(store.memoryEvents.count)"
        case .usage:
            return store.usageSummary.map { AtelierFormatters.currency($0.totalCost) }
        case .memory:
            return "\(store.memories.count)"
        case .automations:
            return "\(store.automations.filter(\.enabled).count)"
        case .drafts:
            let pending = store.drafts.filter { $0.status == "pending" }.count
            return pending > 0 ? "\(pending)" : nil
        case .consolidation:
            return store.consolidationRuns.isEmpty ? nil : "\(store.consolidationRuns.count)"
        case .connections:
            return "\(store.toolkits.filter { !$0.connections.isEmpty }.count)"
        case .browser:
            return store.browserStatus?.running == true ? "On" : nil
        case .status:
            return store.backendState.label
        case .settings:
            return nil
        case .changelog:
            return store.changelog?.version
        }
    }
}

private struct SubtabRow: View {
    let route: AtelierRoute
    let count: String?
    let isSelected: Bool
    let isPaneActive: Bool
    let action: () -> Void
    let paneAction: () -> Void

    @State private var isHovered = false
    @State private var isPaneHovered = false

    private var isExpanded: Bool {
        isHovered || isPaneHovered
    }

    private var showsPaneButton: Bool {
        isExpanded || isPaneActive
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            Button(action: action) {
                HStack(spacing: 10) {
                    Image(systemName: route.systemImage)
                        .font(.system(size: 13, weight: .medium))
                        .frame(width: 18)
                        .foregroundStyle(isSelected ? .primary : .secondary)
                        .scaleEffect(isExpanded ? 1.05 : 1)

                    Text(route.title)
                        .font(.callout)
                        .foregroundStyle(.primary)
                        .offset(x: isExpanded ? 1 : 0)

                    Spacer()

                    if let count {
                        Text(count)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .opacity(isExpanded ? 0.72 : 1)
                    }

                    Color.clear
                        .frame(width: showsPaneButton ? 24 : 0)
                }
                .padding(.horizontal, 10)
                .frame(height: 30)
                .background {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(rowBackground)
                }
                .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .scaleEffect(isExpanded ? 1.01 : 1, anchor: .center)
            }
            .buttonStyle(.plain)

            PaneHoverButton(
                style: .sidebar,
                isVisible: showsPaneButton,
                action: paneAction,
                onHoverChange: { isPaneHovered = $0 }
            )
            .padding(.trailing, 8)
        }
        .onHover { hovered in
            isHovered = hovered
        }
        .animation(.spring(response: 0.20, dampingFraction: 0.86), value: isExpanded)
        .animation(.easeOut(duration: 0.14), value: isSelected)
    }

    private var rowBackground: Color {
        if isSelected {
            return Color.black.opacity(isExpanded ? 0.085 : 0.06)
        }
        return Color.black.opacity(isExpanded ? 0.04 : 0)
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
