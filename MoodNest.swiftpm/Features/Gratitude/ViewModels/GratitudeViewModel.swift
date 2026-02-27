import SwiftUI

/// ViewModel for the gratitude screen — manages entries, new entry text,
/// confirmation state, and editing.
@MainActor
final class GratitudeViewModel: ObservableObject {
    @Published var newGratitude = ""
    @Published var entries: [GratitudeEntry] = []
    @Published var showConfirmation = false
    @Published var editingEntry: GratitudeEntry?
    @Published var editText = ""

    private var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    func loadEntries() {
        if !isPreview {
            entries = GratitudeDataStore.shared.loadAll().sorted { $0.timestamp > $1.timestamp }
        } else {
            entries = GratitudeEntry.mockData.sorted { $0.timestamp > $1.timestamp }
        }
    }

    func deleteEntry(_ entry: GratitudeEntry) {
        GratitudeDataStore.shared.delete(entry)
        loadEntries()
    }

    func startEditing(_ entry: GratitudeEntry) {
        editText = entry.text
        editingEntry = entry
    }

    func updateEntry(_ entry: GratitudeEntry) {
        let updated = GratitudeEntry(id: entry.id, text: editText, timestamp: entry.timestamp)
        GratitudeDataStore.shared.update(updated)
        editingEntry = nil
        loadEntries()
    }
}
