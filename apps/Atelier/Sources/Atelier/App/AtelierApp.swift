import SwiftUI

@main
struct AtelierApp: App {
    @StateObject private var store = AtelierStore()
    @AppStorage("atelier.darkMode") private var isDarkMode = false

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .task {
                    await store.refreshBackendStatus()
                }
        }
        .defaultSize(width: 1120, height: 760)
        .windowStyle(.hiddenTitleBar)
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
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .frame(width: 520)
                .padding()
        }
    }
}
