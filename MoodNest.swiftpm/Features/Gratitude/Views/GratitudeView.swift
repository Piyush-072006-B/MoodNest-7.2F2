import SwiftUI

struct GratitudeView: View {
    @State private var newGratitude = ""
    @State private var entries: [GratitudeEntry] = []
    @State private var showConfirmation = false
    @State private var editingEntry: GratitudeEntry?
    @State private var editText = ""
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    private var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
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
                        Image(systemName: "star.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.softAqua)
                        
                        Text("Gratitude")
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
                            Text(PromptManager.shared.gratitudePrompt())
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.deepTeal)
                            
                            TextField("I'm grateful for...", text: $newGratitude, axis: .vertical)
                                .font(.system(size: 16))
                                .padding(16)
                                .lineLimit(3...6)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.softAqua.opacity(0.5), lineWidth: 2)
                                )
                                
                            #if DEBUG
                            Text("Sentiment Score: \(SentimentAnalyzer.emotionalTone(from: newGratitude), specifier: "%.2f")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            #endif
                            
                            PrimaryButton(
                                title: "Save",
                                action: saveGratitude,
                                isEnabled: !newGratitude.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            )
                        }
                        .padding(20)
                        .glassCard(cornerRadius: 16, borderWidth: 2)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Confirmation
                        if showConfirmation {
                            HStack(spacing: 8) {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.pink)
                                Text("Gratitude saved!")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.deepTeal)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity).combined(with: .move(edge: .bottom)))
                            .offset(y: -10)
                        }
                        
                        // Past Entries
                        if !entries.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Your gratitude journal")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.deepTeal)
                                    
                                    Spacer()
                                    
                                    Text("\(entries.count) entries")
                                        .font(.system(size: 14))
                                        .foregroundColor(.cyanBlue)
                                }
                                .padding(.horizontal, 20)
                                
                                ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                                    GratitudeCard(
                                        entry: entry,
                                        onDelete: { deleteEntry(entry) },
                                        onEdit: { startEditing(entry) }
                                    )
                                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
                                    .animation(reduceMotion ? .none : .easeOut(duration: 0.3).delay(Double(index) * 0.05), value: entries.count)
                                }
                                .padding(.horizontal, 20)
                            }
                        } else if newGratitude.isEmpty {
                            EmptyStateView(
                                icon: "sparkles",
                                title: "Start your gratitude practice",
                                message: "Begin your gratitude practice and watch positivity grow"
                            )
                            .padding(.vertical, 20)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .sheet(item: $editingEntry) { entry in
            EditGratitudeSheet(
                entry: entry,
                text: $editText,
                onSave: {
                    updateEntry(entry)
                },
                onDismiss: {
                    editingEntry = nil
                }
            )
        }
        .onAppear {
            loadEntries()
        }
    }
    
    func saveGratitude() {
        let trimmed = newGratitude.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // Analyze sentiment of gratitude text
        let sentiment = SentimentAnalyzer.emotionalTone(from: trimmed)
        
        let entry = GratitudeEntry(text: trimmed, sentimentScore: sentiment)
        GratitudeDataStore.shared.save(entry)
        
        // Check for achievements
        let allEntries = GratitudeDataStore.shared.loadAll()
        Task { @MainActor in
            AchievementManager.shared.checkGratitudeMilestones(count: allEntries.count)
        }
        
        newGratitude = ""
        
        // Haptic feedback
        HapticManager.success()
        
        withAnimation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.7)) {
            showConfirmation = true
        }
        
        // Auto-dismiss cleanly overlay (0.6–1.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(reduceMotion ? .none : .easeInOut) {
                showConfirmation = false
                loadEntries()
            }
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
    
    func loadEntries() {
        if !isPreview {
            entries = GratitudeDataStore.shared.loadAll().sorted { $0.timestamp > $1.timestamp }
        } else {
            entries = GratitudeEntry.mockData.sorted { $0.timestamp > $1.timestamp }
        }
    }
}

struct GratitudeCard: View {
    let entry: GratitudeEntry
    let onDelete: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(formatDate(entry.timestamp))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.cyanBlue)
                
                // Sentiment indicator
                if let sentiment = entry.sentimentScore {
                    HStack(spacing: 4) {
                        Text(SentimentAnalyzer.toneEmoji(for: sentiment))
                            .font(.system(size: 12))
                        Text(SentimentAnalyzer.sentimentLabel(for: sentiment))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.textTertiary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Color(
                            hue: SentimentAnalyzer.sentimentColor(for: sentiment).hue,
                            saturation: SentimentAnalyzer.sentimentColor(for: sentiment).saturation,
                            brightness: SentimentAnalyzer.sentimentColor(for: sentiment).brightness
                        )
                    )
                    .cornerRadius(8)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14))
                            .foregroundColor(.softAqua)
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(.deepTeal.opacity(0.6))
                    }
                }
            }
            
            Text(entry.text)
                .font(.system(size: 15))
                .foregroundColor(.textPrimary)
                .lineSpacing(4)
            
            #if DEBUG
            // Debug: Show raw sentiment score
            if let sentiment = entry.sentimentScore {
                Text("Sentiment Score: \(String(format: "%.2f", sentiment))")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(sentiment > 0.4 ? .green : sentiment < -0.4 ? .red : .gray)
                    .padding(.top, 4)
            }
            #endif
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.shadowColor, radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.border.opacity(0.2), lineWidth: 1)
        )
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct EditGratitudeSheet: View {
    let entry: GratitudeEntry
    @Binding var text: String
    let onSave: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                TextField("Edit your gratitude", text: $text, axis: .vertical)
                    .font(.system(size: 16))
                    .padding(16)
                    .lineLimit(3...10)
                    .background(Color.lightSky)
                    .cornerRadius(12)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Edit Gratitude")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onDismiss() }
                        .foregroundColor(.deepTeal)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .foregroundColor(.cyanBlue)
                }
            }
        }
    }
}

#Preview {
    GratitudeView()
}
