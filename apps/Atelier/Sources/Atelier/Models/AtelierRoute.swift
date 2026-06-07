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
                AtelierSubtabSection(id: "conversation", title: nil, routes: [.chat]),
                AtelierSubtabSection(id: "live", title: "Live", routes: [.activity]),
            ]
        case .memory:
            [
                AtelierSubtabSection(id: "memory", title: nil, routes: [.memory]),
            ]
        case .workflows:
            [
                AtelierSubtabSection(id: "workflows", title: nil, routes: [.automations]),
            ]
        case .connections:
            [
                AtelierSubtabSection(id: "connections", title: nil, routes: [.connections]),
            ]
        case .settings:
            [
                AtelierSubtabSection(id: "health", title: nil, routes: [.status]),
                AtelierSubtabSection(id: "preferences", title: "Preferences", routes: [.settings]),
            ]
        }
    }

    var routes: [AtelierRoute] {
        sections.flatMap(\.routes)
    }
}

enum AtelierRoute: String, CaseIterable, Identifiable {
    case chat
    case activity
    case memory
    case automations
    case connections
    case status
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .chat: "Chat"
        case .activity: "Activity"
        case .memory: "Memory"
        case .automations: "Automations"
        case .connections: "Connections"
        case .status: "Status"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .chat: "bubble.left.and.bubble.right"
        case .activity: "waveform.path.ecg"
        case .memory: "books.vertical"
        case .automations: "clock.arrow.circlepath"
        case .connections: "link"
        case .status: "checkmark.seal"
        case .settings: "gearshape"
        }
    }

    var mainTab: AtelierMainTab {
        switch self {
        case .chat, .activity:
            .agent
        case .memory:
            .memory
        case .automations:
            .workflows
        case .connections:
            .connections
        case .status, .settings:
            .settings
        }
    }
}
