import SwiftUI

enum AtelierColors {
    static let windowBackground = Color(red: 247 / 255, green: 248 / 255, blue: 250 / 255)
    static let rail = Color(red: 37 / 255, green: 37 / 255, blue: 37 / 255)
    static let card = Color(red: 252 / 255, green: 252 / 255, blue: 252 / 255)
    static let cardStroke = Color.white
    static let selectedSubtab = Color.black.opacity(0.06)
    static let separator = Color.black.opacity(0.06)
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
