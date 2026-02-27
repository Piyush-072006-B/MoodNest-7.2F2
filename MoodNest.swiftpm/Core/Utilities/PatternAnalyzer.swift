import Foundation

// Pattern types surfaced to the insights layer

struct Insight: Identifiable, Sendable {
    let id: UUID
    let title: String
    let description: String
    let type: InsightType

    init(id: UUID = UUID(), title: String, description: String, type: InsightType) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
    }
}

enum InsightType: String, Sendable {
    case weekendImprovement = "weekend_improvement"
    case negativeWeekday    = "negative_weekday"
    case positive           = "positive"
}

enum WeeklyTrendType: Sendable {
    case positive
    case negative
    case flat
    case highVolatility
}

struct WeeklyTrendResult: Sendable {
    let type: WeeklyTrendType
    let title: String
    let message: String
}

enum InsightTone: Sendable {
    case positive
    case neutral
    case caution
}

struct LiveInsightResult: Sendable {
    let message: String
    let tone: InsightTone
}

// MARK: - MoodRhythmLogic

// Pure analysis — no side effects, no stored state
enum MoodRhythmLogic {

    static func analyzeWeeklyMoods(_ entries: [MoodEntry]) -> [Insight] {
        guard !entries.isEmpty else { return [] }

        let weekSlice = recentSlice(entries, days: 7)
        guard weekSlice.count >= 3 else { return [] }

        var found: [Insight] = []

        if let i = detectWeekendImprovement(weekSlice) { found.append(i) }
        if let i = detectMidweekDip(weekSlice)         { found.append(i) }
        if found.isEmpty { found.append(fallbackPositive(from: weekSlice)) }

        return found
    }

    private static func detectWeekendImprovement(_ entries: [MoodEntry]) -> Insight? {
        let weekdayScores = entries.filter { isWeekday($0.timestamp) }.map { score($0.emoji) }
        let weekendScores = entries.filter { !isWeekday($0.timestamp) }.map { score($0.emoji) }
        guard !weekdayScores.isEmpty, !weekendScores.isEmpty else { return nil }

        let weekdayAvg = weekdayScores.reduce(0, +) / Double(weekdayScores.count)
        let weekendAvg = weekendScores.reduce(0, +) / Double(weekendScores.count)
        guard weekendAvg - weekdayAvg >= 0.5 else { return nil }

        return Insight(
            title: "Weekend Boost 🌟",
            description: "Your mood tends to lift on weekends. Consider bringing some of that weekend energy into your weekdays.",
            type: .weekendImprovement
        )
    }

    private static func detectMidweekDip(_ entries: [MoodEntry]) -> Insight? {
        let weekdayEntries = entries.filter { isWeekday($0.timestamp) }
        let lowCount = weekdayEntries.filter { score($0.emoji) < 0 }.count
        guard lowCount >= 2 else { return nil }

        return Insight(
            title: "Midweek Dip 📉",
            description: "You've logged lower moods on several weekdays. Taking short breaks or a brief walk can help reset your energy.",
            type: .negativeWeekday
        )
    }

    private static func fallbackPositive(from entries: [MoodEntry]) -> Insight {
        let avg = entries.map { score($0.emoji) }.reduce(0, +) / Double(entries.count)
        if avg >= 0.5 {
            return Insight(
                title: "Positive Week 🎉",
                description: "You've had a great week! Your mood logs show steady positivity — keep it up.",
                type: .positive
            )
        }
        return Insight(
            title: "Keep Going 💪",
            description: "Every entry is progress. Check in daily to spot patterns and celebrate small wins.",
            type: .positive
        )
    }

    static func weeklyTrend(from entries: [MoodEntry]) -> WeeklyTrendResult? {
        let week = recentSlice(entries, days: 7)
        guard week.count >= 3 else { return nil }

        let scores   = week.map { score($0.emoji) }
        let avg      = scores.reduce(0, +) / Double(scores.count)
        let variance = scores.map { ($0 - avg) * ($0 - avg) }.reduce(0, +) / Double(scores.count)
        let stdDev   = variance.squareRoot()

        let sorted     = week.sorted { $0.timestamp < $1.timestamp }
        let half       = max(1, sorted.count / 2)
        let firstAvg   = sorted.prefix(half).map { score($0.emoji) }.reduce(0, +) / Double(half)
        let secondAvg  = sorted.suffix(half).map { score($0.emoji) }.reduce(0, +) / Double(sorted.suffix(half).count)
        let slope      = secondAvg - firstAvg

        if stdDev >= 0.5 {
            return WeeklyTrendResult(type: .highVolatility, title: "Varied Week",
                message: "Your mood has had ups and downs this week. That's normal — small routines can help steady the waves.")
        }
        if slope >= 0.25 {
            return WeeklyTrendResult(type: .positive, title: "Upward Trend",
                message: "Your mood has improved over the week. Keep doing what's working.")
        }
        if slope <= -0.25 {
            return WeeklyTrendResult(type: .negative, title: "Tough Week",
                message: "Your mood has been lower lately. A short breathing session or journaling can help.")
        }
        return WeeklyTrendResult(type: .flat, title: "Steady Week",
            message: "Your mood has been consistent. Consistency makes it easier to spot what helps.")
    }

