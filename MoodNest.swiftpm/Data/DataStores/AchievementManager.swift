import Foundation

// MARK: - Achievement Manager

/// Tracks and manages user achievements and milestones
@MainActor
final class AchievementManager: ObservableObject {
    static let shared = AchievementManager()
    
    @Published var unlockedAchievements: Set<String> = []
    @Published var newlyUnlocked: Achievement?
    
    private let achievementsKey = "moodnest_unlockedAchievements"
    
    private init() {
        loadAchievements()
    }
    
    private func loadAchievements() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" { return }
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            unlockedAchievements = decoded
        }
    }
    
    private func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(unlockedAchievements) {
            UserDefaults.standard.set(encoded, forKey: achievementsKey)
        }
    }
    
    /// Check and unlock achievement if criteria met
    func checkAchievement(_ achievement: Achievement) {
        guard !unlockedAchievements.contains(achievement.id) else { return }
        
        unlockedAchievements.insert(achievement.id)
        newlyUnlocked = achievement
        saveAchievements()
        
        // Trigger haptic feedback
        HapticManager.success()
    }
    
    // MARK: - Milestone Checking
    
    /// Check journal milestones
    func checkJournalMilestones(count: Int) {
        if count == 1 {
            checkAchievement(.firstJournal)
        } else if count == 5 {
            checkAchievement(.journal5)
        } else if count == 10 {
            checkAchievement(.journal10)
        } else if count == 25 {
            checkAchievement(.journal25)
        }
    }
    
    /// Check gratitude milestones
    func checkGratitudeMilestones(count: Int) {
        if count == 1 {
            checkAchievement(.firstGratitude)
        } else if count == 5 {
            checkAchievement(.gratitude5)
        } else if count == 10 {
            checkAchievement(.gratitude10)
        }
    }
    
    /// Check streak milestones
    func checkStreakMilestones(streak: Int) {
        if streak == 3 {
            checkAchievement(.streak3)
        } else if streak == 7 {
            checkAchievement(.streak7)
        } else if streak == 30 {
            checkAchievement(.streak30)
        }
    }
    
    /// Clear newly unlocked achievement (after showing)
    func clearNewlyUnlocked() {
        newlyUnlocked = nil
    }
}
