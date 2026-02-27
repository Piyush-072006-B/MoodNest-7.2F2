import SwiftUI

/// ViewModel for the main home screen — manages tab selection, sheet presentation,
/// and achievement overlay state.
@MainActor
final class HomeViewModel: ObservableObject {
    @Published var selectedTab: TabItem = .home
    @Published var showCheckIn = false
    @Published var showSelfCare = false
    @Published var showGratitude = false
    @Published var showJournal = false
    @Published var showAchievementOverlay = false
    @Published var pendingAchievement: Achievement? = nil
    @Published var hasAppeared = false
}
