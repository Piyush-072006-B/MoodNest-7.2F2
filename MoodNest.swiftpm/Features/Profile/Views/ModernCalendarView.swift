import SwiftUI

struct ModernCalendarView: View {
    @State private var currentMonth = Date()
    @State private var selectedDate: Date?
    @State private var moodData: [String: [MoodEntry]] = [:]
    @Binding var selectedTab: TabItem
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    // Calendar instance
    private let calendar = Calendar.current
    
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
                ScrollView {
                    VStack(spacing: 16) {
                        // Compact Header
                        HStack {
                            Button(action: { 
                                withAnimation {
                                    selectedTab = .home
                                }
                            }) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.deepTeal)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 20))
                                    .foregroundColor(.cyanBlue)
                                
                                Text("Mood Calendar")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.deepTeal)
                            }
                            
                            Spacer()
                            
                            // Placeholder for symmetry
                            Color.clear.frame(width: 44)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Month Selector
                        HStack(spacing: 20) {
                            Button(action: {
                                withAnimation(reduceMotion ? .none : .spring(response: 0.4, dampingFraction: 0.8)) {
                                    previousMonth()
                                }
                            }) {
                                Image(systemName: "chevron.left.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.cyanBlue)
                            }
                            
                            Spacer()
                            
                            Text(monthYearString())
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.deepTeal)
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(reduceMotion ? .none : .spring(response: 0.4, dampingFraction: 0.8)) {
                                    nextMonth()
                                }
                            }) {
                                Image(systemName: "chevron.right.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.cyanBlue)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Calendar Grid (More compact)
                        VStack(spacing: 8) {
                            // Day headers
                            HStack(spacing: 0) {
                                ForEach(0..<7, id: \.self) { i in
                                    Text(["M", "T", "W", "T", "F", "S", "S"][i])
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.cyanBlue.opacity(0.8))
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal, 16)
                            
                            // Calendar days
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                                ForEach(0..<42, id: \.self) { index in
                                    let days = getDaysInMonth()
                                    if index < days.count, let date = days[index] {
                                        CalendarDayCell(
                                            date: date,
                                            mood: getMostFrequentMood(for: date),
                                            isToday: calendar.isDateInToday(date),
                                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate ?? Date.distantPast)
                                        )
                                        .onTapGesture {
                                            withAnimation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedDate = date
                                            }
                                        }
                                    } else {
                                        Color.clear
                                            .frame(height: 45)
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            .id(monthYearString())
                            .transition(reduceMotion ? .opacity : .asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                        }
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(20)
                        .shadow(color: Color.deepTeal.opacity(0.05), radius: 10, x: 0, y: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(Color.softAqua.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        
                        // Mood Summary
                        if !moodData.isEmpty {
                            MoodSummarySection(moodData: moodData)
                                .padding(.horizontal, 16)
                        }
                        
                        // Selected date detail
                        if let selected = selectedDate, let entries = moodData[dateKey(selected)], !entries.isEmpty {
                            SelectedDateDetail(date: selected, entries: entries)
                                .padding(.horizontal, 16)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .onAppear {
            loadEntries()
        }
    }
    
    // MARK: - Logic
    
    // Explicitly isolated to MainActor ensures safe access to EmotionalArchive.shared
    @MainActor func loadEntries() {
        let entries = EmotionalArchive.shared.loadAll()
        var grouped: [String: [MoodEntry]] = [:]
        
        for entry in entries {
            let key = dateKey(entry.timestamp)
            grouped[key, default: []].append(entry)
        }
        
        moodData = grouped
    }
    
    func dateKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func monthYearString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    func getDaysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var days: [Date?] = []
        var currentDate = monthFirstWeek.start
        
        // Adjust to start on Monday
        let weekday = calendar.component(.weekday, from: currentDate)
        let daysToSubtract = (weekday == 1) ? 6 : weekday - 2
        if let adjustedStart = calendar.date(byAdding: .day, value: -daysToSubtract, to: currentDate) {
            currentDate = adjustedStart
        }
        
        // 42 days grid (6 weeks)
        for _ in 0..<42 {
            if calendar.component(.month, from: currentDate) == calendar.component(.month, from: currentMonth) {
                days.append(currentDate)
            } else {
                days.append(nil)
            }
            
            if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = nextDate
            }
        }
        
        return days
    }
    
    func getMostFrequentMood(for date: Date) -> String? {
        guard let entries = moodData[dateKey(date)], !entries.isEmpty else { return nil }
        
        // Assuming Entry.emoji property
        let moodCounts = Dictionary(grouping: entries, by: { $0.emoji })
            .mapValues { $0.count }
        
        return moodCounts.max(by: { $0.value < $1.value })?.key
    }
}

// MARK: - Subviews

struct CalendarDayCell: View {
    let date: Date
    let mood: String?
    let isToday: Bool
    let isSelected: Bool
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 13, weight: isToday ? .bold : .medium))
                .foregroundColor(isToday ? .white : .deepTeal)
            
            if let mood = mood {
                Text(mood)
                    .font(.system(size: 18))
            } else {
                Circle()
                    .fill(Color.softAqua.opacity(0.2))
                    .frame(width: 4, height: 4)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 45) // More compact
        .background(
            ZStack {
                if isToday {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.deepTeal)
                } else if isSelected {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.deepTeal, lineWidth: 2)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.softAqua.opacity(0.3)))
                } else if let mood = mood {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(moodColor(for: mood).opacity(0.1))
                }
            }
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    func moodColor(for emoji: String?) -> Color {
        guard let emoji = emoji else { return .gray }
        
        switch emoji {
        case "😊", "😄", "🥰": return .cyanBlue
        case "😌", "🙂": return .softAqua
        case "😐", "🤔": return .softAqua.opacity(0.6)
        case "😔", "😢": return .deepTeal
        case "😰", "😫": return .deepTeal.opacity(0.8)
        default: return .cyanBlue
        }
    }
}

