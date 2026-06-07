import Foundation

struct ConvexEnvelope<Value: Decodable>: Decodable {
    let status: String?
    let value: Value?
    let errorMessage: String?
}

struct ConvexEmpty: Decodable {}

struct MemoryRecord: Identifiable, Decodable, Hashable {
    let id: String
    let memoryId: String
    let content: String
    let tier: String
    let segment: String
    let importance: Double
    let accessCount: Int
    let lifecycle: String
    let createdAt: Double
    let lastAccessedAt: Double

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case memoryId
        case content
        case tier
        case segment
        case importance
        case accessCount
        case lifecycle
        case createdAt
        case lastAccessedAt
    }
}

struct AutomationRecord: Identifiable, Decodable, Hashable {
    let id: String
    let automationId: String
    let name: String
    let task: String
    let integrations: [String]
    let schedule: String
    let timezone: String?
    let enabled: Bool
    let nextRunAt: Double?
    let lastRunAt: Double?
    let createdAt: Double

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case automationId
        case name
        case task
        case integrations
        case schedule
        case timezone
        case enabled
        case nextRunAt
        case lastRunAt
        case createdAt
    }
}

struct ConvexMessage: Identifiable, Decodable, Hashable {
    let id: String
    let conversationId: String
    let role: MessageRole
    let content: String
    let createdAt: Double

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case conversationId
        case role
        case content
        case createdAt
    }

    var chatMessage: ChatMessage {
        ChatMessage(
            id: id,
            role: role,
            content: content,
            createdAt: Date(timeIntervalSince1970: createdAt / 1000)
        )
    }
}
