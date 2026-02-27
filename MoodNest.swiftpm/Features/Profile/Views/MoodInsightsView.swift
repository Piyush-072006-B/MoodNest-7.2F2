import SwiftUI

// Local insight pass — runs against the 30 most recent entries

private enum InsightEngine {

    struct InsightResult: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let detail: String
    }

    static func analyze(_ entries: [MoodEntry]) -> [InsightResult] {
        guard entries.count >= 3 else { return [] }
        var results: [InsightResult] = []

        // 1) Most frequent mood
        let counts = Dictionary(grouping: entries, by: { $0.emoji }).mapValues { $0.count }
        if let top = counts.max(by: { $0.value < $1.value }) {
            let label = MoodEntry.label(for: top.key)
            results.append(InsightResult(
                icon: "star.fill",
                title: "Top Mood",
                detail: "Your most frequent mood is \(label) — logged \(top.value) times."
            ))
        }

        // 2) Weekend vs weekday
        let calendar = Calendar.current
        let weekday = entries.filter { !calendar.isDateInWeekend($0.timestamp) }
        let weekend = entries.filter { calendar.isDateInWeekend($0.timestamp) }
        if !weekday.isEmpty && !weekend.isEmpty {
            let weekdayAvg = averageScore(weekday)
            let weekendAvg = averageScore(weekend)
            let diff = weekendAvg - weekdayAvg
            if abs(diff) > 0.15 {
                let better = diff > 0 ? "weekends" : "weekdays"
                results.append(InsightResult(
                    icon: "calendar",
                    title: "Weekly Pattern",
                    detail: "Your mood tends to be better on \(better)."
                ))
            }
        }

        // 3) Morning vs evening
        let morning = entries.filter {
            let h = calendar.component(.hour, from: $0.timestamp)
            return h >= 5 && h < 12
        }
        let evening = entries.filter {
            let h = calendar.component(.hour, from: $0.timestamp)
            return h >= 17 && h < 24
        }
        if morning.count >= 2 && evening.count >= 2 {
            let morningAvg = averageScore(morning)
            let eveningAvg = averageScore(evening)
            let diff = morningAvg - eveningAvg
            if abs(diff) > 0.15 {
                let time = diff > 0 ? "mornings" : "evenings"
                results.append(InsightResult(
                    icon: diff > 0 ? "sunrise.fill" : "moon.stars.fill",
                    title: "Time-of-Day",
                    detail: "\(time.capitalized) tend to be calmer for you."
                ))
            }
        }

        // 4) Consistency badge
        let uniqueDays = Set(entries.map { calendar.startOfDay(for: $0.timestamp) }).count
        if uniqueDays >= 7 {
            results.append(InsightResult(
                icon: "flame.fill",
                title: "Consistency",
                detail: "You've logged moods on \(uniqueDays) different days — great habit!"
            ))
        }

        return results
    }

    private static func moodScore(_ emoji: String) -> Double {
        switch emoji {
        case "😃": return 1.0
        case "😊", "🙂", "🥰", "😌": return 0.5
        case "😐", "🤔": return 0.0
        case "🙁", "😔": return -0.5
        case "😢", "😰": return -1.0
        default: return 0.0
        }
    }

    private static func averageScore(_ entries: [MoodEntry]) -> Double {
        guard !entries.isEmpty else { return 0 }
        return entries.map { moodScore($0.emoji) }.reduce(0, +) / Double(entries.count)
    }
}

// MARK: - AnalyticsHelper
private struct AnalyticsHelper {
    static func calculateStreaks(from entries: [MoodEntry]) -> (current: Int, longest: Int) {
        guard !entries.isEmpty else { return (0, 0) }
        let calendar = Calendar.current
        let sortedEntries = entries.sorted { $0.timestamp > $1.timestamp }
        var uniqueDays: Set<Date> = []
        for entry in sortedEntries {
            uniqueDays.insert(calendar.startOfDay(for: entry.timestamp))
        }
        let sortedDays = uniqueDays.sorted(by: >)
        var streak = 0
        let today = calendar.startOfDay(for: Date())
        for day in sortedDays {
            let expectedDay = calendar.date(byAdding: .day, value: -streak, to: today) ?? today
            if calendar.isDate(day, inSameDayAs: expectedDay) {
                streak += 1
            } else {
                break
            }
        }
        var maxStreak = 0
        var tempStreak = 1
        for i in 0..<sortedDays.count - 1 {
            let diff = calendar.dateComponents([.day], from: sortedDays[i+1], to: sortedDays[i]).day ?? 0
            if diff == 1 {
                tempStreak += 1
                maxStreak = max(maxStreak, tempStreak)
            } else {
                tempStreak = 1
            }
        }
        return (streak, max(maxStreak, streak))
    }

