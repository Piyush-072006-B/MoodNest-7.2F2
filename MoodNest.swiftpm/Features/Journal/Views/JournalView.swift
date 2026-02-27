import SwiftUI

struct JournalView: View {
    @State private var newTitle = ""
    @State private var newContent = ""
    @State private var entries: [JournalEntry] = []
    @State private var showConfirmation = false
    @State private var selectedEntry: JournalEntry?
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var wordCount: Int {
        newContent.split(separator: " ").count
    }

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

                    VStack(spacing: 2) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.cyanBlue)

                        Text("Journal")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.deepTeal)
                    }

                    Spacer()

                    Color.clear.frame(width: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                ScrollView {
                    VStack(spacing: 24) {
                        // New Entry Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text(PromptManager.shared.journalPrompt())
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.deepTeal)

                            TextField("Title (optional)", text: $newTitle)
                                .font(.system(size: 16, weight: .semibold))
                                .padding(12)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.softAqua.opacity(0.5), lineWidth: 1)
                                )

                            TextEditor(text: $newContent)
                                .font(.system(size: 15))
                                .frame(minHeight: 150)
                                .padding(8)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.softAqua.opacity(0.5), lineWidth: 1)
                                )
                            
                            #if DEBUG
                            Text("Sentiment Score: \(SentimentAnalyzer.emotionalTone(from: newContent), specifier: "%.2f")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            #endif

                            HStack {
                                Text("\(wordCount) words")
                                    .font(.system(size: 12))
                                    .foregroundColor(.cyanBlue)

                                Spacer()
                            }

                            PrimaryButton(
                                title: "Save Entry",
                                action: saveEntry,
                                isEnabled: !newContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            )
                        }
                        .padding(20)
                        .glassCard(cornerRadius: 16, borderWidth: 2)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        // Confirmation
                        if showConfirmation {
                            HStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(Color.deepTeal.opacity(0.3))
                                        .frame(width: 30, height: 30)
                                        .scaleEffect(showConfirmation ? 1.3 : 0.5)
                                        .opacity(showConfirmation ? 0 : 1)
                                        .animation(reduceMotion ? .none : .easeOut(duration: 0.8), value: showConfirmation)
                                    Image(systemName: "drop.fill")
                                        .foregroundColor(.deepTeal)
                                }
                                Text("Entry saved!")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.deepTeal)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
                        }

                        // Past Entries
                        if !entries.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Your journal")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.deepTeal)

                                    Spacer()

                                    Text("\(entries.count) entries")
                                        .font(.system(size: 14))
                                        .foregroundColor(.softAqua)
                                }
                                .padding(.horizontal, 20)

                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 12),
                                    GridItem(.flexible(), spacing: 12)
                                ], spacing: 12) {
                                    ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                                        JournalEntryCard(entry: entry) {
                                            selectedEntry = entry
                                        }
                                        .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.95)))
                                        .animation(reduceMotion ? .none : .easeOut(duration: 0.3).delay(Double(index) * 0.05), value: entries.count)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        } else if newContent.isEmpty {
                            EmptyStateView(
                                icon: "book.closed.fill",
                                title: "Start journaling today",
                                message: "Capture your thoughts and reflect on your day"
                            )
                            .padding(.vertical, 20)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .sheet(item: $selectedEntry) { entry in
            JournalDetailView(entry: entry, onDelete: {
                deleteEntry(entry)
                selectedEntry = nil
            }, onUpdate: { updated in
                JournalDataStore.shared.update(updated)
                selectedEntry = nil
                loadEntries()
            })
        }
        .onAppear {
            loadEntries()
        }
    }

    // MARK: - Save / Delete / Load

    func saveEntry() {
        let trimmedContent = newContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else { return }

        let trimmedTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let title = trimmedTitle.isEmpty ? nil : trimmedTitle

        // Analyze sentiment of journal content
        let sentiment = SentimentAnalyzer.emotionalTone(from: trimmedContent)

        let entry = JournalEntry(title: title, content: trimmedContent, sentimentScore: sentiment)
        JournalDataStore.shared.save(entry)

        // Check for achievements
        let allEntries = JournalDataStore.shared.loadAll()
        Task { @MainActor in
            AchievementManager.shared.checkJournalMilestones(count: allEntries.count)
        }

        newTitle = ""
        newContent = ""

        // Haptic feedback
        HapticManager.success()

        withAnimation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.7)) {
            showConfirmation = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(reduceMotion ? .none : .easeInOut) {
                showConfirmation = false
                loadEntries()
            }
        }
    }

    func deleteEntry(_ entry: JournalEntry) {
        JournalDataStore.shared.delete(entry)
        loadEntries()
    }

    func loadEntries() {
        entries = JournalDataStore.shared.loadAll().sorted { $0.timestamp > $1.timestamp }
    }
}

