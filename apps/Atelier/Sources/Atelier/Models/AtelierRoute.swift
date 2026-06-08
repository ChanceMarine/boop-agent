import Foundation

struct AtelierSubtabSection: Identifiable, Hashable {
    let id: String
    let title: String?
    let routes: [AtelierRoute]
}

enum AtelierMainTab: String, CaseIterable, Identifiable {
    case agent
    case memory
    case workflows
    case connections
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .agent: "Agent"
        case .memory: "Memory"
        case .workflows: "Workflows"
        case .connections: "Connections"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .agent: "sparkles"
        case .memory: "books.vertical"
        case .workflows: "clock.arrow.circlepath"
        case .connections: "link"
        case .settings: "gearshape"
        }
    }

    var sections: [AtelierSubtabSection] {
        switch self {
        case .agent:
            [
                AtelierSubtabSection(id: "start", title: nil, routes: [.overview, .chat]),
                AtelierSubtabSection(id: "work", title: "Work", routes: [.agents, .activity, .events, .usage]),
            ]
        case .memory:
            [
                AtelierSubtabSection(id: "memory", title: nil, routes: [.memory]),
            ]
        case .workflows:
            [
                AtelierSubtabSection(id: "workflows", title: nil, routes: [.automations, .drafts, .consolidation]),
            ]
        case .connections:
            [
                AtelierSubtabSection(id: "connections", title: nil, routes: [.connections, .browser]),
            ]
        case .settings:
            [
                AtelierSubtabSection(id: "health", title: nil, routes: [.status]),
                AtelierSubtabSection(id: "preferences", title: "Preferences", routes: [.settings, .changelog]),
            ]
        }
    }

    var routes: [AtelierRoute] {
        sections.flatMap(\.routes)
    }
}

enum AtelierRoute: String, CaseIterable, Identifiable {
    case overview
    case chat
    case agents
    case activity
    case events
    case usage
    case memory
    case automations
    case drafts
    case consolidation
    case connections
    case browser
    case status
    case settings
    case changelog

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview: "Overview"
        case .chat: "Chat"
        case .agents: "Agents"
        case .activity: "Activity"
        case .events: "Events"
        case .usage: "Usage"
        case .memory: "Memory"
        case .automations: "Automations"
        case .drafts: "Drafts"
        case .consolidation: "Consolidation"
        case .connections: "Connections"
        case .browser: "Browser"
        case .status: "Status"
        case .settings: "Settings"
        case .changelog: "Changelog"
        }
    }

    var systemImage: String {
        switch self {
        case .overview: "square.grid.2x2"
        case .chat: "bubble.left.and.bubble.right"
        case .agents: "cpu"
        case .activity: "waveform.path.ecg"
        case .events: "bolt.horizontal.circle"
        case .usage: "chart.line.uptrend.xyaxis"
        case .memory: "books.vertical"
        case .automations: "clock.arrow.circlepath"
        case .drafts: "doc.text.magnifyingglass"
        case .consolidation: "arrow.triangle.merge"
        case .connections: "link"
        case .browser: "globe"
        case .status: "checkmark.seal"
        case .settings: "gearshape"
        case .changelog: "doc.text"
        }
    }

    var mainTab: AtelierMainTab {
        switch self {
        case .overview, .chat, .agents, .activity, .events, .usage:
            .agent
        case .memory:
            .memory
        case .automations, .drafts, .consolidation:
            .workflows
        case .connections, .browser:
            .connections
        case .status, .settings, .changelog:
            .settings
        }
    }
}
