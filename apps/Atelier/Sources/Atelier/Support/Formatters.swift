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
}
