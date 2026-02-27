import Foundation

struct BehavioralInsight: Identifiable, Sendable {
    let id: UUID
    let title: String
    let message: String
    let confidence: Double

    init(id: UUID = UUID(), title: String, message: String, confidence: Double) {
        self.id = id
        self.title = title
        self.message = message
        self.confidence = min(1.0, max(0, confidence))
    }
}

// MARK: - InsightComposer

enum InsightComposer {

    private static let windowDays = 14
    private static let cal = Calendar.current

    static func analyze(
        moods: [MoodEntry],
        journals: [JournalEntry],
        selfCare: [SelfCareEntry]
    ) -> [BehavioralInsight] {
        let cutoff = cal.date(byAdding: .day, value: -windowDays, to: Date()) ?? Date()
        let recentMoods     = moods.filter { $0.timestamp >= cutoff }.sorted { $0.timestamp < $1.timestamp }
        let recentJournals  = journals.filter { $0.timestamp >= cutoff }
        let recentSelfCare  = selfCare.filter { $0.timestamp >= cutoff }

        var results: [BehavioralInsight] = []

        if let i = journalLift(moods: recentMoods, journals: recentJournals)     { results.append(i) }
        if let i = selfCareLift(moods: recentMoods, selfCare: recentSelfCare)    { results.append(i) }
        if let i = peakHour(moods: recentMoods)                                  { results.append(i) }
        if let i = consistencyBonus(moods: recentMoods)                          { results.append(i) }
        if let i = trendLine(moods: recentMoods)                                 { results.append(i) }
        if let i = roughDay(moods: recentMoods)                                  { results.append(i) }

        return results.sorted { $0.confidence > $1.confidence }
    }

    static func moodScore(for emoji: String) -> Double {
        switch emoji {
        case "😃":           return  1.0
        case "🙂", "😊", "🥰", "😌": return  0.5
        case "😐", "🤔":    return  0.0
        case "🙁", "😔":    return -0.5
        case "😢", "😰":    return -1.0
        default:             return  0.0
        }
    }

    private static func journalLift(moods: [MoodEntry], journals: [JournalEntry]) -> BehavioralInsight? {
        guard moods.count >= 5, !journals.isEmpty else { return nil }

        var lifted = 0
        var total  = 0

        let moodByDay   = Dictionary(grouping: moods)    { cal.startOfDay(for: $0.timestamp) }
        let journalDays = Set(journals.map               { cal.startOfDay(for: $0.timestamp) })

        for jDay in journalDays {
            guard let dayMoods  = moodByDay[jDay]?.sorted(by: { $0.timestamp < $1.timestamp }),
                  let firstMood = dayMoods.first else { continue }
            let nextDay = cal.date(byAdding: .day, value: 1, to: jDay) ?? jDay
            guard let nextMoods = moodByDay[nextDay]?.sorted(by: { $0.timestamp < $1.timestamp }),
                  let nextMood  = nextMoods.first else { continue }
            total += 1
            if moodScore(for: nextMood.emoji) > moodScore(for: firstMood.emoji) { lifted += 1 }
        }

        guard total >= 2 else { return nil }
        let pct        = Double(lifted) / Double(total)
        let confidence = 0.4 + min(0.5, pct * 0.6)
        return BehavioralInsight(
            title: "Journaling & Mood",
            message: "On days you journal, your mood improves within 24 hours \(Int(round(pct * 100)))% of the time.",
            confidence: confidence
        )
    }

    private static func selfCareLift(moods: [MoodEntry], selfCare: [SelfCareEntry]) -> BehavioralInsight? {
        guard moods.count >= 5, !selfCare.isEmpty else { return nil }

        let moodByDay     = Dictionary(grouping: moods)    { cal.startOfDay(for: $0.timestamp) }
        let selfCareDays  = Set(selfCare.map               { cal.startOfDay(for: $0.timestamp) })

        var withScores:    [Double] = []
        var withoutScores: [Double] = []

        for (day, entries) in moodByDay {
            let avg = entries.map { moodScore(for: $0.emoji) }.reduce(0, +) / Double(entries.count)
            selfCareDays.contains(day) ? withScores.append(avg) : withoutScores.append(avg)
        }

        guard withScores.count >= 2, !withoutScores.isEmpty else { return nil }
        let withAvg    = withScores.reduce(0, +)    / Double(withScores.count)
        let withoutAvg = withoutScores.reduce(0, +) / Double(withoutScores.count)
        let diff       = withAvg - withoutAvg
        guard diff >= 0.15 else { return nil }

        let confidence = 0.45 + min(0.35, diff * 0.5)
        return BehavioralInsight(
            title: "Self-Care Impact",
            message: "On days you log self-care, your average mood is higher. Small habits add up.",
            confidence: confidence
        )
    }

