import SwiftUI

/// Represents a mental health journey story from a historical or contemporary figure
struct MentalHealthVoice: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let profession: String
    let era: String // e.g., "1809-1865"
    let mentalHealthCondition: String
    let quote: String?
    let biography: String // 100-200 words
    let iconName: String // SF Symbol
    let colorHex: String // Hex color for theming
    let isHistorical: Bool // true for historical figures, false for modern
    
    var color: Color {
        Color(hex: colorHex)
    }
    
    init(id: UUID = UUID(), name: String, profession: String, era: String, condition: String, quote: String?, biography: String, icon: String, colorHex: String, isHistorical: Bool = true) {
        self.id = id
        self.name = name
        self.profession = profession
        self.era = era
        self.mentalHealthCondition = condition
        self.quote = quote
        self.biography = biography
        self.iconName = icon
        self.colorHex = colorHex
        self.isHistorical = isHistorical
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MentalHealthVoice, rhs: MentalHealthVoice) -> Bool {
        lhs.id == rhs.id
    }
}
