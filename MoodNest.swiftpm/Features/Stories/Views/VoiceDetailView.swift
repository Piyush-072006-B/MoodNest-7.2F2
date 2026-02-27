import SwiftUI

struct VoiceDetailView: View {
    let voice: MentalHealthVoice
    @StateObject private var voicesManager = VoicesManager.shared
    @StateObject private var voiceReader = VoiceReaderManager.shared
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var isBookmarked: Bool {
        voicesManager.isBookmarked(voice.id)
    }
    
    private var isPlaying: Bool {
        voiceReader.currentlyPlayingID == voice.id.uuidString
    }
    
    var body: some View {
        ZStack {
            // Background
            DecorativeBackground(
                gradient: LinearGradient(
                    colors: [
                        voice.color.opacity(0.1),
                        Color.lightSky.opacity(0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            VStack(spacing: 0) {
                // Header with close and bookmark
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.deepTeal.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        HapticManager.light()
                        voicesManager.toggleBookmark(voice.id)
                    }) {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 24))
                            .foregroundColor(isBookmarked ? voice.color : .deepTeal.opacity(0.7))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 12)
                
                // Scrollable content
                ScrollView {
                    VStack(spacing: 24) {
                        // Icon and Name
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                voice.color.opacity(0.3),
                                                voice.color.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: voice.iconName)
                                    .font(.system(size: 44))
                                    .foregroundColor(voice.color)
                            }
                            
                            VStack(spacing: 8) {
                                Text(voice.name)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.deepTeal)
                                    .multilineTextAlignment(.center)
                                
                                Text(voice.profession)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.cyanBlue)
                                    .multilineTextAlignment(.center)
                                
                                Text(voice.era)
                                    .font(.system(size: 14))
                                    .foregroundColor(.softAqua)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Mental Health Condition Badge
                        HStack(spacing: 8) {
                            Image(systemName: "heart.text.square.fill")
                                .font(.system(size: 16))
                                .foregroundColor(voice.color)
                            
                            Text(voice.mentalHealthCondition)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.deepTeal)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(voice.color.opacity(0.3), lineWidth: 1.5)
                                )
                        )
                        
                        // Listen / Auto-Read Button
                        Button {
                            VoiceReaderManager.shared.toggle(
                                text: voice.biography,
                                storyID: voice.id.uuidString
                            )
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: isPlaying ? "stop.fill" : "speaker.wave.2.fill")
                                    .font(.system(size: 14))
                                Text(isPlaying ? "Stop Reading" : "Listen to Story")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(isPlaying ? .red : .deepTeal)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                isPlaying ? Color.red.opacity(0.3) : voice.color.opacity(0.3),
                                                lineWidth: 1.5
                                            )
                                    )
                            )
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .accessibilityLabel(isPlaying ? "Stop reading" : "Listen to story")
                        .accessibilityHint(isPlaying ? "Stops reading aloud" : "Reads this story aloud")
                        
                        // Quote (if available)
                        if let quote = voice.quote {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "quote.opening")
                                        .font(.system(size: 20))
                                        .foregroundColor(voice.color)
                                    
                                    Text("Notable Quote")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.deepTeal)
                                }
                                
                                Text(quote)
                                    .font(.system(size: 15))
                                    .foregroundColor(.deepTeal.opacity(0.9))
                                    .italic()
                                    .lineSpacing(4)
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(voice.color.opacity(0.1))
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        // Biography
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "text.alignleft")
                                    .font(.system(size: 18))
                                    .foregroundColor(voice.color)
                                
                                Text("Their Journey")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.deepTeal)
                            }
                            
                            Text(voice.biography)
                                .font(.system(size: 15))
                                .foregroundColor(.deepTeal.opacity(0.85))
                                .lineSpacing(6)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .glassCard(cornerRadius: 16, borderWidth: 1)
                        .shadow(color: voice.color.opacity(0.1), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 20)
                        
                        // Inspirational message
                        VStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 20))
                                .foregroundColor(voice.color)
                            
                            Text("Resilience and greatness can coexist with mental health struggles.")
                                .font(.system(size: 13))
                                .foregroundColor(.cyanBlue)
                                .multilineTextAlignment(.center)
                                .italic()
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .onDisappear {
            VoiceReaderManager.shared.stop()
        }
    }
}

#Preview {
    VoiceDetailView(
        voice: MentalHealthVoice(
            name: "Abraham Lincoln",
            profession: "16th U.S. President",
            era: "1809-1865",
            condition: "Depression",
            quote: "I am now the most miserable man living. If what I feel were equally distributed to the whole human family, there would not be one cheerful face on the earth.",
            biography: "Abraham Lincoln struggled with severe depression throughout his life, experiencing what he called 'melancholy.' His bouts of depression were so intense that friends once removed razors from his room, fearing for his safety. Despite these struggles, Lincoln led the nation through its darkest hour—the Civil War—and abolished slavery.",
            icon: "building.columns.fill",
            colorHex: "#8B7355"
        )
    )
}
