import Foundation
import SwiftUI

// MARK: - Custom Mood Model

struct CustomMood: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var iconName: String  // SF Symbol name
    var colorHex: String  // Stored as hex for Codable compatibility
    var isDefault: Bool
    
    init(id: UUID = UUID(), name: String, iconName: String, colorHex: String, isDefault: Bool = false) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.isDefault = isDefault
    }
    
    var color: Color {
        Color(hex: colorHex)
    }
}
