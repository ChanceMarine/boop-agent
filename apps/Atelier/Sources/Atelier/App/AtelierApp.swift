import SwiftUI

@main
struct AtelierApp: App {
    @StateObject private var store = AtelierStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(.light)
                .task {
                    await store.refreshBackendStatus()
                }
        }
        .defaultSize(width: 1120, height: 760)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Chat") {
                    store.startNewConversation()
                }
                .keyboardShortcut("n", modifiers: [.command])
            }
        }

        Settings {
            AppSettingsView()
                .environmentObject(store)
                .preferredColorScheme(.light)
                .frame(width: 520)
                .padding()
        }
    }
}
