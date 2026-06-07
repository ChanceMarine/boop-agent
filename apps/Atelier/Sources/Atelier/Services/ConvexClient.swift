import Foundation

enum ConvexClientError: LocalizedError {
    case badURL
    case http(Int, String)
    case server(String)
    case missingValue

    var errorDescription: String? {
        switch self {
        case .badURL:
            "The Convex URL is invalid."
        case .http(let code, let body):
            "Convex HTTP \(code): \(body)"
        case .server(let message):
            message
        case .missingValue:
            "Convex returned no value."
        }
    }
}

final class ConvexClient {
    var cloudURL: URL

    private let session: URLSession
    private let decoder = JSONDecoder()

    init(cloudURL: URL, session: URLSession = .shared) {
        self.cloudURL = cloudURL
        self.session = session
    }

    func recentMessages(conversationId: String, limit: Int = 50) async throws -> [ConvexMessage] {
        try await query(
            "messages:recent",
            args: ["conversationId": conversationId, "limit": limit],
            as: [ConvexMessage].self
        )
    }

    func memories(limit: Int = 80) async throws -> [MemoryRecord] {
        try await query(
            "memoryRecords:list",
            args: ["lifecycle": "active", "limit": limit],
            as: [MemoryRecord].self
        )
    }

    func automations(enabledOnly: Bool = false) async throws -> [AutomationRecord] {
        try await query(
            "automations:list",
            args: ["enabledOnly": enabledOnly],
            as: [AutomationRecord].self
        )
    }

    private func query<Value: Decodable>(
        _ path: String,
        args: [String: Any],
        as type: Value.Type
    ) async throws -> Value {
        let endpoint = cloudURL.appendingPathComponent("api").appendingPathComponent("query")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "path": path,
            "args": args,
            "format": "json"
        ])

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw ConvexClientError.http(-1, "No HTTP response")
        }
        guard (200..<300).contains(http.statusCode) else {
            throw ConvexClientError.http(
                http.statusCode,
                String(data: data, encoding: .utf8) ?? ""
            )
        }

        let envelope = try decoder.decode(ConvexEnvelope<Value>.self, from: data)
        if let error = envelope.errorMessage {
            throw ConvexClientError.server(error)
        }
        guard let value = envelope.value else {
            throw ConvexClientError.missingValue
        }
        return value
    }
}
