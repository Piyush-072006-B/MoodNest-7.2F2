import SwiftUI

struct GuideDetailView: View {
    let guide: MiniGuide
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @StateObject private var voiceReader = VoiceReaderManager.shared
    
    private var isPlaying: Bool {
        voiceReader.currentlyPlayingID == guide.id
    }
    
    /// Join all section text for speech
    private var fullText: String {
        guide.sections.map { $0.heading + ". " + $0.content }.joined(separator: ". ")
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Hero Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.cyanBlue.opacity(0.3), Color.deepTeal.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: guide.icon)
                            .font(.system(size: 36))
                            .foregroundColor(.cyanBlue)
                    }
                    
                    Text(guide.title)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.deepTeal)
                        .multilineTextAlignment(.center)
                    
                    Text(guide.readTime + " read")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.softAqua)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    
                    // Listen / Auto-Read Button
                    Button {
                        HapticManager.light()
                        VoiceReaderManager.shared.toggle(
                            text: fullText,
                            storyID: guide.id
                        )
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: isPlaying ? "stop.fill" : "speaker.wave.2.fill")
                                .font(.system(size: 14))
                                .scaleEffect(isPlaying && !reduceMotion ? 1.1 : 1.0)
                                .animation(isPlaying && !reduceMotion ? Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default, value: isPlaying)
                            Text(isPlaying ? "Stop Reading" : "Listen to Guide")
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
                                            isPlaying ? Color.red.opacity(0.3) : Color.cyanBlue.opacity(0.3),
                                            lineWidth: 1.5
                                        )
                                )
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .accessibilityLabel(isPlaying ? "Stop reading" : "Listen to guide")
                    .accessibilityHint(isPlaying ? "Stops reading aloud" : "Reads this guide aloud")
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
                .padding(.bottom, 8)
                
                // Sections
                ForEach(Array(guide.sections.enumerated()), id: \.offset) { index, section in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.cyanBlue)
                                .frame(width: 4, height: 20)
                            
                            Text(section.heading)
                                .font(.system(size: 19, weight: .semibold))
                                .foregroundColor(.deepTeal)
                        }
                        
                        Text(section.content)
                            .font(.system(size: 15))
                            .foregroundColor(.deepTeal.opacity(0.85))
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        ZStack {
                            if colorScheme == .dark {
                                Color.black.opacity(0.3)
                            } else {
                                Color.white.opacity(0.75)
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
                                    colors: [Color.white.opacity(0.5), Color.white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.deepTeal.opacity(0.08), radius: 6, x: 0, y: 3)
                    .padding(.horizontal, 4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .background(Color.lightSky)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            VoiceReaderManager.shared.stop()
        }
    }
}

#Preview {
    NavigationView {
        GuideDetailView(guide: MiniGuide(
            id: "test",
            title: "Test Guide",
            icon: "book.pages",
            readTime: "5 min",
            sections: [
                GuideSection(heading: "Introduction", content: "This is a test guide section with some content to display."),
                GuideSection(heading: "Main Content", content: "Here's more detailed information about the topic.")
            ]
        ))
    }
}
