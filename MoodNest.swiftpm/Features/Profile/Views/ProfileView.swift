import SwiftUI


struct ProfileView: View {
    @State private var moodCount = 0
    @State private var gratitudeCount = 0
    @State private var journalCount = 0
    @State private var selfCareCount = 0
    @State private var daysUsing = 0
    @State private var userName = ""
    @State private var isEditingName = false
    @State private var tempName = ""
    @State private var showInsights = false
    @State private var hasAnimatedStats = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @AppStorage("moodnest_appTheme") private var appTheme: String = "System"
    @AppStorage("moodnest_reminderEnabled") private var reminderEnabled = false
    @AppStorage("moodnest_reminderHour") private var reminderHour = 9
    @AppStorage("moodnest_reminderMinute") private var reminderMinute = 0
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showMoodEditor = false
    @State private var weeklyInsight: BehavioralInsight? = nil

    #if DEBUG
    @State private var testSentimentScore: Double = 0.0
    @State private var showTestResult = false
    #endif
    
    var body: some View {
        ZStack {
            DecorativeBackground(
                gradient: LinearGradient(
                    colors: [Color.lightSky, Color.softAqua.opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.cyanBlue)
                        
                        Text(userName.isEmpty ? "Welcome Back!" : "Hello, \(userName)!")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.deepTeal)
                        
                        Button(action: {
                            tempName = userName
                            isEditingName = true
                        }) {
                            Text(userName.isEmpty ? "Set Your Name" : "Edit Name")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.cyanBlue)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.softAqua.opacity(0.2))
                                .cornerRadius(20)
                        }
                    }
                    .padding(.top, 40)
                    
