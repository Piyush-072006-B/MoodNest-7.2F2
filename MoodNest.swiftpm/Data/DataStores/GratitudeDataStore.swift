import Foundation

// MARK: - Gratitude Data Store

@MainActor
final class GratitudeDataStore {
    static let shared = GratitudeDataStore()
    private let key = "moodnest_gratitudeEntries"

    private lazy var cache: [GratitudeEntry] = pullFromDisk()

    private var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    private init() {}

    func save(_ entry: GratitudeEntry) {
        cache.append(entry)
        // 1000 keeps gratitude history substantial without excessive disk churn
        if cache.count > 1000 {
            cache = Array(cache.suffix(1000))
        }
        pushToDisk()
    }

    func loadAll() -> [GratitudeEntry] { cache }

    func delete(_ entry: GratitudeEntry) {
        cache.removeAll { $0.id == entry.id }
        pushToDisk()
    }

    func update(_ entry: GratitudeEntry) {
        if let index = cache.firstIndex(where: { $0.id == entry.id }) {
            cache[index] = entry
            pushToDisk()
        }
    }

    func invalidateCache() {
        cache = pullFromDisk()
    }

    // MARK: - Private

    private func pullFromDisk() -> [GratitudeEntry] {
        if isPreview { return GratitudeEntry.mockData }
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([GratitudeEntry].self, from: data)) ?? []
    }

    private func pushToDisk() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(cache) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}
