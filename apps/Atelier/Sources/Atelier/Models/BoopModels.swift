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

struct BrowserStatus: Codable, Hashable {
    let running: Bool
    let patchrightVersion: String?
    let detectedChromePath: String?
    let launchedAt: Double?
    let settings: BrowserSettings
    let activeUrl: String?
}

struct BrowserSettings: Codable, Hashable {
    let enabled: Bool
    let profileDir: String
    let showUi: Bool
    let loginHandoffEnabled: Bool
    let startUrl: String
    let channel: String
    let executablePath: String
    let extraArgs: [String]
}

struct ChangelogPayload: Codable, Hashable {
    let repo: String
    let branch: String
    let version: String
    let source: String
    let url: String?
    let fetchedAt: String
    let markdown: String
    let warning: String?
}
