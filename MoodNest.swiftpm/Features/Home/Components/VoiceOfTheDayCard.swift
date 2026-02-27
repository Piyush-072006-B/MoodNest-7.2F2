import SwiftUI

struct VoiceOfTheDayCard: View {
    @StateObject private var voicesManager = VoicesManager.shared
    @State private var showingDetail = false
    @State private var todaysVoice: MentalHealthVoice
    @Environment(\.colorScheme) var colorScheme
    
    init() {
        // Get consistent "voice of the day" based on current date
        let calendar = Calendar.current
        let today = Date()
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: today) ?? 1
        let voices = VoicesManager.shared.historicalVoices
        let index = dayOfYear % voices.count
        _todaysVoice = State(initialValue: voices[index])
    }
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Image(systemName: "quote.bubble.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.moodLavender)
                    
                    Text("Voice of the Day")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.deepTeal)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14))
                        .foregroundColor(.cyanBlue)
                }
                
                // Content
                HStack(spacing: 16) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        todaysVoice.color.opacity(0.3),
                                        todaysVoice.color.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 64, height: 64)
                        
                        Image(systemName: todaysVoice.iconName)
                            .font(.system(size: 28))
                            .foregroundColor(todaysVoice.color)
                    }
                    
                    // Text
                    VStack(alignment: .leading, spacing: 6) {
                        Text(todaysVoice.name)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.deepTeal)
                            .lineLimit(1)
                        
                        Text(todaysVoice.profession)
                            .font(.system(size: 13))
                            .foregroundColor(.cyanBlue)
                            .lineLimit(1)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "heart.text.square")
                                .font(.system(size: 11))
                                .foregroundColor(todaysVoice.color)
                            
                            Text(todaysVoice.mentalHealthCondition)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.softAqua)
                        }
                    }
                    
                    Spacer()
                }
                
                // Quote preview (if available)
                if let quote = todaysVoice.quote {
                    Text("\"\(quote.prefix(100))...\"")

                        .font(.system(size: 13))
                        .foregroundColor(.deepTeal.opacity(0.8))
                        .italic()
                        .lineLimit(2)
                }
            }
            .padding(20)
            .background(
                ZStack {
                    if colorScheme == .dark {
                        Color.black.opacity(0.3)
                    } else {
                        Color.white.opacity(0.7)
                    }
                    
                    Rectangle()
                        .fill(.ultraThinMaterial)
                }
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                todaysVoice.color.opacity(0.4),
                                todaysVoice.color.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: todaysVoice.color.opacity(0.15), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
        .sheet(isPresented: $showingDetail) {
            VoiceDetailView(voice: todaysVoice)
        }
    }
}

#Preview {
    VoiceOfTheDayCard()
        .padding()
        .background(Color.lightSky)
}
