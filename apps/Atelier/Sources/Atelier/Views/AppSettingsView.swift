import SwiftUI

struct AppSettingsView: View {
    @EnvironmentObject private var store: AtelierStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                SettingsGroup(title: "Backend") {
                    TextField("Boop URL", text: $store.boopBaseURLString)
                    TextField("Convex cloud URL", text: $store.convexURLString)

                    HStack {
                        StatusDot(state: store.backendState)
                        Text(store.backendState.label)
                        Spacer()
                        Button("Check") {
                            Task { await store.refreshBackendStatus() }
                        }
                    }
                }

                SettingsGroup(title: "Runtime") {
                    if let runtime = store.runtimeConfig {
                        LabeledContent("Runtime", value: runtime.runtime)
                        LabeledContent("Model", value: runtime.model)
                        LabeledContent("Billing", value: runtime.billingMode)
                        if let effort = runtime.reasoningEffort {
                            LabeledContent("Reasoning", value: effort)
                        }
                    } else {
                        Text("Runtime config unavailable.")
                            .foregroundStyle(.secondary)
                    }
                }

                SettingsGroup(title: "Conversation") {
                    LabeledContent("Current ID", value: store.conversationId)
                    Button("Start New Chat") {
                        store.startNewConversation()
                    }
                }

                if let error = store.lastError {
                    SettingsGroup(title: "Last Error") {
                        Text(error)
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }
                }
            }
            .textFieldStyle(.roundedBorder)
            .padding(24)
            .frame(maxWidth: 640, alignment: .leading)
        }
        .scrollContentBackground(.hidden)
    }
}

private struct SettingsGroup<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            VStack(alignment: .leading, spacing: 10) {
                content
            }
        }
    }
}
