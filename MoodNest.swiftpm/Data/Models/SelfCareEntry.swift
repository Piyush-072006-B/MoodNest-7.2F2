import Foundation

// MARK: - Self-Care Entry Model

struct SelfCareEntry: Identifiable, Codable, Sendable {
    let id: UUID
    let activity: String
    let timestamp: Date
    let completed: Bool
    let note: String?

    init(id: UUID = UUID(), activity: String, timestamp: Date = Date(), completed: Bool = true, note: String? = nil) {
        self.id = id
        self.activity = activity
        self.timestamp = timestamp
        self.completed = completed
        self.note = note
    }
}
