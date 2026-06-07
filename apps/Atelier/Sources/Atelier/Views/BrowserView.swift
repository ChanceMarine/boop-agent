import SwiftUI

struct BrowserView: View {
    @EnvironmentObject private var store: AtelierStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Browser")
                        .font(.title3.weight(.semibold))
                    Spacer()
                    Button {
                        Task { await store.loadBrowserStatus() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.plain)
                    .help("Refresh")
                }

                if store.isLoadingBrowser && store.browserStatus == nil {
                    ProgressView("Loading browser...")
                        .frame(maxWidth: .infinity, minHeight: 240)
                } else if let status = store.browserStatus {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 12)], spacing: 12) {
                        MetricTile(
                            title: "Chrome",
                            value: status.running ? "Running" : "Closed",
                            footnote: status.activeUrl ?? "No active page",
                            systemImage: "globe"
                        )
                        MetricTile(
                            title: "Local Use",
                            value: status.settings.enabled ? "On" : "Off",
                            footnote: status.settings.showUi ? "Visible browser" : "Hidden browser",
                            systemImage: "switch.2"
                        )
                        MetricTile(
                            title: "Login",
                            value: status.settings.loginHandoffEnabled ? "On" : "Off",
                            footnote: status.settings.channel.capitalized,
                            systemImage: "person.crop.circle.badge.checkmark"
                        )
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        BrowserDetail(label: "Start URL", value: status.settings.startUrl)
                        BrowserDetail(label: "Profile", value: status.settings.profileDir)
                        if let chromePath = status.detectedChromePath {
                            BrowserDetail(label: "Chrome", value: chromePath)
                        }
                    }
                    .padding(14)
                    .background(AtelierColors.softFill, in: RoundedRectangle(cornerRadius: 12))
                } else {
                    EmptyStateView(title: "Browser unavailable", message: "Start Boop to load local browser status.")
                        .frame(maxWidth: .infinity, minHeight: 260)
                }
            }
            .padding(24)
        }
        .scrollContentBackground(.hidden)
        .task {
            await store.loadBrowserStatus()
        }
    }
}

private struct BrowserDetail: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .foregroundStyle(.secondary)
                .frame(width: 72, alignment: .leading)
            Text(value.isEmpty ? "Not set" : value)
                .textSelection(.enabled)
                .lineLimit(2)
            Spacer()
        }
        .font(.callout)
    }
}
