import SwiftUI

// MARK: - Emotional Spectrum

private struct EmotionalSpectrum {
    /// Maps a slider value (-1…1) to the nearest mood zone emoji
    static func emoji(for value: Double) -> String {
        switch value {
        case ..<(-0.75): return "😢"
        case ..<(-0.25): return "😔"
        case ..<0.25:    return "😐"
        case ..<0.75:    return "😊"
        default:         return "😃"
        }
    }

    /// Snaps raw value to the nearest zone center
    static func snap(_ value: Double) -> Double {
        let zones: [Double] = [-1.0, -0.5, 0.0, 0.5, 1.0]
        return zones.min(by: { abs($0 - value) < abs($1 - value) }) ?? 0.0
    }

    /// Gradient colors for the slider track
    static let gradientColors: [Color] = [
        Color.red.opacity(0.7),
        Color.orange,
        Color.yellow,
        Color.green,
        Color.cyanBlue
    ]
}

// MARK: - CheckInHelper

private struct CheckInHelper {
    static func mapMoodToEmoji(_ moodName: String) -> String {
        switch moodName.lowercased() {
        case "great": return "😃"
        case "good": return "🙂"
        case "okay", "neutral": return "😐"
        case "down", "sad": return "🙁"
        case "struggling", "terrible": return "😢"
        default: return "😐"
        }
    }

