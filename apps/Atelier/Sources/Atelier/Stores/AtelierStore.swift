import Foundation

@MainActor
final class AtelierStore: ObservableObject {
    @Published var selectedRoute: AtelierRoute = .overview
    @Published var backendState: BackendState = .unknown
    @Published var runtimeConfig: RuntimeConfig?
    @Published var messages: [ChatMessage] = []
    @Published var dashboardMetrics: DashboardMetrics?
    @Published var agents: [ExecutionAgent] = []
    @Published var memories: [MemoryRecord] = []
    @Published var automations: [AutomationRecord] = []
    @Published var consolidationRuns: [ConsolidationRun] = []
    @Published var memoryEvents: [MemoryEventRecord] = []
    @Published var usageRecords: [UsageRecord] = []
    @Published var usageSummary: UsageSummary?
    @Published var drafts: [DraftRecord] = []
    @Published var toolkits: [Toolkit] = []
    @Published var browserStatus: BrowserStatus?
    @Published var changelog: ChangelogPayload?
    @Published var composioEnabled = false
    @Published var isSending = false
    @Published var isLoadingDashboard = false
    @Published var isLoadingAgents = false
    @Published var isLoadingMemory = false
    @Published var isLoadingAutomations = false
    @Published var isLoadingConsolidation = false
    @Published var isLoadingEvents = false
    @Published var isLoadingUsage = false
    @Published var isLoadingDrafts = false
    @Published var isLoadingConnections = false
    @Published var isLoadingBrowser = false
    @Published var isLoadingChangelog = false
    @Published var lastError: String?

    @Published var boopBaseURLString: String {
        didSet {
            UserDefaults.standard.set(boopBaseURLString, forKey: Keys.boopURL)
            rebuildClients()
        }
    }

    @Published var convexURLString: String {
        didSet {
            UserDefaults.standard.set(convexURLString, forKey: Keys.convexURL)
            rebuildClients()
        }
    }

    @Published private(set) var conversationId: String {
        didSet {
            UserDefaults.standard.set(conversationId, forKey: Keys.conversationId)
        }
    }

    private enum Keys {
        static let boopURL = "atelier.boopURL"
        static let convexURL = "atelier.convexURL"
        static let conversationId = "atelier.conversationId"
    }

    private var boopClient: BoopClient
    private var convexClient: ConvexClient

    init() {
        let defaultBoop = "http://127.0.0.1:3456"
        let defaultConvex = "https://limitless-meerkat-752.convex.cloud"
        let savedBoop = UserDefaults.standard.string(forKey: Keys.boopURL) ?? defaultBoop
        let savedConvex = UserDefaults.standard.string(forKey: Keys.convexURL) ?? defaultConvex
        self.boopBaseURLString = savedBoop
        self.convexURLString = savedConvex
        self.conversationId = UserDefaults.standard.string(forKey: Keys.conversationId)
            ?? "atelier-\(UUID().uuidString)"
        self.boopClient = BoopClient(baseURL: URL(string: savedBoop) ?? URL(string: defaultBoop)!)
        self.convexClient = ConvexClient(cloudURL: URL(string: savedConvex) ?? URL(string: defaultConvex)!)
    }

    func startNewConversation() {
        conversationId = "atelier-\(UUID().uuidString)"
        messages = []
    }

    func refreshBackendStatus() async {
        do {
            let health = try await boopClient.health()
            backendState = health.ok ? .online(service: health.service) : .offline("Boop did not report healthy.")
            runtimeConfig = try? await boopClient.runtimeConfig()
            lastError = nil
        } catch {
            backendState = .offline(error.localizedDescription)
            runtimeConfig = nil
            lastError = error.localizedDescription
        }
    }

    func loadChatHistory() async {
        do {
            let rows = try await convexClient.recentMessages(conversationId: conversationId)
            messages = rows.map(\.chatMessage)
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    func loadDashboard() async {
        guard !isLoadingDashboard else { return }
        isLoadingDashboard = true
        defer { isLoadingDashboard = false }
        do {
            dashboardMetrics = try await convexClient.dashboardMetrics()
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    func loadAgents() async {
        guard !isLoadingAgents else { return }
        isLoadingAgents = true
        defer { isLoadingAgents = false }
        do {
            agents = try await convexClient.agents()
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    func send(_ content: String) async {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isSending else { return }

        isSending = true
        messages.append(ChatMessage(role: .user, content: trimmed))

        do {
            let reply = try await boopClient.sendChat(
                conversationId: conversationId,
                content: trimmed
            )
            messages.append(ChatMessage(role: .assistant, content: reply))
            lastError = nil
            await refreshBackendStatus()
        } catch {
            lastError = error.localizedDescription
            messages.append(ChatMessage(role: .assistant, content: "Boop is unavailable: \(error.localizedDescription)"))
            await refreshBackendStatus()
        }

        isSending = false
    }

    func loadMemory() async {
        guard !isLoadingMemory else { return }
        isLoadingMemory = true
        defer { isLoadingMemory = false }
        do {
            memories = try await convexClient.memories()
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    func loadAutomations() async {
        guard !isLoadingAutomations else { return }
        isLoadingAutomations = true
        defer { isLoadingAutomations = false }
        do {
            automations = try await convexClient.automations()
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    func loadConsolidation() async {
        guard !isLoadingConsolidation else { return }
        isLoadingConsolidation = true
        defer { isLoadingConsolidation = false }
        do {
            consolidationRuns = try await convexClient.consolidationRuns()
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    func loadEvents() async {
        guard !isLoadingEvents else { return }
        isLoadingEvents = true
        defer { isLoadingEvents = false }
        do {
            memoryEvents = try await convexClient.memoryEvents()
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    func loadUsage() async {
        guard !isLoadingUsage else { return }
        isLoadingUsage = true
        defer { isLoadingUsage = false }
        do {
            async let records = convexClient.usageRecords()
            async let summary = convexClient.usageSummary()
            usageRecords = try await records
            usageSummary = try await summary
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    func loadDrafts() async {
        guard !isLoadingDrafts else { return }
        isLoadingDrafts = true
        defer { isLoadingDrafts = false }
        do {
            drafts = try await convexClient.drafts()
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    func loadConnections() async {
        guard !isLoadingConnections else { return }
        isLoadingConnections = true
        defer { isLoadingConnections = false }
        do {
            let response = try await boopClient.toolkits()
            composioEnabled = response.enabled
            toolkits = response.toolkits
            lastError = nil
        } catch {
            composioEnabled = false
            toolkits = []
            lastError = error.localizedDescription
        }
    }

    func loadBrowserStatus() async {
        guard !isLoadingBrowser else { return }
        isLoadingBrowser = true
        defer { isLoadingBrowser = false }
        do {
            browserStatus = try await boopClient.browserStatus()
            lastError = nil
        } catch {
            browserStatus = nil
            lastError = error.localizedDescription
        }
    }

    func loadChangelog() async {
        guard !isLoadingChangelog else { return }
        isLoadingChangelog = true
        defer { isLoadingChangelog = false }
        do {
            changelog = try await boopClient.changelog()
            lastError = nil
        } catch {
            changelog = nil
            lastError = error.localizedDescription
        }
    }

    private func rebuildClients() {
        if let boopURL = URL(string: boopBaseURLString) {
            boopClient.baseURL = boopURL
        }
        if let convexURL = URL(string: convexURLString) {
            convexClient.cloudURL = convexURL
        }
    }
}
