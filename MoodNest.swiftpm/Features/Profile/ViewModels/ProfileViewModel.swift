import SwiftUI

/// ViewModel for the profile screen — manages stats, user name editing,
/// navigation state, and weekly insight.
@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var moodCount = 0
    @Published var gratitudeCount = 0
    @Published var journalCount = 0
    @Published var selfCareCount = 0
    @Published var daysUsing = 0
    @Published var userName = ""
    @Published var isEditingName = false
    @Published var tempName = ""
    @Published var showInsights = false
    @Published var hasAnimatedStats = false
    @Published var showMoodEditor = false
    @Published var weeklyInsight: BehavioralInsight? = nil

    func loadUserName() {
        userName = UserDefaults.standard.string(forKey: "userName") ?? ""
    }

    func saveUserName() {
        UserDefaults.standard.set(userName, forKey: "userName")
    }
}
