import AppKit
import SwiftUI

enum AtelierColors {
    static let windowBackground = Color.atelier(
        light: NSColor(red: 247 / 255, green: 248 / 255, blue: 250 / 255, alpha: 1),
        dark: NSColor(red: 15 / 255, green: 16 / 255, blue: 19 / 255, alpha: 1)
    )
    static let rail = Color.atelier(
        light: NSColor(red: 37 / 255, green: 37 / 255, blue: 37 / 255, alpha: 1),
        dark: NSColor(red: 37 / 255, green: 37 / 255, blue: 37 / 255, alpha: 1)
    )
    static let railForeground = Color.atelier(
        light: .white,
        dark: .white
    )
    static let card = Color.atelier(
        light: NSColor(red: 252 / 255, green: 252 / 255, blue: 252 / 255, alpha: 1),
        dark: NSColor(red: 28 / 255, green: 30 / 255, blue: 35 / 255, alpha: 1)
    )
    static let cardStroke = Color.atelier(
        light: .white,
        dark: NSColor(red: 44 / 255, green: 47 / 255, blue: 54 / 255, alpha: 1)
    )
    static let composer = Color.atelier(
        light: NSColor(red: 252 / 255, green: 252 / 255, blue: 252 / 255, alpha: 1),
        dark: NSColor(red: 36 / 255, green: 39 / 255, blue: 46 / 255, alpha: 1)
    )
    static let composerStroke = Color.atelier(
        light: .white,
        dark: NSColor(red: 54 / 255, green: 58 / 255, blue: 67 / 255, alpha: 1)
    )
    static let selectedSubtab = Color.atelier(
        light: NSColor.black.withAlphaComponent(0.06),
        dark: NSColor.white.withAlphaComponent(0.08)
    )
    static let separator = Color.atelier(
        light: NSColor.black.withAlphaComponent(0.06),
        dark: NSColor.white.withAlphaComponent(0.07)
    )
    static let softFill = Color.atelier(
        light: NSColor.black.withAlphaComponent(0.035),
        dark: NSColor.white.withAlphaComponent(0.055)
    )
}

private extension Color {
    static func atelier(light: NSColor, dark: NSColor) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            let match = appearance.bestMatch(from: [.darkAqua, .aqua])
            return match == .darkAqua ? dark : light
        })
    }
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
