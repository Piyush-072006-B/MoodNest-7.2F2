import SwiftUI

/// ViewModel for the journal screen — manages entries, new entry text,
/// confirmation state, and CRUD operations.
@MainActor
final class JournalViewModel: ObservableObject {
    @Published var newTitle = ""
    @Published var newContent = ""
    @Published var entries: [JournalEntry] = []
    @Published var showConfirmation = false
    @Published var selectedEntry: JournalEntry?

    var wordCount: Int {
        newContent.split(separator: " ").count
    }

    func loadEntries() {
        entries = JournalDataStore.shared.loadAll().sorted { $0.timestamp > $1.timestamp }
    }

    func deleteEntry(_ entry: JournalEntry) {
        JournalDataStore.shared.delete(entry)
        loadEntries()
    }
}
