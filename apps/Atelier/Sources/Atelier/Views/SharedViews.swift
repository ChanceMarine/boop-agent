import SwiftUI

enum AtelierColors {
    static let windowBackground = Color(red: 247 / 255, green: 248 / 255, blue: 250 / 255)
    static let rail = Color(red: 37 / 255, green: 37 / 255, blue: 37 / 255)
    static let card = Color(red: 252 / 255, green: 252 / 255, blue: 252 / 255)
    static let cardStroke = Color.white
    static let selectedSubtab = Color.black.opacity(0.06)
    static let separator = Color.black.opacity(0.06)
    static let softFill = Color.black.opacity(0.035)
}

struct HeaderView: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.largeTitle.bold())
                Text(subtitle)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(24)
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.title2.bold())
            Text(message)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 380)
        }
        .padding()
    }
}

struct MetricTile: View {
    let title: String
    let value: String
    let footnote: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .semibold))
                    .frame(width: 28, height: 28)
                    .background(AtelierColors.softFill, in: RoundedRectangle(cornerRadius: 8))
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2.weight(.semibold))
                    .monospacedDigit()
                Text(title)
                    .font(.callout.weight(.medium))
                Text(footnote)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 128, alignment: .topLeading)
        .background(AtelierColors.softFill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct SoftPill: View {
    let text: String
    var tone: Tone = .neutral

    enum Tone {
        case neutral
        case good
        case warning
        case bad
    }

    var body: some View {
        Text(text)
            .font(.caption.weight(.medium))
            .foregroundStyle(color)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(color.opacity(0.10), in: Capsule())
    }

    private var color: Color {
        switch tone {
        case .neutral: .secondary
        case .good: .green
        case .warning: .orange
        case .bad: .red
        }
    }
}
