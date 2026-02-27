import Foundation

// MARK: - Quote Manager

struct Quote: Codable, Identifiable, Sendable {
    var id: String { text }
    let text: String
    let author: String
}

struct QuoteCollection: Codable, Sendable {
    let quotes: [Quote]
}

final class QuoteManager: @unchecked Sendable {
    static let shared = QuoteManager()
    private lazy var cachedQuotes: [Quote] = {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" { return [] }
        if let url = Bundle.main.url(forResource: "DailyQuotes", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode(QuoteCollection.self, from: data) {
            return decoded.quotes
        }
        return []
    }()
    
    private init() {}
    
    func quoteOfTheDay(for date: Date = Date()) -> Quote {
        guard !cachedQuotes.isEmpty else {
            return Quote(text: "Take care of yourself today.", author: "MoodNest")
        }
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let index = dayOfYear % cachedQuotes.count
        return cachedQuotes[index]
    }
}

// MARK: - Tip Manager

struct WellnessTipsCollection: Codable, Sendable {
    let tips: [String]
}

final class TipManager: @unchecked Sendable {
    static let shared = TipManager()
    private lazy var cachedTips: [String] = {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return ["Take a moment to breathe and be present"]
        }
        if let url = Bundle.main.url(forResource: "WellnessTips", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode(WellnessTipsCollection.self, from: data) {
            return decoded.tips
        }
        return [
            "Did you know? Just 5 minutes of journaling can reduce stress by 20%",
            "Gratitude practice rewires your brain for positivity over time",
            "Your feelings are valid, even if you can't explain them"
        ]
    }()
    
    private init() {}
    
    func randomTip() -> String {
        guard !cachedTips.isEmpty else {
            return "Take a moment to breathe and be present"
        }
        return cachedTips.randomElement() ?? cachedTips[0]
    }
    
    func tipOfTheDay(for date: Date = Date()) -> String {
        guard !cachedTips.isEmpty else {
            return "Take a moment to breathe and be present"
        }
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let index = dayOfYear % cachedTips.count
        return cachedTips[index]
    }
}

// MARK: - Prompt Manager

struct DailyPrompts: Codable, Sendable {
    let gratitudePrompts: [String]
    let journalPrompts: [String]
}

final class PromptManager: @unchecked Sendable {
    static let shared = PromptManager()
    private lazy var cachedPrompts: DailyPrompts? = {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" { return nil }
        if let url = Bundle.main.url(forResource: "DailyPrompts", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode(DailyPrompts.self, from: data) {
            return decoded
        }
        return nil
    }()
    
    private init() {}
    
    func gratitudePrompt(for date: Date = Date()) -> String {
        guard let prompts = cachedPrompts?.gratitudePrompts, !prompts.isEmpty else {
            return "What are you grateful for today?"
        }
        let index = dayOfYear(date) % prompts.count
        return prompts[index]
    }
    
    func journalPrompt(for date: Date = Date()) -> String {
        guard let prompts = cachedPrompts?.journalPrompts, !prompts.isEmpty else {
            return "How are you feeling today?"
        }
        let index = dayOfYear(date) % prompts.count
        return prompts[index]
    }
    
    private func dayOfYear(_ date: Date) -> Int {
        let calendar = Calendar.current
        return calendar.ordinality(of: .day, in: .year, for: date) ?? 1
    }
}

// MARK: - Greeting Manager

@MainActor
struct GreetingManager {
    
    static func greeting(for date: Date = Date(), name: String? = nil) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        let userName = name ?? "there"
        
        switch hour {
        case 0..<6:
            return "Good night, \(userName) 🌙"
        case 6..<12:
            return "Good morning, \(userName) ☀️"
        case 12..<17:
            return "Good afternoon, \(userName) 🌤️"
        case 17..<21:
            return "Good evening, \(userName) 🌆"
        default:
            return "Good night, \(userName) 🌙"
        }
    }
    
    static func simpleGreeting(for date: Date = Date()) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        
        switch hour {
        case 0..<6: return "Good night 🌙"
        case 6..<12: return "Good morning ☀️"
        case 12..<17: return "Good afternoon 🌤️"
        case 17..<21: return "Good evening 🌆"
        default: return "Good night 🌙"
        }
    }
    
    // Mood-aware subtitle — compares this week vs last week
    static func subtitle(for date: Date = Date()) -> String {
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: now) ?? now
        
        let allEntries = EmotionalArchive.shared.loadAll()
        
        let thisWeek = allEntries.filter { $0.timestamp >= weekAgo }
        let lastWeek = allEntries.filter { $0.timestamp >= twoWeeksAgo && $0.timestamp < weekAgo }
        
        if thisWeek.count >= 2 && lastWeek.count >= 2 {
            let thisAvg = average(thisWeek)
            let lastAvg = average(lastWeek)
            let diff = thisAvg - lastAvg
            
            if diff > 0.15 {
                let pct = Int(abs(diff / max(abs(lastAvg), 0.01)) * 100)
                let capped = min(pct, 200)
                return "Your mood improved ~\(capped)% this week ✨"
            } else if diff < -0.15 {
                return "Be kind to yourself this week 💙"
            } else {
                return "Staying steady — keep it up 🌱"
            }
        }
        
        // Fallback: time-of-day subtitle
        let hour = calendar.component(.hour, from: date)
        switch hour {
        case 0..<6: return "Rest well and recharge"
        case 6..<12: return "How's your heart today?"
        case 12..<17: return "Taking a moment for yourself?"
        case 17..<21: return "How was your day?"
        default: return "Time to wind down"
        }
    }
    
    private static func score(_ emoji: String) -> Double {
        switch emoji {
        case "😃": return 1.0
        case "😊", "🙂": return 0.5
        case "😐": return 0.0
        case "🙁", "😔": return -0.5
        case "😢": return -1.0
        default: return 0.0
        }
    }
    
    private static func average(_ entries: [MoodEntry]) -> Double {
        guard !entries.isEmpty else { return 0 }
        return entries.map { score($0.emoji) }.reduce(0, +) / Double(entries.count)
    }
    
    // Used for background gradient adaptation in NewHomeView
    static func weeklyAverageScore() -> Double {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let entries = EmotionalArchive.shared.loadAll().filter { $0.timestamp >= weekAgo }
        return average(entries)
    }
}

