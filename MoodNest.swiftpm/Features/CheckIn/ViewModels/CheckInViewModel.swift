import SwiftUI

/// ViewModel for the mood check-in screen — manages mood selection, note input,
/// spectrum value, intensity, confirmation, and recovery state.
@MainActor
final class CheckInViewModel: ObservableObject {
    @Published var selectedMood: String? = nil
    @Published var selectedMoodId: UUID? = nil
    @Published var moodNote: String = ""
    @Published var showConfirmation = false
    @Published var showConfetti = false
    @Published var showRecoveryBanner = false
    @Published var recoveryRecommendation: RecoveryRecommendation? = nil
    @Published var todayEntries: [MoodEntry] = []
    @Published var spectrumValue: Double = 0.0
    @Published var moodIntensity: Int = 3
    @Published var showCustomMoodSheet = false
    @Published var inputMode: ModernCheckInView.MoodInputMode = .emoji

    func loadTodayEntries() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        todayEntries = EmotionalArchive.shared.loadAll().filter { entry in
            calendar.isDate(entry.timestamp, inSameDayAs: today)
        }.sorted { $0.timestamp > $1.timestamp }
    }
}
