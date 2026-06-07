import SwiftUI

struct AppSettingsView: View {
    @EnvironmentObject private var store: AtelierStore

    var body: some View {
        Form {
            Section("Backend") {
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

            Section("Runtime") {
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

            Section("Conversation") {
                LabeledContent("Current ID", value: store.conversationId)
                Button("Start New Chat") {
                    store.startNewConversation()
                }
            }

            if let error = store.lastError {
                Section("Last Error") {
                    Text(error)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
    }
}
