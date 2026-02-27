import Foundation

// MARK: - Journal Entry Model

struct JournalEntry: Identifiable, Codable, Sendable {
    let id: UUID
    let title: String?
    let content: String
    let timestamp: Date
    let sentimentScore: Double?

    init(id: UUID = UUID(), title: String? = nil, content: String, timestamp: Date = Date(), sentimentScore: Double? = nil) {
        self.id = id
        self.title = title
        self.content = content
        self.timestamp = timestamp
        self.sentimentScore = sentimentScore
    }
}