    static func getWeeklyEntries(from entries: [MoodEntry]) -> [MoodEntry] {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return entries.filter { $0.timestamp >= weekAgo }
    }

    static func getMonthlyEntries(from entries: [MoodEntry]) -> [MoodEntry] {
        let calendar = Calendar.current
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        return entries.filter { $0.timestamp >= monthAgo }
    }

    static func getMostFrequentMood(from entries: [MoodEntry]) -> (emoji: String, count: Int)? {
        let monthlyEntries = getMonthlyEntries(from: entries)
        guard !monthlyEntries.isEmpty else { return nil }
        let counts = Dictionary(grouping: monthlyEntries, by: { $0.emoji })
            .mapValues { $0.count }
        return counts.max(by: { $0.value < $1.value }).map { ($0.key, $0.value) }
    }
}

// MARK: - MoodInsightsView

struct MoodInsightsView: View {
    @State private var moodEntries: [MoodEntry] = []
    @State private var currentStreak = 0
    @State private var longestStreak = 0
    @State private var insights: [InsightEngine.InsightResult] = []
    @State private var patternInsights: [Insight] = []
    @State private var behavioralInsights: [BehavioralInsight] = []
    @State private var weeklyTrendResult: WeeklyTrendResult? = nil
    @State private var trendCardVisible = false
    @State private var reflectionText: String = ""
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        ZStack {
            DecorativeBackground(
                gradient: LinearGradient(
                    colors: [Color.lightSky, Color.softAqua.opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.deepTeal.opacity(0.3))
                    }

                    Spacer()

                    VStack(spacing: 4) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.cyanBlue)

                        Text("Mood Insights")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.deepTeal)
                    }

                    Spacer()

                    Button(action: exportCSV) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 24))
                            .foregroundColor(.cyanBlue)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(Color.lightSky)

                ScrollView {
                    VStack(spacing: 24) {
                        // Streak Cards
                        HStack(spacing: 12) {
                            StreakCard(
                                title: "Current Streak",
                                count: currentStreak,
                                icon: "flame.fill",
                                color: .cyanBlue
                            )

                            StreakCard(
                                title: "Longest Streak",
                                count: longestStreak,
                                icon: "star.fill",
                                color: .softAqua
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        if !reflectionText.isEmpty {
                            WeeklyReflectionCard(reflectionText: reflectionText, entries: moodEntries)
                                .padding(.horizontal, 16)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                        
                        // Insight of the Week (dynamic trend: positive / negative / flat / volatility)
                        if let trend = weeklyTrendResult {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Insight of the Week")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.deepTeal)
                                    .padding(.horizontal, 20)

                                DynamicInsightOfTheWeekCard(trend: trend, visible: trendCardVisible, reduceMotion: reduceMotion)
                                    .padding(.horizontal, 16)
                            }
                        } else if let topInsight = patternInsights.first {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Insight of the Week")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.deepTeal)
                                    .padding(.horizontal, 20)
                                PatternInsightCard(insight: topInsight)
                                    .padding(.horizontal, 16)
                            }
                        }

                        // Behavioral insights from InsightComposer
                        if !behavioralInsights.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("What Your Data Shows")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.deepTeal)
                                    .padding(.horizontal, 20)

                                VStack(spacing: 12) {
                                    ForEach(behavioralInsights) { insight in
                                        BehavioralInsightCard(insight: insight, showConfidence: true)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }

                        if !insights.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Mood Patterns")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.deepTeal)
                                    .padding(.horizontal, 20)

                                VStack(spacing: 12) {
                                    ForEach(insights) { insight in
                                        InsightCard(insight: insight)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }

                        // Weekly Distribution
                        VStack(alignment: .leading, spacing: 12) {
                            Text("This Week")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.deepTeal)
                                .padding(.horizontal, 20)

                            WeeklyMoodChart(entries: AnalyticsHelper.getWeeklyEntries(from: moodEntries))
                                .padding(.horizontal, 16)
                        }

                        // Monthly Summary
                        VStack(alignment: .leading, spacing: 12) {
                            Text("This Month")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.deepTeal)
                                .padding(.horizontal, 20)

                            MonthlyMoodSummary(entries: AnalyticsHelper.getMonthlyEntries(from: moodEntries))
                                .padding(.horizontal, 16)
                        }

                        // Most Frequent Mood
                        if let mostFrequent = AnalyticsHelper.getMostFrequentMood(from: moodEntries) {
                            VStack(spacing: 12) {
                                Text("Most Frequent Mood")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.deepTeal)

                                HStack(spacing: 16) {
                                    Image(systemName: MoodEntry.iconName(for: mostFrequent.emoji))
                                        .font(.system(size: 50))
                                        .foregroundColor(.deepTeal)
                                        .accessibilityLabel(MoodEntry.label(for: mostFrequent.emoji))

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(mostFrequent.count) times")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(.deepTeal)

                                        Text("this month")
                                            .font(.system(size: 14))
                                            .foregroundColor(.softAqua)
                                    }
                                }
                                .padding(20)
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.deepTeal.opacity(0.1), radius: 8, x: 0, y: 2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(Color.softAqua.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear { loadData() }
    }

    // MARK: - Data

    func loadData() {
        moodEntries = EmotionalArchive.shared.loadAll()

        let streaks = AnalyticsHelper.calculateStreaks(from: moodEntries)
        currentStreak = streaks.current
        longestStreak  = streaks.longest

        patternInsights   = MoodRhythmLogic.analyzeWeeklyMoods(moodEntries)
        weeklyTrendResult = MoodRhythmLogic.weeklyTrend(from: moodEntries)
        reflectionText    = MoodRhythmLogic.emotionalDriftSummary(from: moodEntries)

        if reduceMotion {
            trendCardVisible = true
        } else {
            withAnimation(.easeOut(duration: 0.4)) {
                trendCardVisible = true
            }
        }

        let journals = JournalDataStore.shared.loadAll()
        let selfCare = SelfCareDataStore.shared.loadAll()
        behavioralInsights = InsightComposer.analyze(moods: moodEntries, journals: journals, selfCare: selfCare)

        let recentEntries = Array(moodEntries.sorted { $0.timestamp > $1.timestamp }.prefix(30))
        insights = InsightEngine.analyze(recentEntries)
    }

    func exportCSV() {
        var csvString = "Date,Time,Mood,Note\n"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"

        for entry in moodEntries.sorted(by: { $0.timestamp < $1.timestamp }) {
            let date = formatter.string(from: entry.timestamp)
            let time = timeFormatter.string(from: entry.timestamp)
            let note = entry.note?.replacingOccurrences(of: ",", with: ";") ?? ""
            csvString += "\(date),\(time),\(entry.emoji),\"\(note)\"\n"
        }

        let activityVC = UIActivityViewController(
            activityItems: [csvString],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Insight Card

private struct InsightCard: View {
    let insight: InsightEngine.InsightResult

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: insight.icon)
                .font(.system(size: 22))
                .foregroundColor(.cyanBlue)
                .frame(width: 44, height: 44)
                .background(Color.cyanBlue.opacity(0.12))
                .cornerRadius(13)

            VStack(alignment: .leading, spacing: 3) {
                Text(insight.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.deepTeal)

                Text(insight.detail)
                    .font(.system(size: 13))
                    .foregroundColor(.softAqua)
                    .lineLimit(3)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .glassCard(cornerRadius: 13)
    }
}

// MARK: - Supporting Views

struct StreakCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)

            Text("\(count)")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.deepTeal)

            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.cyanBlue)
                .multilineTextAlignment(.center)

            Text(count == 1 ? "day" : "days")
                .font(.system(size: 10))
                .foregroundColor(.softAqua)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.deepTeal.opacity(0.05), radius: 8, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.softAqua.opacity(0.2), lineWidth: 1)
        )
    }
}

