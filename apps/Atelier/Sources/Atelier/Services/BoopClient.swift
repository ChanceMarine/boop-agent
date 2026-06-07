import Foundation

enum BoopClientError: LocalizedError {
    case invalidResponse
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            "The Boop server returned an unreadable response."
        case .server(let message):
            message
        }
    }
}

final class BoopClient {
    var baseURL: URL

    private let session: URLSession
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func health() async throws -> HealthResponse {
        try await get("/health", as: HealthResponse.self)
    }

    func runtimeConfig() async throws -> RuntimeConfig {
        try await get("/runtime-config", as: RuntimeConfig.self)
    }

    func sendChat(conversationId: String, content: String) async throws -> String {
        let response = try await post(
            "/chat",
            body: ["conversationId": conversationId, "content": content],
            as: ChatResponse.self
        )
        return response.reply
    }

    func composioStatus() async throws -> ComposioStatus {
        try await get("/composio/status", as: ComposioStatus.self)
    }

    func toolkits() async throws -> ToolkitListResponse {
        try await get("/composio/toolkits", as: ToolkitListResponse.self)
    }

    func browserStatus() async throws -> BrowserStatus {
        try await get("/browser/status", as: BrowserStatus.self)
    }

    func changelog() async throws -> ChangelogPayload {
        try await get("/changelog", as: ChangelogPayload.self)
    }

    private func get<Value: Decodable>(_ path: String, as type: Value.Type) async throws -> Value {
        let url = baseURL.appendingPathComponent(path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
        let (data, response) = try await session.data(from: url)
        try validate(response: response, data: data)
        return try decoder.decode(Value.self, from: data)
    }

    private func post<Value: Decodable, Body: Encodable>(
        _ path: String,
        body: Body,
        as type: Value.Type
    ) async throws -> Value {
        let url = baseURL.appendingPathComponent(path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await session.data(for: request)
        try validate(response: response, data: data)
        return try decoder.decode(Value.self, from: data)
    }

    private func validate(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw BoopClientError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            if let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = object["error"] as? String {
                throw BoopClientError.server(error)
            }
            throw BoopClientError.server("HTTP \(http.statusCode)")
        }
    }
}