    // MARK: - Emotional Drift Summary

    // Renamed from weeklyReflection — better describes what this actually computes
    static func emotionalDriftSummary(from entries: [MoodEntry]) -> String {
        let week = recentSlice(entries, days: 7)
        guard week.count >= 3 else {
            return "Log a few more days to unlock your weekly reflection."
        }

        let scores = week.map { score($0.emoji) }
        let avg    = scores.reduce(0, +) / Double(scores.count)

        let sorted    = week.sorted { $0.timestamp < $1.timestamp }
        let half      = max(1, sorted.count / 2)
        let firstAvg  = sorted.prefix(half).map { score($0.emoji) }.reduce(0, +) / Double(half)
        let secondAvg = sorted.suffix(half).map { score($0.emoji) }.reduce(0, +) / Double(sorted.suffix(half).count)
        let slope     = secondAvg - firstAvg

        let weekdayAvg = week.filter { isWeekday($0.timestamp) }.map { score($0.emoji) }.avg
        let weekendAvg = week.filter { !isWeekday($0.timestamp) }.map { score($0.emoji) }.avg
        let uniqueDays = Set(week.map { Calendar.current.startOfDay(for: $0.timestamp) }).count

        if slope >= 0.3 {
            return "Your mood pattern suggests steady improvement this week. Whatever routines you're practicing are currently working."
        } else if slope <= -0.3 {
            return "Your mood shows a slight decline lately. This is a gentle reminder to prioritize your self-care routines today."
        } else if weekendAvg - weekdayAvg >= 0.4 {
            return "Your positive days increased toward the weekend. Consider carrying some of that weekend downtime into your weekdays."
        } else if weekdayAvg < -0.2 && week.filter({ !isWeekday($0.timestamp) }).isEmpty {
            return "Mid-week dips appear quite often — consider adding a short check-in on Wednesdays to re-center."
        } else if uniqueDays >= 6 {
            return "You've been remarkably consistent with your check-ins this week. This is an excellent foundation for emotional awareness."
        } else if avg > 0.4 {
            return "Your overall mood is highly positive this week. You're building something beautiful."
        } else {
            return "Your mood pattern suggests emotional stability. Consistency makes it much easier to spot what helps you thrive."
        }
    }

    static func liveInsight(from entries: [MoodEntry]) -> LiveInsightResult {
        let recent = Array(entries.sorted { $0.timestamp > $1.timestamp }.prefix(3))
        guard !recent.isEmpty else {
            return LiveInsightResult(message: "Start by logging your mood to see live reflections.", tone: .neutral)
        }
        if recent.count == 1 {
            return LiveInsightResult(message: "Log a few more check-ins to unlock deeper insights.", tone: .neutral)
        }

        let scores  = recent.map { score($0.emoji) }
        let cal     = Calendar.current
        let today   = cal.startOfDay(for: Date())
        let todayCount = recent.filter { cal.isDate($0.timestamp, inSameDayAs: today) }.count

        if todayCount >= 3  { return LiveInsightResult(message: "You're checking in often today. Being mindful of fluctuations is a great habit.", tone: .neutral) }
        if scores[0] > scores[1] + 0.2  { return LiveInsightResult(message: "Your energy lifted since your last log. Momentum is building!", tone: .positive) }
        if scores[0] < scores[1] - 0.2  { return LiveInsightResult(message: "Your mood dipped recently. Perhaps a 5-minute breather could help.", tone: .caution) }
        if scores[0] >= 0.5  { return LiveInsightResult(message: "You're staying consistently positive. Notice what's working for you!", tone: .positive) }
        if scores[0] <= -0.5 { return LiveInsightResult(message: "You've been feeling low. A quick journal reflection might help unpack this.", tone: .caution) }

        return LiveInsightResult(message: "Your mood is steady right now. Consistency is an excellent baseline.", tone: .neutral)
    }

    private static func recentSlice(_ entries: [MoodEntry], days: Int) -> [MoodEntry] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return entries.filter { $0.timestamp >= cutoff }
    }

    private static func isWeekday(_ date: Date) -> Bool {
        (2...6).contains(Calendar.current.component(.weekday, from: date))
    }

    private static func score(_ emoji: String) -> Double {
        switch emoji {
        case "😃": return  1.0
        case "🙂": return  0.5
        case "😐": return  0.0
        case "🙁": return -0.5
        case "😢": return -1.0
        default:   return  0.0
        }
    }
}

// Tiny extension to keep the drift summary readable
private extension [Double] {
    var avg: Double { isEmpty ? 0 : reduce(0, +) / Double(count) }
}