    private static func peakHour(moods: [MoodEntry]) -> BehavioralInsight? {
        guard moods.count >= 6 else { return nil }

        var morning:   [MoodEntry] = []
        var afternoon: [MoodEntry] = []
        var evening:   [MoodEntry] = []

        for m in moods {
            let h = cal.component(.hour, from: m.timestamp)
            if h >= 5  && h < 12 { morning.append(m) }
            else if h >= 12 && h < 17 { afternoon.append(m) }
            else { evening.append(m) }
        }

        let avg: ([MoodEntry]) -> Double = {
            $0.isEmpty ? 0.0 : $0.map { moodScore(for: $0.emoji) }.reduce(0, +) / Double($0.count)
        }
        let mA = avg(morning), aA = avg(afternoon), eA = avg(evening)
        let best  = max(mA, aA, eA)
        let worst = min(mA, aA, eA)
        guard best - worst >= 0.2 else { return nil }

        let period = best == mA ? "mornings" : best == aA ? "afternoons" : "evenings"
        let confidence = 0.5 + min(0.3, (best - worst) * 0.4)
        return BehavioralInsight(
            title: "Time of Day",
            message: "Your mood tends to be better in \(period). Consider scheduling harder tasks then.",
            confidence: confidence
        )
    }

    private static func consistencyBonus(moods: [MoodEntry]) -> BehavioralInsight? {
        guard moods.count >= 7 else { return nil }

        let days       = Set(moods.map { cal.startOfDay(for: $0.timestamp) }).sorted(by: <)
        var maxStreak  = 0
        var current    = 0
        var prev: Date?

        for d in days {
            if let p = prev, cal.dateComponents([.day], from: p, to: d).day == 1 {
                current += 1
            } else {
                current = 1
            }
            maxStreak = max(maxStreak, current)
            prev = d
        }

        guard maxStreak >= 3 else { return nil }
        let confidence = 0.5 + min(0.25, Double(maxStreak) * 0.05)
        return BehavioralInsight(
            title: "Consistency Helps",
            message: "When you check in \(maxStreak) days in a row, patterns become clearer. Keep the streak going.",
            confidence: confidence
        )
    }

    private static func trendLine(moods: [MoodEntry]) -> BehavioralInsight? {
        guard moods.count >= 5 else { return nil }

        let byDay       = Dictionary(grouping: moods) { cal.startOfDay(for: $0.timestamp) }
        let sortedDays  = byDay.keys.sorted(by: <)
        let half        = max(1, sortedDays.count / 2)
        let firstScores = sortedDays.prefix(half).flatMap { byDay[$0] ?? [] }.map { moodScore(for: $0.emoji) }
        let lastScores  = sortedDays.suffix(half).flatMap { byDay[$0] ?? [] }.map { moodScore(for: $0.emoji) }
        guard !firstScores.isEmpty, !lastScores.isEmpty else { return nil }

        let first = firstScores.reduce(0, +) / Double(firstScores.count)
        let last  = lastScores.reduce(0, +)  / Double(lastScores.count)
        let diff  = last - first
        guard abs(diff) >= 0.15 else { return nil }

        let confidence = 0.45 + min(0.35, abs(diff) * 0.5)
        if diff > 0 {
            return BehavioralInsight(
                title: "Upward Trend",
                message: "Your mood has improved over the last two weeks. Whatever you're doing is working.",
                confidence: confidence
            )
        } else {
            return BehavioralInsight(
                title: "Recent Dip",
                message: "Your mood has been a bit lower lately. Consider a short breathing session or journaling.",
                confidence: confidence
            )
        }
    }

    private static func roughDay(moods: [MoodEntry]) -> BehavioralInsight? {
        guard moods.count >= 7 else { return nil }

        let byWeekday = Dictionary(grouping: moods) { cal.component(.weekday, from: $0.timestamp) }
        var worstDay: Int?
        var worstAvg: Double = 1.0

        for (weekday, entries) in byWeekday where entries.count >= 1 {
            let avg = entries.map { moodScore(for: $0.emoji) }.reduce(0, +) / Double(entries.count)
            if avg < worstAvg { worstAvg = avg; worstDay = weekday }
        }

        guard let w = worstDay, worstAvg < 0.2 else { return nil }
        let name       = dayLabel(w)
        let confidence = 0.5 + min(0.25, (0.5 - worstAvg) * 0.5)
        return BehavioralInsight(
            title: "Weekly Pattern",
            message: "Your mood drops most often on \(name). Consider scheduling self-care earlier that day.",
            confidence: confidence
        )
    }

    private static func dayLabel(_ weekday: Int) -> String {
        var comp = DateComponents(); comp.weekday = weekday
        guard let d = cal.date(from: comp) else { return "that day" }
        let fmt = DateFormatter(); fmt.dateFormat = "EEEE"
        return fmt.string(from: d)
    }
}
