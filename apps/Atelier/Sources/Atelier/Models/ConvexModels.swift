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

struct DashboardMetrics: Decodable, Hashable {
    let messages: Int
    let memories: DashboardMemoryMetrics
    let agents: DashboardAgentMetrics
    let cost: DashboardCostMetrics
    let tokens: DashboardTokenMetrics
    let dailyBuckets: [DashboardDailyBucket]
    let truncated: Bool
    let scanLimit: Int
}

struct DashboardMemoryMetrics: Decodable, Hashable {
    let total: Int
    let shortTerm: Int
    let longTerm: Int
    let permanent: Int
}

struct DashboardAgentMetrics: Decodable, Hashable {
    let total: Int
    let completed: Int
    let failed: Int
    let cancelled: Int
    let running: Int
}

struct DashboardCostMetrics: Decodable, Hashable {
    let total: Double
}

struct DashboardTokenMetrics: Decodable, Hashable {
    let input: Int
    let output: Int
}

struct DashboardDailyBucket: Decodable, Hashable {
    let day: String
    let agentCost: Double
    let inputTokens: Int
    let outputTokens: Int
    let agentsSpawned: Int
    let agentsCompleted: Int
    let agentsFailed: Int
    let agentsCancelled: Int
    let automationRuns: Int
}

struct ExecutionAgent: Identifiable, Decodable, Hashable {
    let id: String
    let agentId: String
    let conversationId: String?
    let name: String
    let task: String
    let runtime: String?
    let model: String?
    let reasoningEffort: String?
    let billingMode: String?
    let status: String
    let result: String?
    let error: String?
    let mcpServers: [String]
    let inputTokens: Int
    let outputTokens: Int
    let costUsd: Double
    let startedAt: Double
    let completedAt: Double?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case agentId
        case conversationId
        case name
        case task
        case runtime
        case model
        case reasoningEffort
        case billingMode
        case status
        case result
        case error
        case mcpServers
        case inputTokens
        case outputTokens
        case costUsd
        case startedAt
        case completedAt
    }
}

struct ConsolidationRun: Identifiable, Decodable, Hashable {
    let id: String
    let runId: String
    let trigger: String
    let status: String
    let proposalsCount: Int
    let mergedCount: Int
    let prunedCount: Int
    let notes: String?
    let details: String?
    let startedAt: Double
    let completedAt: Double?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case runId
        case trigger
        case status
        case proposalsCount
        case mergedCount
        case prunedCount
        case notes
        case details
        case startedAt
        case completedAt
    }
}
