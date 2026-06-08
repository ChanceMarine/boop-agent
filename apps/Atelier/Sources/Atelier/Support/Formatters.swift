import Foundation

enum AtelierFormatters {
    static let relative: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    static func relativeTime(milliseconds: Double?) -> String {
        guard let milliseconds else { return "Not scheduled" }
        let date = Date(timeIntervalSince1970: milliseconds / 1000)
        return relative.localizedString(for: date, relativeTo: Date())
    }

    static func shortDate(milliseconds: Double) -> String {
        let date = Date(timeIntervalSince1970: milliseconds / 1000)
        return date.formatted(date: .abbreviated, time: .shortened)
    }

    static func compactNumber(_ value: Int) -> String {
        if value >= 1_000_000 {
            return String(format: "%.1fM", Double(value) / 1_000_000)
        }
        if value >= 1_000 {
            return String(format: "%.1fK", Double(value) / 1_000)
        }
        return "\(value)"
    }

    static func currency(_ value: Double) -> String {
        if value == 0 { return "$0" }
        if value < 0.01 { return String(format: "$%.4f", value) }
        return String(format: "$%.2f", value)
    }

    static func duration(milliseconds: Double) -> String {
        if milliseconds < 1_000 {
            return "\(Int(milliseconds))ms"
        }
        if milliseconds < 60_000 {
            return String(format: "%.1fs", milliseconds / 1_000)
        }
        return String(format: "%.1fm", milliseconds / 60_000)
    }

    static func tail(_ value: String?, count: Int = 6) -> String? {
        guard let value, !value.isEmpty else { return nil }
        return String(value.suffix(count))
    }
}
