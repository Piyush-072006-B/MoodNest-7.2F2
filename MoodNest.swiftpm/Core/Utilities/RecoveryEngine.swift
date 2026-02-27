import Foundation

// MARK: - Recovery Recommendation (Reactive System)

/// Suggested action when today's mood is at or below threshold.
struct RecoveryRecommendation: Sendable {
    let type: RecoveryType
    let title: String
    let subtitle: String

    enum RecoveryType: Sendable {
        case breathing
        case journal
        case guide
        case gratitude
    }
}

// MARK: - Recovery Engine (Pure — No Singleton)

/// Decides what to suggest when mood is low. Call with latest mood score (e.g. from today's check-in).
enum RecoveryEngine {

    /// Mood score at or below this value triggers a recovery suggestion.
    static let lowMoodThreshold: Double = -0.3

    /// Returns a recommendation when today's mood score is at or below threshold; nil otherwise.
    static func recommendation(for todayMoodScore: Double) -> RecoveryRecommendation? {
        guard todayMoodScore <= lowMoodThreshold else { return nil }

        // Prefer breathing for immediate reset; alternate others for variety
        switch todayMoodScore {
        case ..<(-0.6):
            return RecoveryRecommendation(
                type: .breathing,
                title: "2-minute reset",
                subtitle: "A short breathing session can help."
            )
        case ..<(-0.45):
            return RecoveryRecommendation(
                type: .journal,
                title: "Quick reflection",
                subtitle: "A brief journal prompt might help."
            )
        case ..<(-0.3):
            return RecoveryRecommendation(
                type: .gratitude,
                title: "Gratitude moment",
                subtitle: "Noting one good thing can shift perspective."
            )
        default:
            return RecoveryRecommendation(
                type: .breathing,
                title: "2-minute reset",
                subtitle: "Would you like a short breathing exercise?"
            )
        }
    }
}