    static func calculateStreak(from entries: [MoodEntry]) -> Int {
        guard !entries.isEmpty else { return 0 }
        let calendar = Calendar.current
        let sortedEntries = entries.sorted { $0.timestamp > $1.timestamp }
        var streak = 0
        var currentDate = Date()

        for entry in sortedEntries {
            if calendar.isDate(entry.timestamp, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else if calendar.isDate(entry.timestamp, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        return streak
    }
}

// MARK: - ModernCheckInView

struct ModernCheckInView: View {
    @Binding var selectedTab: TabItem
    @StateObject private var moodManager = CustomMoodManager.shared
    @State private var selectedMood: String? = nil
    @State private var selectedMoodId: UUID? = nil
    @State private var moodNote: String = ""
    @State private var showConfirmation = false
    @State private var showConfetti = false
    @State private var showRecoveryBanner = false
    @State private var recoveryRecommendation: RecoveryRecommendation? = nil
    @State private var todayEntries: [MoodEntry] = []

    // Phase 3: Spectrum & Intensity
    @State private var spectrumValue: Double = 0.0
    @State private var moodIntensity: Int = 3
    @State private var showCustomMoodSheet = false
    @State private var inputMode: MoodInputMode = .emoji

    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    enum MoodInputMode: String, CaseIterable {
        case emoji = "Emoji"
        case spectrum = "Spectrum"
    }

    var body: some View {
        ZStack {
            Color.lightSky
                .overlay(
                    AnimatedBackground(
                        particleType: .sparkle,
                        particleCount: 25,
                        colors: [.softAqua, .cyanBlue, .deepTeal.opacity(0.3)]
                    )
                    .opacity(0.3)
                )
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerBar
                
                ScrollView {
                    VStack(spacing: 28) {
                        // Title
                        titleSection

                        // Input Mode Toggle
                        inputModeToggle

                        // Mood Selector
                        if inputMode == .emoji {
                            emojiSelector
                        } else {
                            spectrumSlider
                        }

                        // Mood Intensity
                        intensitySelector

                        // Reflection Prompt
                        if let mood = selectedMood, ["🙁", "😢"].contains(mood) {
                            Text("Would you like to write about what's making you feel this way?")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.deepTeal)
                                .padding(.horizontal, 20)
                                .transition(.opacity)
                        }

                        // Note Input
                        noteInput

                        // Save Button
                        PrimaryButton(
                            title: "Save Mood",
                            action: saveMood,
                            isEnabled: selectedMood != nil
                        )
                        .padding(.horizontal, 20)

                        // Confirmation
                        if showConfirmation {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .stroke(Color.cyanBlue, lineWidth: 2)
                                        .frame(width: 28, height: 28)
                                        .scaleEffect(showConfirmation ? 1.5 : 0.5)
                                        .opacity(showConfirmation ? 0 : 1)
                                        .animation(reduceMotion ? .none : .easeOut(duration: 0.6), value: showConfirmation)
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.deepTeal)
                                        .font(.system(size: 20))
                                }
                                Text("Mood saved!")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.deepTeal)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
                        }

                        // Recovery banner (low mood)
                        if showRecoveryBanner, let rec = recoveryRecommendation {
                            RecoveryBanner(
                                recommendation: rec,
                                onAccept: {
                                    showRecoveryBanner = false
                                    recoveryRecommendation = nil
                                    dismiss()
                                    selectedTab = .focus
                                },
                                onDismiss: {
                                    showRecoveryBanner = false
                                    recoveryRecommendation = nil
                                }
                            )
                            .padding(.horizontal, 20)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        // Today's Entries
                        if !todayEntries.isEmpty {
                            todaySection
                        }
                    }
                    .padding(.bottom, 40)
                }
            }

            // Confetti overlay
            if showConfetti {
                ConfettiView(particleCount: 60)
                    .allowsHitTesting(false)
            }
        }
        .onAppear { loadTodayEntries() }
        .sheet(isPresented: $showCustomMoodSheet) {
            MoodEditSheet(mood: nil)
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.deepTeal.opacity(0.3))
            }

            Spacer()

            Button(action: { showCustomMoodSheet = true }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.cyanBlue)
            }
            .accessibilityLabel("Create custom mood")
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    // MARK: - Title

    private var titleSection: some View {
        VStack(spacing: 8) {
            Text("How are you")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.deepTeal)

            Text("feeling today?")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.deepTeal)

            Text("Tap to select your mood")
                .font(.system(size: 16))
                .foregroundColor(.cyanBlue)
                .padding(.top, 4)
        }
        .padding(.top, 20)
    }

    // MARK: - Input Mode Toggle

    private var inputModeToggle: some View {
        Picker("Input Mode", selection: $inputMode) {
            ForEach(MoodInputMode.allCases, id: \.self) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal, 40)
    }

    // MARK: - Emoji Selector

    private var emojiSelector: some View {
        VStack(spacing: 12) {
            // Custom moods first (non-default)
            let customOnly = moodManager.customMoods.filter { !$0.isDefault }
            if !customOnly.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(customOnly) { mood in
                            MoodButton(
                                iconName: mood.iconName,
                                label: mood.name,
                                color: mood.color,
                                isSelected: selectedMoodId == mood.id,
                                reduceMotion: reduceMotion
                            ) {
                                selectMood(mood)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }

            // Default moods
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(moodManager.customMoods.filter { $0.isDefault }) { mood in
                        MoodButton(
                            iconName: mood.iconName,
                            label: mood.name,
                            color: mood.color,
                            isSelected: selectedMoodId == mood.id,
                            reduceMotion: reduceMotion
                        ) {
                            selectMood(mood)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Spectrum Slider

    private var spectrumSlider: some View {
        VStack(spacing: 16) {
            // Current mood emoji
            Text(EmotionalSpectrum.emoji(for: spectrumValue))
                .font(.system(size: 56))
                .scaleEffect(reduceMotion ? 1.0 : 1.0 + 0.1 * abs(spectrumValue))
                .animation(reduceMotion ? .none : .easeInOut(duration: 0.3), value: spectrumValue)
                .shadow(
                    color: spectrumGlowColor.opacity(0.3),
                    radius: 10, x: 0, y: 0
                )

            // Gradient slider track
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: EmotionalSpectrum.gradientColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 8)

                // Native slider overlaid
                Slider(value: $spectrumValue, in: -1.0...1.0, step: 0.01) { editing in
                    if !editing {
                        let snapped = EmotionalSpectrum.snap(spectrumValue)
                        withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.2)) {
                            spectrumValue = snapped
                        }
                        selectedMood = EmotionalSpectrum.emoji(for: snapped)
                        HapticManager.selection()
                    }
                }
                .tint(.clear)
            }
            .padding(.horizontal, 20)

            // Zone labels
            HStack {
                Text("😢")
                Spacer()
                Text("😔")
                Spacer()
                Text("😐")
                Spacer()
                Text("😊")
                Spacer()
                Text("😃")
            }
            .font(.system(size: 20))
            .padding(.horizontal, 24)

            Text(spectrumLabel)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.deepTeal)
        }
        .padding(20)
        .glassCard(cornerRadius: 16)
        .padding(.horizontal, 16)
        .onChange(of: spectrumValue, perform: { _ in
            selectedMood = EmotionalSpectrum.emoji(for: spectrumValue)
        })
    }

    private var spectrumLabel: String {
        switch EmotionalSpectrum.snap(spectrumValue) {
        case -1.0: return "Struggling"
        case -0.5: return "Feeling Down"
        case  0.0: return "Neutral"
        case  0.5: return "Feeling Good"
        case  1.0: return "Feeling Great"
        default:   return "Neutral"
        }
    }

    private var spectrumGlowColor: Color {
        let s = EmotionalSpectrum.snap(spectrumValue)
        if s < -0.25 { return .red }
        if s < 0.25  { return .yellow }
        return .green
    }

    // MARK: - Intensity Selector

    private var intensitySelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Intensity")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.deepTeal)

            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { level in
                    Button(action: {
                        moodIntensity = level
                        HapticManager.light()
                    }) {
                        Text("\(level)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(moodIntensity == level ? .white : .cyanBlue)
                            .frame(width: 44, height: 36)
                            .background(
                                Capsule()
                                    .fill(moodIntensity == level ? Color.cyanBlue : Color.softAqua.opacity(0.18))
                            )
                            .overlay(
                                Capsule()
                                    .strokeBorder(moodIntensity == level ? Color.cyanBlue : Color.softAqua.opacity(0.3), lineWidth: 1)
                            )
                    }
                }

                Spacer()

                Text(intensityLabel)
                    .font(.system(size: 12))
                    .foregroundColor(.softAqua)
            }
        }
        .padding(.horizontal, 20)
    }

    private var intensityLabel: String {
        switch moodIntensity {
        case 1: return "Barely"
        case 2: return "Mildly"
        case 3: return "Moderate"
        case 4: return "Strongly"
        case 5: return "Intensely"
        default: return ""
        }
    }

    // MARK: - Note Input

    private var noteInput: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add a note (optional)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.deepTeal)

            TextField("How are you feeling?", text: $moodNote, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(16)
                .background(Color.white.opacity(0.5))
                .cornerRadius(12)
                .lineLimit(3...6)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: - Today's Entries

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Check-ins")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.deepTeal)

            ForEach(todayEntries) { entry in
                TodayEntryCard(entry: entry)
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Actions

    private func selectMood(_ mood: CustomMood) {
        HapticManager.selection()
        withAnimation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.6)) {
            selectedMoodId = mood.id
            selectedMood = CheckInHelper.mapMoodToEmoji(mood.name)
        }
    }

    func saveMood() {
        print("[saveMood] ▶︎ called. selectedMood=\(selectedMood ?? "nil")")
        guard let mood = selectedMood else {
            print("[saveMood] ✖ aborted — no mood selected")
            return
        }

        // Append intensity metadata to note
        var noteText = moodNote
        if !noteText.isEmpty { noteText += "\n" }
        noteText += "[intensity:\(moodIntensity)]"

        let entry = MoodEntry(
            emoji: mood,
            timestamp: Date(),
            note: noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : noteText
        )
        print("[saveMood] ✔ MoodEntry created: emoji=\(entry.emoji), id=\(entry.id)")

        EmotionalArchive.shared.save(entry)
        print("[saveMood] ✔ EmotionalArchive.save() complete — total entries: \(EmotionalArchive.shared.loadAll().count)")

        let score = InsightComposer.moodScore(for: mood)
        print("[saveMood] ✔ moodScore=\(score)")
        if let rec = RecoveryEngine.recommendation(for: score) {
            recoveryRecommendation = rec
            withAnimation(.easeOut(duration: 0.3)) { showRecoveryBanner = true }
            HapticManager.light()
            print("[saveMood] ✔ RecoveryBanner shown")
        }

        // Streak achievemens — runs on @MainActor
        let allEntries = EmotionalArchive.shared.loadAll()
        guard !allEntries.isEmpty else {
            print("[saveMood] ⚠ allEntries empty — skipping streak check")
            return
        }
        let streak = CheckInHelper.calculateStreak(from: allEntries)
        print("[saveMood] ✔ Streak calculated: \(streak)")
        Task { @MainActor in
            AchievementManager.shared.checkStreakMilestones(streak: streak)
        }

        // Show confetti
        withAnimation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.7)) {
            showConfetti = true
            showConfirmation = true
        }
        HapticManager.success()
        print("[saveMood] ✔ Confetti + confirmation shown")

        // Reset form
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(reduceMotion ? .none : .easeInOut) {
                self.showConfetti = false
                self.showConfirmation = false
                self.selectedMood = nil
                self.selectedMoodId = nil
                self.moodNote = ""
                self.moodIntensity = 3
                self.spectrumValue = 0.0
                self.loadTodayEntries()
            }
            print("[saveMood] ✔ Form reset complete")
        }
    }

    func loadTodayEntries() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        todayEntries = EmotionalArchive.shared.loadAll().filter { entry in
            calendar.isDate(entry.timestamp, inSameDayAs: today)
        }.sorted { $0.timestamp > $1.timestamp }
    }
}

