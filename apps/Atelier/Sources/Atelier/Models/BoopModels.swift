import Foundation

enum BackendState: Equatable {
    case unknown
    case online(service: String)
    case offline(String)

    var isOnline: Bool {
        if case .online = self { return true }
        return false
    }

    var label: String {
        switch self {
        case .unknown: "Checking"
        case .online: "Online"
        case .offline: "Offline"
        }
    }
}

enum MessageRole: String, Codable, Hashable {
    case user
    case assistant
    case system
}

struct ChatMessage: Identifiable, Codable, Hashable {
    let id: String
    let role: MessageRole
    let content: String
    let createdAt: Date

    init(id: String = UUID().uuidString, role: MessageRole, content: String, createdAt: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.createdAt = createdAt
    }
}

struct RuntimeConfig: Codable, Hashable {
    let runtime: String
    let model: String
    let reasoningEffort: String?
    let billingMode: String
}

struct HealthResponse: Codable {
    let ok: Bool
    let service: String
}

struct ChatResponse: Codable {
    let reply: String
}

struct ComposioStatus: Codable {
    let enabled: Bool
}

struct ToolkitListResponse: Codable {
    let enabled: Bool
    let toolkits: [Toolkit]
}

struct Toolkit: Identifiable, Codable, Hashable {
    var id: String { slug }

    let slug: String
    let displayName: String
    let authMode: String
    let hasAuthConfig: Bool
    let logoUrl: String?
    let description: String?
    let toolCount: Int?
    let connections: [ToolkitConnection]
}

struct ToolkitConnection: Identifiable, Codable, Hashable {
    let id: String
    let status: String
    let alias: String?
    let accountLabel: String?
    let accountEmail: String?
    let accountName: String?
    let accountAvatarUrl: String?
    let createdAt: String?

    var displayLabel: String {
        alias ?? accountLabel ?? accountEmail ?? accountName ?? status
    }
}
