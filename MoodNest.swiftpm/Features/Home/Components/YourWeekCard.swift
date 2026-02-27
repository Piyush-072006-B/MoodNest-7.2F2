import SwiftUI

struct YourWeekCard: View {
    @State private var moodEntries: [MoodEntry] = []
    @State private var selectedDay: Int? = nil
    @State private var weekDays: [(day: String, date: Date, mood: String?)] = []
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Week")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.textPrimary)
            
            // Mood dots timeline with connecting line
            ZStack(alignment: .center) {
                // Connecting line (Behind dots)
                Rectangle()
                    .fill(Color.deepTeal.opacity(0.1))
                    .frame(height: 1.5)
                    .padding(.horizontal, 25)
                
                // Mood dots
                HStack(spacing: 0) {
                    ForEach(Array(weekDays.enumerated()), id: \.offset) { index, dayData in
                        VStack(spacing: 12) {
                            Text(dayData.day)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.textSecondary)
                            
                            Button(action: {
                                withAnimation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedDay = selectedDay == index ? nil : index
                                }
                                // Haptic feedback
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            }) {
                                ZStack {
                                    if let mood = dayData.mood {
                                        // Glow background for logged moods
                                        Circle()
                                            .fill(moodColor(for: mood))
                                            .frame(width: 28, height: 28)
                                            .shadow(
                                                color: moodColor(for: mood).opacity(0.4),
                                                radius: selectedDay == index ? 10 : 6
                                            )
                                        
                                        // The emoji itself or a colored dot? 
                                        // User said "Each dot should reflect the emoji color and mood"
                                        // Let's show a subtle emoji or just the color dot with a checkmark?
                                        // Actually, let's show the emoji itself if it's there, but small.
                                        Text(mood)
                                            .font(.system(size: 14))
                                    } else {
                                        // Empty state dot
                                        Circle()
                                            .strokeBorder(Color.deepTeal.opacity(0.15), lineWidth: 1.5)
                                            .frame(width: 24, height: 24)
                                    }
                                    
                                    // Selection ring
                                    if selectedDay == index {
                                        Circle()
                                            .strokeBorder(Color.deepTeal, lineWidth: 2)
                                            .frame(width: 36, height: 36)
                                    }
                                }
                                .scaleEffect(selectedDay == index ? 1.15 : 1.0)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.vertical, 4)
            
            // Preview of selected day
            if let selectedIndex = selectedDay {
                let dayData = weekDays[selectedIndex]
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 12) {
                        if let mood = dayData.mood {
                            Text(mood)
                                .font(.system(size: 36))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(formatDate(dayData.date))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.textPrimary)
                                
                                Text(moodLabel(for: mood))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.textSecondary)
                            }
                        } else {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 24))
                                .foregroundColor(.softAqua)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(formatDate(dayData.date))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.textPrimary)
                                
                                Text("No entry yet")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.deepTeal.opacity(0.1), lineWidth: 1)
                    )
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(20)
        .background(
            ZStack {
                Color.white.opacity(0.5)
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(Color.softAqua.opacity(0.3), lineWidth: 1.5)
            }
        )
        .cornerRadius(24)
        .shadow(color: Color.deepTeal.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 16)
        .onAppear {
            loadWeekData()
        }
    }
    
    func loadWeekData() {
        moodEntries = EmotionalArchive.shared.loadAll()
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Get last 7 days including today (6 days ago -> today)
        weekDays = (0..<7).reversed().map { daysAgo in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) ?? today
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "E"
            // Use single letter if possible or short string
            let dayString = dayFormatter.string(from: date).prefix(1).uppercased()
            
            // Find ALL moods for this day and pick the latest or most representative
            let dayEntries = moodEntries.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
            let mood = dayEntries.last?.emoji // Latest mood of the day
            
            return (day: dayString, date: date, mood: mood)
        }
        
        // Auto-select today if not already something selected
        if selectedDay == nil {
            selectedDay = 6 // Index of today
        }
    }
    
    func moodColor(for emoji: String) -> Color {
        switch emoji {
        case "😃", "😊", "😄", "🥰": return .cyanBlue
        case "🙂", "😌": return .softAqua
        case "😐", "🤔": return .softAqua.opacity(0.6)
        case "🙁", "😔": return .deepTeal
        case "😢", "😰", "😫": return .deepTeal.opacity(0.8)
        default: return .cyanBlue
        }
    }
    
    func moodLabel(for emoji: String) -> String {
        switch emoji {
        case "😃", "😄": return "Feeling Great"
        case "😊", "🥰": return "Feeling Loved"
        case "🙂", "😌": return "Feeling Good"
        case "😐", "🤔": return "Feeling Okay"
        case "🙁", "😔": return "Feeling Sad"
        case "😢", "😰": return "Feeling Down"
        case "😫": return "Feeling Stressed"
        default: return "Mood logged"
        }
    }
    
    func formatDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return "Today" }
        if Calendar.current.isDateInYesterday(date) { return "Yesterday" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
}

#Preview {
    ZStack {
        Color.lightSky.ignoresSafeArea()
        YourWeekCard()
    }
}