// MARK: - Journal Entry Card

struct JournalEntryCard: View {
    let entry: JournalEntry
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                Text(entry.title ?? "Untitled")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.deepTeal)
                    .lineLimit(1)

                Text(entry.content)
                    .font(.system(size: 12))
                    .foregroundColor(.cyanBlue)
                    .lineLimit(3)

                Spacer()

                Text(formatDate(entry.timestamp))
                    .font(.system(size: 10))
                    .foregroundColor(.softAqua)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .frame(height: 120)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.deepTeal.opacity(0.05), radius: 4, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.softAqua.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Journal Detail View

struct JournalDetailView: View {
    @State var entry: JournalEntry
    @State private var isEditing = false
    @State private var editTitle: String
    @State private var editContent: String
    let onDelete: () -> Void
    let onUpdate: (JournalEntry) -> Void
    @Environment(\.dismiss) var dismiss

    init(entry: JournalEntry, onDelete: @escaping () -> Void, onUpdate: @escaping (JournalEntry) -> Void) {
        self.entry = entry
        self.onDelete = onDelete
        self.onUpdate = onUpdate
        _editTitle = State(initialValue: entry.title ?? "")
        _editContent = State(initialValue: entry.content)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if isEditing {
                        TextField("Title", text: $editTitle)
                            .font(.system(size: 20, weight: .bold))
                            .padding(12)
                            .background(Color.lightSky)
                            .cornerRadius(8)

                        TextEditor(text: $editContent)
                            .font(.system(size: 16))
                            .frame(minHeight: 300)
                            .padding(8)
                            .background(Color.lightSky)
                            .cornerRadius(8)
                    } else {
                        if let title = entry.title {
                            Text(title)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.deepTeal)
                        } else {
                            Text("Untitled")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.deepTeal)
                        }

                        Text(formatDate(entry.timestamp))
                            .font(.system(size: 14))
                            .foregroundColor(.cyanBlue)

                        #if DEBUG
                        if let sentiment = entry.sentimentScore {
                            HStack {
                                Text("Sentiment Score: \(String(format: "%.2f", sentiment))")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(sentiment > 0.4 ? .green : sentiment < -0.4 ? .red : .gray)
                                Spacer()
                                Text(SentimentAnalyzer.toneEmoji(for: sentiment))
                                    .font(.system(size: 16))
                                Text(SentimentAnalyzer.sentimentLabel(for: sentiment))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.textSecondary)
                            }
                            .padding(.top, 8)
                            .padding(8)
                            .background(
                                Color(
                                    hue: SentimentAnalyzer.sentimentColor(for: sentiment).hue,
                                    saturation: SentimentAnalyzer.sentimentColor(for: sentiment).saturation,
                                    brightness: SentimentAnalyzer.sentimentColor(for: sentiment).brightness
                                )
                            )
                            .cornerRadius(8)
                        }
                        #endif

                        Divider()

                        Text(entry.content)
                            .font(.system(size: 16))
                            .foregroundColor(.black.opacity(0.8))
                            .lineSpacing(6)
                    }
                }
                .padding()
            }
            .background(Color.white)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(.deepTeal)
                }

                ToolbarItem(placement: .primaryAction) {
                    if isEditing {
                        Button("Save") {
                            let trimmedTitle = editTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                            let updated = JournalEntry(
                                id: entry.id,
                                title: trimmedTitle.isEmpty ? nil : trimmedTitle,
                                content: editContent,
                                timestamp: entry.timestamp,
                                sentimentScore: SentimentAnalyzer.emotionalTone(from: editContent)
                            )
                            onUpdate(updated)
                            isEditing = false
                        }
                        .foregroundColor(.deepTeal)
                    } else {
                        Button("Edit") {
                            isEditing = true
                        }
                        .foregroundColor(.cyanBlue)
                    }
                }

                ToolbarItem(placement: .destructiveAction) {
                    Button(role: .destructive) {
                        onDelete()
                        dismiss()
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    JournalView()
}