struct WeeklyMoodChart: View {
    let entries: [MoodEntry]
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var moodCounts: [String: Int] {
        Dictionary(grouping: entries, by: { $0.emoji }).mapValues { $0.count }
    }

    var maxCount: Int { moodCounts.values.max() ?? 1 }

    var body: some View {
        VStack(spacing: 12) {
            if entries.isEmpty {
                Text("No mood entries this week")
                    .font(.system(size: 14))
                    .foregroundColor(.softAqua)
                    .padding(40)
            } else {
                ForEach(Array(moodCounts.sorted(by: { $0.value > $1.value })), id: \.key) { emoji, count in
                    HStack(spacing: 12) {
                        Image(systemName: MoodEntry.iconName(for: emoji))
                            .font(.system(size: 20))
                            .foregroundColor(.deepTeal)
                            .frame(width: 40)
                            .accessibilityLabel(MoodEntry.label(for: emoji))

                        GeometryReader { geometry in
                            HStack(spacing: 0) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(moodColor(for: emoji))
                                    .frame(width: geometry.size.width * CGFloat(count) / CGFloat(maxCount))
                                    .animation(reduceMotion ? .none : .easeOut(duration: 0.5), value: count)
                                Spacer()
                            }
                        }
                        .frame(height: 32)

                        Text("\(count)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.deepTeal)
                            .frame(width: 30, alignment: .trailing)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.deepTeal.opacity(0.05), radius: 8, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.softAqua.opacity(0.2), lineWidth: 1)
        )
    }

    func moodColor(for emoji: String) -> Color {
        switch emoji {
        case "😃", "😊", "🥰": return .cyanBlue
        case "🙂", "😌": return .softAqua
        case "😐", "🤔": return .softAqua.opacity(0.6)
        case "🙁", "😔": return .deepTeal
        case "😢", "😰": return .deepTeal.opacity(0.8)
        default: return .cyanBlue
        }
    }
}

struct MonthlyMoodSummary: View {
    let entries: [MoodEntry]

    var totalEntries: Int { entries.count }

    var uniqueDays: Int {
        let calendar = Calendar.current
        return Set(entries.map { calendar.startOfDay(for: $0.timestamp) }).count
    }

    var moodDiversity: Int { Set(entries.map { $0.emoji }).count }

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                SummaryCard(value: "\(totalEntries)", label: "Total Entries", icon: "checkmark.circle.fill", color: .cyanBlue)
                SummaryCard(value: "\(uniqueDays)", label: "Active Days", icon: "calendar.badge.checkmark", color: .deepTeal)
            }
            SummaryCard(value: "\(moodDiversity)", label: "Different Moods Logged", icon: "face.smiling", color: .softAqua)
        }
    }
}