                    // Stats Grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Stats")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.deepTeal)
                            .padding(.horizontal, 20)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 12) {
                            ProfileStatCard(
                                icon: "face.smiling",
                                count: moodCount,
                                label: "Mood Logs",
                                color: .cyanBlue
                            )
                            
                            ProfileStatCard(
                                icon: "star.fill",
                                count: gratitudeCount,
                                label: "Gratitude",
                                color: .softAqua
                            )
                            
                            ProfileStatCard(
                                icon: "book.fill",
                                count: journalCount,
                                label: "Journal",
                                color: .deepTeal
                            )
                            
                            ProfileStatCard(
                                icon: "sparkles",
                                count: selfCareCount,
                                label: "Self-Care",
                                color: .softAqua
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 20) // This padding is applied to the VStack containing the stats grid.
                    
                    #if DEBUG
    // Debug: Sentiment Analysis Testing
    VStack(alignment: .leading, spacing: 12) {
        Text("Debug: Sentiment Analysis")
            .font(.caption)
            .foregroundColor(.gray)
        
        HStack {
            Button("Test Positive") {
                testSentimentScore = SentimentAnalyzer.emotionalTone(from: "I am feeling great and happy today!")
                showTestResult = true
                showTestResultEffect()
            }
            .font(.caption)
            .padding(8)
            .background(Color.green.opacity(0.2))
            .cornerRadius(8)
            
            Button("Test Negative") {
                testSentimentScore = SentimentAnalyzer.emotionalTone(from: "I am feeling sad and terrible.")
                showTestResult = true
                showTestResultEffect()
            }
            .font(.caption)
            .padding(8)
            .background(Color.red.opacity(0.2))
            .cornerRadius(8)
        }
    }
    .padding(.horizontal, 20)
    .padding(.top, 8)
    
    if showTestResult {
         VStack(spacing: 8) {
            Text("✅ Test Complete!")
                .font(.system(size: 14, weight: .bold))
            Text("Score: \(String(format: "%.2f", testSentimentScore))")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(getSentimentColor(for: testSentimentScore))
             Text("Check console for results")
                 .font(.caption)
                 .foregroundColor(.secondary)
         }
         .padding(16)
         .background(Color.white)
         .cornerRadius(12)
         .shadow(radius: 5)
    }
    #endif
                    
                    // Weekly behavioral insight
                    if let insight = weeklyInsight {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("This Week's Insight")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.deepTeal)
                                .padding(.horizontal, 20)
                            BehavioralInsightCard(insight: insight, showConfidence: false)
                                .padding(.horizontal, 20)
                        }
                    }

                    // Days Using Card
                    HStack(spacing: 16) {
                        Image(systemName: "calendar.badge.checkmark")
                            .font(.system(size: 32))
                            .foregroundColor(.deepTeal)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(daysUsing) Days")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.deepTeal)
                            
                            Text("Using MoodNest")
                                .font(.system(size: 14))
                                .foregroundColor(.cyanBlue)
                        }
                        
                        Spacer()
                    }
                    .padding(20)
                    .background(Color.softAqua.opacity(0.15))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.deepTeal.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    // Mood Insights Button
                    Button(action: { showInsights = true }) {
                        HStack(spacing: 16) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.cyanBlue)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Mood Insights")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.deepTeal)
                                
                                Text("View your mood analytics")
                                    .font(.system(size: 14))
                                    .foregroundColor(.softAqua)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.cyanBlue)
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(16)
                        .shadow(color: Color.deepTeal.opacity(0.1), radius: 8, x: 0, y: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color.softAqua.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 20)
                    
                    // Edit Mood List Button
                    Button(action: { showMoodEditor = true }) {
                        HStack(spacing: 16) {
                            Image(systemName: "face.smiling")
                                .font(.system(size: 32))
                                .foregroundColor(.deepTeal)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Edit Mood List")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.deepTeal)
                                
                                Text("Customize your mood options")
                                    .font(.system(size: 14))
                                    .foregroundColor(.softAqua)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.cyanBlue)
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(16)
                        .shadow(color: Color.deepTeal.opacity(0.1), radius: 8, x: 0, y: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color.softAqua.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 20)
                    
                    // Settings Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Settings")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.deepTeal)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 0) {
                            // Theme Picker Row
                            HStack {
                                Image(systemName: "circle.lefthalf.filled")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Color.deepTeal)
                                    .cornerRadius(10)
                                
                                Text("Appearance")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.deepTeal)
                                
                                Spacer()
                                
                                Picker("Appearance", selection: $appTheme) {
                                    Text("System").tag("System")
                                    Text("Light").tag("Light")
                                    Text("Dark").tag("Dark")
                                }
                                .pickerStyle(MenuPickerStyle())
                                .accentColor(.cyanBlue)
                            }
                            .padding(16)
                        }
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 20)
                    }
                    
                    // Reminders Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Reminders")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.deepTeal)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            // Enable/Disable Toggle
                            HStack {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Color.cyanBlue)
                                    .cornerRadius(10)
                                
                                Text("Daily Check-In")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.deepTeal)
                                
                                Spacer()
                                
                                Toggle("", isOn: $reminderEnabled)
                                    .labelsHidden()
                                    .tint(.cyanBlue)
                                    .onChange(of: reminderEnabled, perform: { newValue in
                                        Task {
                                            if newValue {
                                                await notificationManager.scheduleDailyReminder(
                                                    hour: reminderHour,
                                                    minute: reminderMinute
                                                )
                                            } else {
                                                notificationManager.cancelDailyReminder()
                                            }
                                            HapticManager.success()
                                        }
                                    })
                            }
                            .padding(16)
                            
                            if reminderEnabled {
                                Divider()
                                    .padding(.horizontal, 16)
                                
                                // Time Picker
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.softAqua)
                                    
                                    Text("Reminder Time")
                                        .font(.system(size: 14))
                                        .foregroundColor(.deepTeal)
                                    
                                    Spacer()
                                    
                                    DatePicker(
                                        "",
                                        selection: Binding(
                                            get: {
                                                var components = DateComponents()
                                                components.hour = reminderHour
                                                components.minute = reminderMinute
                                                return Calendar.current.date(from: components) ?? Date()
                                            },
                                            set: { newDate in
                                                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                                                reminderHour = components.hour ?? 9
                                                reminderMinute = components.minute ?? 0
                                                
                                                Task {
                                                    await notificationManager.scheduleDailyReminder(
                                                        hour: reminderHour,
                                                        minute: reminderMinute
                                                    )
                                                    HapticManager.success()
                                                }
                                            }
                                        ),
                                        displayedComponents: .hourAndMinute
                                    )
                                    .labelsHidden()
                                    .accentColor(.cyanBlue)
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 16)
                            }
                        }
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 20)
                    }
                    
                    // App Version
                    Text("MoodNest v1.0")
                        .font(.system(size: 12))
                        .foregroundColor(.softAqua)
                        .padding(.top, 20)
                        .padding(.bottom, 140)
                }
            }
        }
        .onAppear {
            loadStats()
            loadUserName()
        }
        .sheet(isPresented: $isEditingName) {
            NameEditSheet(name: $tempName, isPresented: $isEditingName, onSave: {
                userName = tempName
                saveUserName()
            })
        }
        .sheet(isPresented: $showInsights) {
            MoodInsightsView()
        }
        .sheet(isPresented: $showMoodEditor) {
            CustomMoodEditorView()
        }
    }
    
    func loadStats() {
        let moods    = EmotionalArchive.shared.loadAll()
        let journals  = JournalDataStore.shared.loadAll()
        let selfCare  = SelfCareDataStore.shared.loadAll()
        weeklyInsight = InsightComposer.analyze(moods: moods, journals: journals, selfCare: selfCare).first

        let targetMoodCount      = moods.count
        let targetGratitudeCount = GratitudeDataStore.shared.loadAll().count
        let targetJournalCount = JournalDataStore.shared.loadAll().count
        let targetSelfCareCount = SelfCareDataStore.shared.loadAll().count
        
        let allDates = EmotionalArchive.shared.loadAll().map { $0.timestamp }
        let targetDays: Int
        if let firstDate = allDates.min() {
            let calendar = Calendar.current
            let days = calendar.dateComponents([.day], from: firstDate, to: Date()).day ?? 0
            targetDays = max(1, days + 1)
        } else {
            targetDays = 1
        }
        
        if reduceMotion || hasAnimatedStats {
            moodCount = targetMoodCount
            gratitudeCount = targetGratitudeCount
            journalCount = targetJournalCount
            selfCareCount = targetSelfCareCount
            daysUsing = targetDays
            hasAnimatedStats = true
        } else {
            hasAnimatedStats = true
            animateCount(targetMoodCount, into: $moodCount)
            animateCount(targetGratitudeCount, into: $gratitudeCount)
            animateCount(targetJournalCount, into: $journalCount)
            animateCount(targetSelfCareCount, into: $selfCareCount)
            animateCount(targetDays, into: $daysUsing)
        }
    }
    
    private func animateCount(_ target: Int, into binding: Binding<Int>) {
        guard target > 0 else { return }
        let duration: TimeInterval = 1.0
        let steps = 30
        let stepDuration = duration / Double(steps)
        let increment = max(1, target / steps)
        
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                if i == steps || binding.wrappedValue + increment > target {
                    binding.wrappedValue = target
                } else {
                    binding.wrappedValue += increment
                }
            }
        }
    }
    
    #if DEBUG
    func testSentimentAnalysis() {
        // Test the specific requested phrase
        let testPhrase = "I'm feeling hopeful and motivated today."
        let score = SentimentAnalyzer.emotionalTone(from: testPhrase)
        
        // Update state for visual feedback
        testSentimentScore = score
        showTestResult = true
        showTestResultEffect()
        
        // Hide result after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showTestResult = false
        }
    }
    
    func showTestResultEffect() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func getSentimentColor(for score: Double) -> Color {
        let values = SentimentAnalyzer.sentimentColor(for: score)
        return Color(hue: values.hue, saturation: values.saturation, brightness: values.brightness)
    }
    #endif
    
    func loadUserName() {
        userName = UserDefaults.standard.string(forKey: "userName") ?? ""
    }
    
    func saveUserName() {
        UserDefaults.standard.set(userName, forKey: "userName")
    }
}

