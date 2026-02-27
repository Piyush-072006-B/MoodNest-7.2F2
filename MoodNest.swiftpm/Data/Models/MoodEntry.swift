import Foundation

// MARK: - Mood Entry Model

struct MoodEntry: Identifiable, Codable, Sendable {
    let id: UUID
    let emoji: String
    let timestamp: Date
    let note: String?

    init(id: UUID = UUID(), emoji: String, timestamp: Date, note: String? = nil) {
        self.id = id
        self.emoji = emoji
        self.timestamp = timestamp
        self.note = note
    }
}

// MARK: - Icon Mapping
extension MoodEntry {
    var iconName: String { MoodEntry.iconName(for: emoji) }

    static func iconName(for emoji: String) -> String {
        switch emoji {
        case "😃": return "face.smiling"
        case "🙂": return "face.smiling"
        case "😐": return "face.dashed"
        case "🙁": return "face.smiling.inverse"
        case "😢": return "xmark.circle"
        default:   return "face.dashed"
        }
    }

    static func label(for emoji: String) -> String {
        switch emoji {
        case "😃": return "Feeling Great"
        case "🙂": return "Feeling Good"
        case "😐": return "Feeling Okay"
        case "🙁": return "Feeling Down"
        case "😢": return "Struggling"
        default:   return "Mood"
        }
    }
}