// MARK: - Recovery Banner (low mood → suggest reset)

private struct RecoveryBanner: View {
    let recommendation: RecoveryRecommendation
    let onAccept: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "wind")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Would you like a 2-minute reset?")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text(recommendation.subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.9))
                }
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Color.cyanBlue, Color.deepTeal],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(14)

            Button(action: onAccept) {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 14))
                    Text("Go to breathing")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.cyanBlue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - MoodButton

struct MoodButton: View {
    let iconName: String
    let label: String
    let color: Color
    let isSelected: Bool
    let reduceMotion: Bool
    let action: () -> Void

    /// Validates the SF Symbol name at runtime; returns a safe fallback if invalid.
    private var safeIconName: String {
        guard !iconName.isEmpty,
              UIImage(systemName: iconName) != nil else {
            return "face.smiling"
        }
        return iconName
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: safeIconName)
                    .font(.system(size: 40))
                    .foregroundColor(isSelected ? color : .cyanBlue)
                    .frame(width: 90, height: 90)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(isSelected ? color.opacity(0.1) : Color.white.opacity(0.5))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(isSelected ? color : Color.softAqua.opacity(0.3), lineWidth: isSelected ? 3 : 1)
                    )
                    .shadow(
                        color: isSelected ? color.opacity(0.3) : .clear,
                        radius: isSelected ? 8 : 0
                    )
                    .scaleEffect(isSelected ? 1.05 : 1.0)

                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? color : .cyanBlue)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .animation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - TodayEntryCard

struct TodayEntryCard: View {
    let entry: MoodEntry

    /// Validates the mapped SF Symbol name before rendering.
    private var safeIconName: String {
        let name = entry.iconName
        guard UIImage(systemName: name) != nil else { return "face.dashed" }
        return name
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: safeIconName)
                .font(.system(size: 24))
                .foregroundColor(.deepTeal)

            VStack(alignment: .leading, spacing: 4) {
                Text(formatTime(entry.timestamp))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.deepTeal)

                if let note = entry.note, !note.isEmpty {
                    // Strip metadata from display
                    let displayNote = note
                        .components(separatedBy: "\n")
                        .filter { !$0.hasPrefix("[intensity:") }
                        .joined(separator: " ")
                    if !displayNote.isEmpty {
                        Text(displayNote)
                            .font(.system(size: 12))
                            .foregroundColor(.cyanBlue)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()
        }
        .padding(12)
        .glassCard(cornerRadius: 12)
    }

    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ModernCheckInView(selectedTab: .constant(.home))
}
