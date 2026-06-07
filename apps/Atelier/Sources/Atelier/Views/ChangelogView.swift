import SwiftUI

struct ChangelogView: View {
    @EnvironmentObject private var store: AtelierStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Changelog")
                        .font(.title3.weight(.semibold))
                    Spacer()
                    Button {
                        Task { await store.loadChangelog() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.plain)
                    .help("Refresh")
                }

                if store.isLoadingChangelog && store.changelog == nil {
                    ProgressView("Loading changelog...")
                        .frame(maxWidth: .infinity, minHeight: 240)
                } else if let changelog = store.changelog {
                    HStack(spacing: 8) {
                        SoftPill(text: "v\(changelog.version)", tone: .neutral)
                        SoftPill(text: changelog.source, tone: changelog.warning == nil ? .good : .warning)
                        Text(changelog.repo)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let warning = changelog.warning {
                        Text(warning)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(12)
                            .background(AtelierColors.softFill, in: RoundedRectangle(cornerRadius: 10))
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(markdownPreview(changelog.markdown), id: \.self) { line in
                            Text(line)
                                .font(line.hasPrefix("#") ? .headline : .callout)
                                .foregroundStyle(line.hasPrefix("#") ? .primary : .secondary)
                                .textSelection(.enabled)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AtelierColors.softFill, in: RoundedRectangle(cornerRadius: 12))
                } else {
                    EmptyStateView(title: "Changelog unavailable", message: "Start Boop to load the changelog.")
                        .frame(maxWidth: .infinity, minHeight: 260)
                }
            }
            .padding(24)
        }
        .scrollContentBackground(.hidden)
        .task {
            await store.loadChangelog()
        }
    }

    private func markdownPreview(_ markdown: String) -> [String] {
        let lines: [String] = markdown
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { line in
                line
                    .replacingOccurrences(of: "**", with: "")
                    .trimmingCharacters(in: .whitespaces)
            }
            .filter { !$0.isEmpty }
        return Array(lines.prefix(36))
    }
}