struct MoodSummarySection: View {
    let moodData: [String: [MoodEntry]]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Month")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.deepTeal)
                .padding(.horizontal, 4)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ], spacing: 10) {
                ForEach(getMoodCounts(), id: \.emoji) { stat in
                    StatCard(emoji: stat.emoji, count: stat.count, label: stat.label)
                }
            }
        }
    }
    
    func getMoodCounts() -> [(emoji: String, count: Int, label: String)] {
        let allEntries = moodData.values.flatMap { $0 }
        var counts: [String: Int] = [:]
        
        for entry in allEntries {
            counts[entry.emoji, default: 0] += 1
        }
        
        let labels: [String: String] = [
            "😊": "happy", "😄": "joyful", "🥰": "loved",
            "😌": "calm", "🙂": "content", "😐": "neutral",
            "🤔": "thoughtful", "😔": "sad", "😢": "tearful",
            "😰": "anxious", "😫": "stressed"
        ]
        
        // Returns top moods
        return counts.map { (emoji: $0.key, count: $0.value, label: labels[$0.key] ?? "days") }
            .sorted { $0.count > $1.count }
    }
}

struct StatCard: View {
    let emoji: String
    let count: Int
    let label: String
    
    var body: some View {
        HStack(spacing: 8) {
            Text(emoji)
                .font(.system(size: 24))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(count)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.deepTeal)
                
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(.cyanBlue)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.white.opacity(0.8))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.softAqua.opacity(0.2), lineWidth: 1)
        )
    }
}

struct SelectedDateDetail: View {
    let date: Date
    let entries: [MoodEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(formattedDate())
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.deepTeal)
                .padding(.horizontal, 4)
            
            VStack(spacing: 12) {
                ForEach(entries) { entry in
                    HStack(spacing: 12) {
                        Text(entry.emoji)
                            .font(.system(size: 28))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(formattedTime(entry.timestamp))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.deepTeal)
                            
                            if let note = entry.note, !note.isEmpty {
                                Text(note)
                                    .font(.system(size: 12))
                                    .foregroundColor(.cyanBlue)
                                    .lineLimit(2)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.softAqua.opacity(0.2), lineWidth: 1)
                    )
                }
            }
        }
    }
    
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
    
    func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    ModernCalendarView(selectedTab: .constant(.calendar))
}
