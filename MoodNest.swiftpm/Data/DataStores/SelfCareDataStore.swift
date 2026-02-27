import Foundation

// MARK: - Self-Care Data Store

@MainActor
final class SelfCareDataStore {
    static let shared = SelfCareDataStore()
    private let key = "moodnest_selfCareEntries"

    // Moved here after performance profiling — avoids blocking the main launch path
    private lazy var cache: [SelfCareEntry] = restoreCache()

    private init() {}

    func save(_ entry: SelfCareEntry) {
        cache.append(entry)
        // Tighter cap — self-care logs are short and 800 covers ~2+ years of daily use
        if cache.count > 800 {
            cache = Array(cache.suffix(800))
        }
        commitCache()
    }

    func loadAll() -> [SelfCareEntry] { cache }

    func delete(_ entry: SelfCareEntry) {
        cache.removeAll { $0.id == entry.id }
        commitCache()
    }

    func update(_ entry: SelfCareEntry) {
        if let index = cache.firstIndex(where: { $0.id == entry.id }) {
            cache[index] = entry
            commitCache()
        }
    }

    func invalidateCache() {
        cache = restoreCache()
    }

    // MARK: - Streak Calculation

    func getStreak() -> Int {
        let entries = loadAll()
        let cal = Calendar.current
        var streak = 0
        var currentDate = cal.startOfDay(for: Date())

        while true {
            let hasActivity = entries.contains { cal.isDate($0.timestamp, inSameDayAs: currentDate) }
            if hasActivity {
                streak += 1
                currentDate = cal.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        return streak
    }

    // MARK: - Private

    private func restoreCache() -> [SelfCareEntry] {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" { return [] }
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([SelfCareEntry].self, from: data)) ?? []
    }

    private func commitCache() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(cache) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}
