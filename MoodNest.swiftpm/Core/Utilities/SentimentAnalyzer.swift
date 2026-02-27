import Foundation
import NaturalLanguage

// On-device tone detection — no network, no server, fully private
struct SentimentAnalyzer {

    // Word-level fallback handles short entries that paragraph-level tagger misses
    static func emotionalTone(from text: String) -> Double {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return 0.0 }

        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = trimmed

        let range = trimmed.startIndex..<trimmed.endIndex
        let (tag, _) = tagger.tag(at: trimmed.startIndex, unit: .paragraph, scheme: .sentimentScore)

        var score = 0.0
        if let raw = tag?.rawValue, let parsed = Double(raw) {
            score = parsed
        }

        // Prevents rare bias toward neutral on short entries (< 4 words)
        let words = trimmed.split(separator: " ")
        if words.count < 4 && score == 0.0 {
            var wordSum   = 0.0
            var wordCount = 0
            tagger.enumerateTags(in: range, unit: .word, scheme: .sentimentScore,
                                 options: [.omitWhitespace, .omitPunctuation]) { tag, _ in
                if let t = tag, let s = Double(t.rawValue) {
                    wordSum   += s
                    wordCount += 1
                }
                return true
            }
            if wordCount > 0 { score = wordSum / Double(wordCount) }
        }

        return max(-1.0, min(1.0, score))
    }

    // Maps a tone score to a representative emoji
    static func toneEmoji(for score: Double) -> String {
        score > 0.4 ? "😃" : score < -0.4 ? "😢" : "😐"
    }

    // Human-readable label for display in cards and journal entries
    static func sentimentLabel(for score: Double) -> String {
        switch score {
        case  0.6...1.0:      return "Joyful"
        case  0.3..<0.6:      return "Optimistic"
        case  0.1..<0.3:      return "Positive"
        case -0.1..<0.1:      return "Reflective"
        case -0.3..<(-0.1):   return "Thoughtful"
        case -0.6..<(-0.3):   return "Concerned"
        default:              return "Stressed"
        }
    }

    // HSB tuple used for gradient interpolation in JournalView and GratitudeView
    static func sentimentColor(for score: Double) -> (hue: Double, saturation: Double, brightness: Double) {
        (hue: score > 0 ? 0.33 : 0.0, saturation: min(abs(score), 1.0), brightness: 0.85)
    }
}