struct SummaryCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.deepTeal)

                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(.cyanBlue)
            }

            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.deepTeal.opacity(0.05), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.softAqua.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Dynamic Insight of the Week Card (trend + pulse)

private struct DynamicInsightOfTheWeekCard: View {
    let trend: WeeklyTrendResult
    let visible: Bool
    let reduceMotion: Bool
    @State private var pulseOpacity: Double = 0.4

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                if !reduceMotion {
                    Circle()
                        .fill(Color.cyanBlue.opacity(pulseOpacity * 0.5))
                        .frame(width: 44, height: 44)
                        .scaleEffect(1.3)
                }
                Image(systemName: iconName)
                    .font(.system(size: 28))
                    .foregroundColor(.cyanBlue)
            }
            .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 4) {
                Text(trend.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.deepTeal)
                Text(trend.message)
                    .font(.system(size: 14))
                    .foregroundColor(.softAqua)
            }
            Spacer(minLength: 0)
        }
        .padding(20)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .shadow(color: Color.deepTeal.opacity(0.1), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.softAqua.opacity(0.3), lineWidth: 1)
        )
        .opacity(visible ? 1 : 0)
        .offset(y: visible ? 0 : 10)
        .onAppear {
            if !reduceMotion {
                // Refactored after animation glitch in v1 — spring feels more organic here
                withAnimation(.spring(response: 1.4, dampingFraction: 0.5).repeatForever(autoreverses: true)) {
                    pulseOpacity = 0.15
                }
            }
        }
    }

    private var iconName: String {
        switch trend.type {
        case .positive: return "arrow.up.right"
        case .negative: return "arrow.down.right"
        case .flat: return "minus"
        case .highVolatility: return "waveform.path.ecg"
        }
    }
}

// MARK: - Pattern Insight Card

struct PatternInsightCard: View {
    let insight: Insight

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 32))
                .foregroundColor(.cyanBlue)

            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.deepTeal)

                Text(insight.description)
                    .font(.system(size: 14))
                    .foregroundColor(.softAqua)
            }
            Spacer(minLength: 0)
        }
        .padding(20)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .shadow(color: Color.deepTeal.opacity(0.1), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.softAqua.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Weekly Reflection Card
struct WeeklyReflectionCard: View {
    let reflectionText: String
    let entries: [MoodEntry]
    
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var appear = false
    
    private var accentColor: Color {
        guard let trend = MoodRhythmLogic.weeklyTrend(from: entries) else { return .deepTeal }
        switch trend.type {
        case .positive: return .green
        case .negative: return .orange.opacity(0.8)
        case .flat, .highVolatility: return .deepTeal
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 32))
                .foregroundColor(accentColor)
                .frame(width: 44, height: 44)
                .background(accentColor.opacity(0.15))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Your Weekly Reflection")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.deepTeal)
                
                Text(reflectionText)
                    .font(.system(size: 14))
                    .foregroundColor(.softAqua)
                    .lineSpacing(4)
            }
            Spacer(minLength: 0)
        }
        .padding(20)
        .glassCard(cornerRadius: 16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(
                        colors: [accentColor.opacity(0.4), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
        )
        .opacity(appear || reduceMotion ? 1 : 0)
        .scaleEffect(appear || reduceMotion ? 1 : 0.96)
        .onAppear {
            if !reduceMotion {
                withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                    appear = true
                }
            } else {
                appear = true
            }
            HapticManager.light()
        }
    }
}

#Preview {
    MoodInsightsView()
}
