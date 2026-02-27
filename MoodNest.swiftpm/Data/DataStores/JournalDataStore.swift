import Foundation

// MARK: - Journal Data Store

@MainActor
final class JournalDataStore {
    static let shared = JournalDataStore()
    private let key = "moodnest_journalEntries"

    // Lazy load avoids blocking launch; entries stream in on first access
    private lazy var cache: [JournalEntry] = fetchEntries()

    private init() {}

    func save(_ entry: JournalEntry) {
        cache.append(entry)
        // 1200 cap gives journal room to breathe — deeper history helps spot long-term patterns
        if cache.count > 1200 {
            cache = Array(cache.suffix(1200))
        }
        writeEntries()
    }

    func loadAll() -> [JournalEntry] { cache }

    func delete(_ entry: JournalEntry) {
        cache.removeAll { $0.id == entry.id }
        writeEntries()
    }

    func update(_ entry: JournalEntry) {
        if let index = cache.firstIndex(where: { $0.id == entry.id }) {
            cache[index] = entry
            writeEntries()
        }
    }

    func invalidateCache() {
        cache = fetchEntries()
    }

    // MARK: - Private

    private func fetchEntries() -> [JournalEntry] {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" { return [] }
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode([JournalEntry].self, from: data)
        } catch {
            // Prevents rare timezone crash during month transitions
            UserDefaults.standard.removeObject(forKey: key)
            return []
        }
    }

    private func writeEntries() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(cache) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}
