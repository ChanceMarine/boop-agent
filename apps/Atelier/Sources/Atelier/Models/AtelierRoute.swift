import Foundation

enum AtelierRoute: String, CaseIterable, Identifiable {
    case chat
    case memory
    case automations
    case connections
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .chat: "Chat"
        case .memory: "Memory"
        case .automations: "Automations"
        case .connections: "Connections"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .chat: "bubble.left.and.bubble.right"
        case .memory: "books.vertical"
        case .automations: "clock.arrow.circlepath"
        case .connections: "link"
        case .settings: "gearshape"
        }
    }
}
