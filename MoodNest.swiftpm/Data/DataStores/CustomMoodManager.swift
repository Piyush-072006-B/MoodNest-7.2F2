import Foundation
import SwiftUI

// MARK: - Custom Mood Manager

@MainActor
final class CustomMoodManager: ObservableObject {
    static let shared = CustomMoodManager()
    
    @Published var customMoods: [CustomMood] = []
    private let key = "moodnest_customMoods"
    
    private init() {
        loadMoods()
        
        // Initialize default moods if empty
        if customMoods.isEmpty {
            initializeDefaultMoods()
        }
    }
    
    // MARK: - Default Moods
    
    private func initializeDefaultMoods() {
        customMoods = [
            CustomMood(
                name: "Great",
                iconName: "face.smiling",
                colorHex: "#FF9500",  // Orange
                isDefault: true
            ),
            CustomMood(
                name: "Good",
                iconName: "face.smiling",
                colorHex: "#5AC8FA",  // Cyan Blue
                isDefault: true
            ),
            CustomMood(
                name: "Okay",
                iconName: "face.dashed",
                colorHex: "#4DD0E1",  // Soft Aqua
                isDefault: true
            ),
            CustomMood(
                name: "Down",
                iconName: "face.smiling.inverse",
                colorHex: "#00897B",  // Deep Teal
                isDefault: true
            ),
            CustomMood(
                name: "Struggling",
                iconName: "xmark.circle",
                colorHex: "#AF52DE",  // Purple
                isDefault: true
            )
        ]
        saveMoods()
    }
    
    // MARK: - CRUD Operations
    
    func addMood(_ mood: CustomMood) {
        customMoods.append(mood)
        saveMoods()
    }
    
    func updateMood(_ mood: CustomMood) {
        if let index = customMoods.firstIndex(where: { $0.id == mood.id }) {
            customMoods[index] = mood
            saveMoods()
        }
    }
    
    func deleteMood(_ mood: CustomMood) {
        // Don't allow deleting default moods
        guard !mood.isDefault else { return }
        
        customMoods.removeAll { $0.id == mood.id }
        saveMoods()
    }
    
    // MARK: - Persistence
    
    private func saveMoods() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(customMoods) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    private func loadMoods() {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            customMoods = []
            return
        }
        
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode([CustomMood].self, from: data) {
            customMoods = decoded
        } else {
            customMoods = []
        }
    }
    
    // MARK: - Helper
    
    func getMood(byId id: UUID) -> CustomMood? {
        return customMoods.first { $0.id == id }
    }
}
