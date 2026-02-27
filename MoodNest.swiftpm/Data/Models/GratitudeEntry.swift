import Foundation

// MARK: - Gratitude Entry Model

struct GratitudeEntry: Identifiable, Codable, Sendable {
    let id: UUID
    let text: String
    let timestamp: Date
    let sentimentScore: Double?

    init(id: UUID = UUID(), text: String, timestamp: Date = Date(), sentimentScore: Double? = nil) {
        self.id = id
        self.text = text
        self.timestamp = timestamp
        self.sentimentScore = sentimentScore
    }

    static var mockData: [GratitudeEntry] {
        [
            GratitudeEntry(text: "A beautiful morning walk", timestamp: Date().addingTimeInterval(-86400), sentimentScore: 0.8),
            GratitudeEntry(text: "Great coffee", timestamp: Date(), sentimentScore: 0.6)
        ]
    }
}
