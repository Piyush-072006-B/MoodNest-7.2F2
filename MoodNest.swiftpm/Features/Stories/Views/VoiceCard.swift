import SwiftUI

struct VoiceCard: View {
    let voice: MentalHealthVoice
    let isBookmarked: Bool
    let onTap: () -> Void
    let onBookmark: () -> Void
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var voiceReader = VoiceReaderManager.shared
    
    private var isPlaying: Bool {
        voiceReader.currentlyPlayingID == voice.id.uuidString
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon and Bookmark
            HStack {
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
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: voice.iconName)
                        .font(.system(size: 26))
                        .foregroundColor(voice.color)
                }
                
                Spacer()
                
                // Bookmark button
                Button(action: {
                    HapticManager.light()
                    onBookmark()
                }) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 18))
                        .foregroundColor(isBookmarked ? voice.color : Color.gray.opacity(0.5))
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Name
            Text(voice.name)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.deepTeal)
                .lineLimit(2)
            
            // Profession
            Text(voice.profession)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.cyanBlue)
                .lineLimit(1)
            
            // Era
            Text(voice.era)
                .font(.system(size: 11))
                .foregroundColor(.softAqua)
            
            // Listen button — always visible
            Button {
                VoiceReaderManager.shared.toggle(
                    text: voice.biography,
                    storyID: voice.id.uuidString
                )
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: isPlaying ? "stop.fill" : "speaker.wave.2.fill")
                        .font(.system(size: 11))
                    Text(isPlaying ? "Stop" : "Listen")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(isPlaying ? .red : .deepTeal)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.softAqua.opacity(0.15))
                .cornerRadius(16)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel(isPlaying ? "Stop reading" : "Listen to story")
            .accessibilityHint(isPlaying ? "Stops reading aloud" : "Reads this story aloud")
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
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
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            voice.color.opacity(0.4),
                            voice.color.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: voice.color.opacity(0.15), radius: 8, x: 0, y: 4)
        .onTapGesture { onTap() }
    }
}

#Preview {
    VStack(spacing: 16) {
        VoiceCard(
            voice: MentalHealthVoice(
                name: "Abraham Lincoln",
                profession: "16th U.S. President",
                era: "1809-1865",
                condition: "Depression",
                quote: "Test quote",
                biography: "Test bio",
                icon: "building.columns.fill",
                colorHex: "#8B7355"
            ),
            isBookmarked: false,
            onTap: {},
            onBookmark: {}
        )
        
        VoiceCard(
            voice: MentalHealthVoice(
                name: "Virginia Woolf",
                profession: "Novelist & Essayist",
                era: "1882-1941",
                condition: "Bipolar Disorder",
                quote: nil,
                biography: "Test bio",
                icon: "book.fill",
                colorHex: "#9B59B6"
            ),
            isBookmarked: true,
            onTap: {},
            onBookmark: {}
        )
    }
    .padding()
    .background(Color.lightSky)
}
