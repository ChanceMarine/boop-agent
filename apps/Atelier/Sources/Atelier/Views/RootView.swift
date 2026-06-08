import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: AtelierStore
    @AppStorage("atelier.subtabSidebarWidth") private var savedSidebarWidth = ShellMetrics.defaultSidebarWidth
    @AppStorage("atelier.subtabSidebarCollapsed") private var isSubtabSidebarCollapsed = false
    @State private var activeSidebarWidth: Double?
    @State private var dragStartSidebarWidth: Double?

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                AtelierColors.windowBackground
                    .ignoresSafeArea()

                HStack(spacing: 0) {
                    MainRailView(selection: $store.selectedRoute)
                        .frame(width: ShellMetrics.railWidth)
                        .padding(ShellMetrics.outerInset)

                    if currentSidebarWidth > 0.5 {
                        SubtabSidebarView(mainTab: store.selectedRoute.mainTab, selection: $store.selectedRoute)
                            .frame(width: max(currentSidebarWidth, ShellMetrics.minExpandedSidebarWidth), alignment: .leading)
                            .blur(radius: sidebarBlurRadius)
                            .opacity(sidebarContentOpacity)
                            .frame(width: currentSidebarWidth, alignment: .leading)
                            .clipped()
                            .allowsHitTesting(!shouldSoftenSidebar)
                    }

                    ContentShellView(route: store.selectedRoute, leadingPadding: contentLeadingPadding)
                        .padding(.trailing, 14)
                        .padding(.vertical, 14)
                }
                .ignoresSafeArea(.container, edges: .vertical)

                SidebarResizeHandle(collapseProgress: sidebarCollapseProgress)
                    .frame(width: ShellMetrics.handleHitWidth, height: ShellMetrics.handleHitHeight)
                    .position(x: handleCenterX, y: proxy.size.height / 2)
                    .gesture(sidebarResizeGesture)
                    .help("Drag to resize sidebar")
            }
        }
    }

    private var currentSidebarWidth: CGFloat {
        let rawWidth = activeSidebarWidth ?? (isSubtabSidebarCollapsed ? 0 : savedSidebarWidth)
        return min(max(CGFloat(rawWidth), 0), ShellMetrics.maxSidebarWidth)
    }

    private var sidebarCollapseProgress: CGFloat {
        guard currentSidebarWidth > 0 else { return 1 }
        let blurRange = ShellMetrics.blurStartWidth - ShellMetrics.collapseThresholdWidth
        guard blurRange > 0, currentSidebarWidth < ShellMetrics.blurStartWidth else { return 0 }
        return min(max((ShellMetrics.blurStartWidth - currentSidebarWidth) / blurRange, 0), 1)
    }

    private var sidebarBlurRadius: CGFloat {
        sidebarCollapseProgress * ShellMetrics.maxSidebarBlurRadius
    }

    private var sidebarContentOpacity: CGFloat {
        1 - (sidebarCollapseProgress * 0.28)
    }

    private var shouldSoftenSidebar: Bool {
        sidebarCollapseProgress > 0.12
    }

    private var contentLeadingPadding: CGFloat {
        guard currentSidebarWidth > 0 else { return ShellMetrics.collapsedContentLeading }
        let progress = min(currentSidebarWidth / ShellMetrics.collapseThresholdWidth, 1)
        return ShellMetrics.collapsedContentLeading
            + ((ShellMetrics.expandedContentLeading - ShellMetrics.collapsedContentLeading) * progress)
    }

    private var handleCenterX: CGFloat {
        if currentSidebarWidth <= 0.5 {
            return ShellMetrics.railWidth + ShellMetrics.outerInset + (ShellMetrics.outerInset / 2)
        }
        return ShellMetrics.railLayoutWidth + currentSidebarWidth
    }

    private var sidebarResizeGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if dragStartSidebarWidth == nil {
                    dragStartSidebarWidth = isSubtabSidebarCollapsed ? 0 : Double(currentSidebarWidth)
                }
                let startWidth = dragStartSidebarWidth ?? 0
                let proposedWidth = startWidth + value.translation.width
                activeSidebarWidth = min(max(proposedWidth, 0), Double(ShellMetrics.maxSidebarWidth))
            }
            .onEnded { value in
                let startWidth = dragStartSidebarWidth ?? (isSubtabSidebarCollapsed ? 0 : Double(currentSidebarWidth))
                let proposedWidth = startWidth + value.translation.width
                finishSidebarDrag(at: proposedWidth)
            }
    }

    private func finishSidebarDrag(at proposedWidth: Double) {
        let clampedWidth = min(max(CGFloat(proposedWidth), 0), ShellMetrics.maxSidebarWidth)
        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
            if clampedWidth < ShellMetrics.collapseThresholdWidth {
                isSubtabSidebarCollapsed = true
                activeSidebarWidth = nil
            } else {
                let expandedWidth = min(
                    max(clampedWidth, ShellMetrics.minExpandedSidebarWidth),
                    ShellMetrics.maxSidebarWidth
                )
                savedSidebarWidth = Double(expandedWidth)
                isSubtabSidebarCollapsed = false
                activeSidebarWidth = nil
            }
            dragStartSidebarWidth = nil
        }
    }
}

private enum ShellMetrics {
    static let outerInset: CGFloat = 4
    static let railWidth: CGFloat = 70
    static let railLayoutWidth: CGFloat = railWidth + (outerInset * 2)
    static let defaultSidebarWidth: Double = 240
    static let minExpandedSidebarWidth: CGFloat = 176
    static let maxSidebarWidth: CGFloat = 340
    static let blurStartWidth: CGFloat = 168
    static let collapseThresholdWidth: CGFloat = 112
    static let maxSidebarBlurRadius: CGFloat = 8
    static let collapsedContentLeading: CGFloat = 4
    static let expandedContentLeading: CGFloat = 14
    static let handleHitWidth: CGFloat = 24
    static let handleHitHeight: CGFloat = 112
}

private struct ContentShellView: View {
    let route: AtelierRoute
    let leadingPadding: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            BreadcrumbView(route: route)

            DetailCard {
                DetailView(route: route)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.leading, leadingPadding)
    }
}

private struct SidebarResizeHandle: View {
    let collapseProgress: CGFloat
    @State private var isHovered = false

    var body: some View {
        ZStack {
            Capsule()
                .fill(.black.opacity(lineOpacity))
                .frame(width: isHovered ? 4 : 3, height: 54)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onHover { hovered in
            isHovered = hovered
        }
        .accessibilityLabel("Resize sidebar")
        .animation(.easeOut(duration: 0.14), value: isHovered)
        .animation(.easeOut(duration: 0.14), value: collapseProgress)
    }

    private var lineOpacity: Double {
        if isHovered { return 0.48 }
        return 0.22 + (Double(collapseProgress) * 0.24)
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
            .shadow(color: .black.opacity(0.08), radius: 28, x: 0, y: 16)
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

private struct DetailView: View {
    let route: AtelierRoute

    var body: some View {
        switch route {
        case .overview:
            OverviewView()
        case .chat:
            ChatView()
        case .agents:
            AgentsView()
        case .activity:
            ActivityView()
        case .events:
            EventsView()
        case .usage:
            UsageView()
        case .memory:
            MemoryView()
        case .automations:
            AutomationsView()
        case .drafts:
            DraftsView()
        case .consolidation:
            ConsolidationView()
        case .connections:
            ConnectionsView()
        case .browser:
            BrowserView()
        case .status:
            StatusView()
        case .settings:
            AppSettingsView()
        case .changelog:
            ChangelogView()
        }
    }
}
