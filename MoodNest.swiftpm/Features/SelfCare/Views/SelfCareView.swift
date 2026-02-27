import SwiftUI

struct ActivityTemplate: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
}

struct SelfCareView: View {
    @State private var todayActivities: [SelfCareEntry] = []
    @State private var streak = 0
    @State private var showConfirmation = false
    @State private var editingEntry: SelfCareEntry?
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    let predefinedActivities: [ActivityTemplate] = [
        // Physical (5)
        ActivityTemplate(name: "Exercise", icon: "figure.walk", color: .cyanBlue),
        ActivityTemplate(name: "Yoga", icon: "figure.yoga", color: .softAqua),
        ActivityTemplate(name: "Walk Outside", icon: "figure.outdoor.cycle", color: .deepTeal),
        ActivityTemplate(name: "Hydrate", icon: "drop.fill", color: .cyanBlue.opacity(0.7)),
        ActivityTemplate(name: "Healthy Meal", icon: "leaf.fill", color: .softAqua.opacity(0.8)),
        
        // Mental (5)
        ActivityTemplate(name: "Meditation", icon: "figure.mind.and.body", color: .cyanBlue),
        ActivityTemplate(name: "Reading", icon: "book.fill", color: .deepTeal.opacity(0.8)),
        ActivityTemplate(name: "Journaling", icon: "pencil.and.outline", color: .softAqua),
        ActivityTemplate(name: "Breathing", icon: "wind", color: .cyanBlue.opacity(0.6)),
        ActivityTemplate(name: "Mindfulness", icon: "leaf.circle", color: .deepTeal.opacity(0.7)),
        
        // Social (4)
        ActivityTemplate(name: "Call Friend", icon: "phone.fill", color: .cyanBlue),
        ActivityTemplate(name: "Quality Time", icon: "heart.fill", color: .softAqua),
        ActivityTemplate(name: "Help Someone", icon: "hands.sparkles", color: .deepTeal.opacity(0.6)),
        ActivityTemplate(name: "Join Group", icon: "person.3.fill", color: .cyanBlue.opacity(0.7)),
        
        // Creative (3)
        ActivityTemplate(name: "Art/Drawing", icon: "paintbrush.fill", color: .softAqua),
        ActivityTemplate(name: "Music", icon: "music.note", color: .cyanBlue),
        ActivityTemplate(name: "Crafts", icon: "scissors", color: .deepTeal.opacity(0.8)),
        
        // Rest (5)
        ActivityTemplate(name: "Nap", icon: "bed.double.fill", color: .deepTeal.opacity(0.6)),
        ActivityTemplate(name: "Bath/Shower", icon: "drop.triangle.fill", color: .cyanBlue.opacity(0.6)),
        ActivityTemplate(name: "Sunlight", icon: "sun.max.fill", color: .softAqua.opacity(0.9)),
        ActivityTemplate(name: "Stretch", icon: "figure.flexibility", color: .cyanBlue.opacity(0.7)),
        ActivityTemplate(name: "Digital Detox", icon: "iphone.slash", color: .deepTeal.opacity(0.7))
    ]
    
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
                        Image(systemName: "sparkles")
                            .font(.system(size: 20))
                            .foregroundColor(.cyanBlue)
                        
                        Text("Self-Care")
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
                        // Streak Card
                        HStack(spacing: 16) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.cyanBlue)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(streak) Day Streak")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.deepTeal)
                                
                                Text("Keep it going!")
                                    .font(.system(size: 14))
                                    .foregroundColor(.softAqua)
                            }
                            
                            Spacer()
                        }
                        .padding(20)
                        .background(Color.softAqua.opacity(0.2))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color.softAqua.opacity(0.4), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Activity Grid
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Log an activity")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.deepTeal)
                                
                                Spacer()
                                
                                Text("Unlock badges!")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.cyanBlue)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.softAqua.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal, 20)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 12) {
                                ForEach(predefinedActivities) { activity in
                                    ActivityButton(
                                        name: activity.name,
                                        icon: activity.icon,
                                        color: activity.color,
                                        action: {
                                            logActivity(activity.name)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Today's Activities
                        if !todayActivities.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Today's self-care")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.deepTeal)
                                    .padding(.horizontal, 20)
                                
                                ForEach(todayActivities) { entry in
                                    ActivityCard(entry: entry, onDelete: {
                                        deleteActivity(entry)
                                    })
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.top, 8)
                        }
                        
                        // Confirmation
                        if showConfirmation {
                            HStack(spacing: 8) {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                    .shadow(color: .orange.opacity(0.8), radius: 5, x: 0, y: 0)
                                Text("Activity logged!")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.deepTeal)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            loadData()
        }
    }
    
    func logActivity(_ name: String) {
        let entry = SelfCareEntry(activity: name, completed: true)
        SelfCareDataStore.shared.save(entry)
        
        HapticManager.success()
        withAnimation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.7)) {
            showConfirmation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(reduceMotion ? .none : .easeInOut) {
                showConfirmation = false
                loadData()
            }
        }
    }
    
    func deleteActivity(_ entry: SelfCareEntry) {
        SelfCareDataStore.shared.delete(entry)
        loadData()
    }
    
    func loadData() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        todayActivities = SelfCareDataStore.shared.loadAll().filter { entry in
            calendar.isDate(entry.timestamp, inSameDayAs: today)
        }.sorted { $0.timestamp > $1.timestamp }
        
        streak = SelfCareDataStore.shared.getStreak()
    }
}

struct ActivityButton: View {
    let name: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                
                Text(name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(color)
            .cornerRadius(16)
            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ActivityCard: View {
    let entry: SelfCareEntry
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.cyanBlue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.activity)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.deepTeal)
                
                Text(formatTime(entry.timestamp))
                    .font(.system(size: 12))
                    .foregroundColor(.softAqua)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(.deepTeal.opacity(0.6))
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.deepTeal.opacity(0.05), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.softAqua.opacity(0.2), lineWidth: 1)
        )
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    SelfCareView()
}