struct ProfileStatCard: View {
    let icon: String
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            
            Text("\(count)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.deepTeal)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.cyanBlue)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.7))
        .cornerRadius(16)
        .shadow(color: Color.deepTeal.opacity(0.05), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.softAqua.opacity(0.2), lineWidth: 1)
        )
    }
}

struct NameEditSheet: View {
    @Binding var name: String
    @Binding var isPresented: Bool
    let onSave: () -> Void
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.cyanBlue)
                    
                    Text("What should we call you?")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.deepTeal)
                }
                .padding(.top, 40)
                
                TextField("Your name", text: $name)
                    .font(.system(size: 18))
                    .padding(16)
                    .background(Color.lightSky)
                    .cornerRadius(12)
                    .focused($isTextFieldFocused)
                    .padding(.horizontal, 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.softAqua.opacity(0.5), lineWidth: 1)
                            .padding(.horizontal, 20)
                    )
                
                Spacer()
                
                PrimaryButton(
                    title: "Save",
                    action: {
                        onSave()
                        isPresented = false
                    },
                    isEnabled: !name.trimmingCharacters(in: .whitespaces).isEmpty
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .background(Color.mainBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.deepTeal)
                }
            }
            .onAppear {
                isTextFieldFocused = true
            }
        }
    }
}

// #Preview {
//    ProfileView()
// }
