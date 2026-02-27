import SwiftUI

// MARK: - Behavioral Insight Card (Lightweight, Reusable)

/// Displays one BehavioralInsight with optional confidence indicator. Used in MoodInsightsView, NewHomeView, ProfileView.
struct BehavioralInsightCard: View {
    let insight: BehavioralInsight
    var showConfidence: Bool = false
    var compact: Bool = false

    var body: some View {
        HStack(spacing: compact ? 12 : 14) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: compact ? 18 : 22))
                .foregroundColor(.cyanBlue)
                .frame(width: compact ? 36 : 44, height: compact ? 36 : 44)
                .background(Color.cyanBlue.opacity(0.12))
                .cornerRadius(compact ? 10 : 12)

            VStack(alignment: .leading, spacing: compact ? 2 : 3) {
                Text(insight.title)
                    .font(.system(size: compact ? 13 : 14, weight: .semibold))
                    .foregroundColor(.deepTeal)

                Text(insight.message)
                    .font(.system(size: compact ? 12 : 13))
                    .foregroundColor(.softAqua)
                    .lineLimit(compact ? 2 : 3)

                if showConfidence {
                    Text("\(Int(round(insight.confidence * 100)))% confidence")
                        .font(.system(size: 11))
                        .foregroundColor(.softAqua.opacity(0.8))
                }
            }

            Spacer(minLength: 0)
        }
        .padding(compact ? 12 : 14)
        .glassCard(cornerRadius: compact ? 12 : 14)
    }
}

#Preview {
    VStack(spacing: 12) {
        BehavioralInsightCard(
            insight: BehavioralInsight(
                title: "Journaling & Mood",
                message: "On days you journal, your mood improves within 24 hours 68% of the time.",
                confidence: 0.72
            ),
            showConfidence: true
        )
        BehavioralInsightCard(
            insight: BehavioralInsight(
                title: "Weekly Pattern",
                message: "Your mood drops most often on Sundays. Consider scheduling self-care earlier.",
                confidence: 0.65
            ),
            compact: true
        )
    }
    .padding()
    .background(Color.lightSky)
}
