import SwiftUI

struct MiniGuide: Identifiable, Codable {
    let id: String
    let title: String
    let icon: String
    let readTime: String
    let sections: [GuideSection]
}

struct GuideSection: Codable {
    let heading: String
    let content: String
}

struct GuideCollection: Codable {
    let guides: [MiniGuide]
}

struct MiniGuidesView: View {
    @State private var guides: [MiniGuide] = []
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    // Cycle through awareness-themed colors
    private let cardColors: [Color] = [
        .deepTeal, .cyanBlue, .softAqua,
        .deepTeal.opacity(0.8), .cyanBlue.opacity(0.8),
        .softAqua.opacity(0.9), .deepTeal.opacity(0.7)
    ]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if guides.isEmpty {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Loading guides…")
                            .font(.system(size: 14))
                            .foregroundColor(.cyanBlue)
                    }
                    .padding(40)
                } else {
                    ForEach(Array(guides.enumerated()), id: \.element.id) { index, guide in
                        NavigationLink(destination: GuideDetailView(guide: guide)) {
                            GuideFlashCard(
                                guide: guide,
                                accentColor: cardColors[index % cardColors.count]
                            )
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
        .background(Color.lightSky)
        .navigationTitle("Wellness Guides")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadGuides()
        }
        .onDisappear {
            VoiceReaderManager.shared.stop()
        }
    }
    
    private func loadGuides() {
        guard let url = Bundle.main.url(forResource: "MiniGuides", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(GuideCollection.self, from: data) else {
            return
        }
        guides = decoded.guides
    }
}

// MARK: - Guide Flashcard

struct GuideFlashCard: View {
    let guide: MiniGuide
    var accentColor: Color = .deepTeal
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @StateObject private var voiceReader = VoiceReaderManager.shared
    
    private var isPlaying: Bool {
        voiceReader.currentlyPlayingID == guide.id
    }
    
    /// Build a preview string from the first section content
    private var previewText: String {
        guard let first = guide.sections.first else { return "" }
        let text = first.content
        if text.count > 100 {
            return String(text.prefix(100)) + "…"
        }
        return text
    }
    
    /// Join all section text for speech
    private var fullText: String {
        guide.sections.map { $0.heading + ". " + $0.content }.joined(separator: ". ")
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [accentColor.opacity(0.3), accentColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                
                Image(systemName: guide.icon)
                    .font(.system(size: 24))
                    .foregroundColor(accentColor)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(guide.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.deepTeal)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(previewText)
                    .font(.system(size: 12))
                    .foregroundColor(.deepTeal.opacity(0.6))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 8) {
                    // Listen button
                    Button {
                        HapticManager.light()
                        VoiceReaderManager.shared.toggle(
                            text: fullText,
                            storyID: guide.id
                        )
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: isPlaying ? "stop.fill" : "speaker.wave.2.fill")
                                .font(.system(size: 10))
                                .scaleEffect(isPlaying && !reduceMotion ? 1.1 : 1.0)
                                .animation(isPlaying && !reduceMotion ? Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default, value: isPlaying)
                            Text(isPlaying ? "Stop" : "Listen")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(isPlaying ? .red : .deepTeal)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.softAqua.opacity(0.15))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel(isPlaying ? "Stop reading" : "Listen to guide")
                    
                    Text(guide.readTime + " read")
                        .font(.system(size: 11))
                        .foregroundColor(.softAqua)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("Read More")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(accentColor)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(accentColor)
                    }
                }
            }
        }
        .padding(16)
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
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [accentColor.opacity(0.4), accentColor.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: accentColor.opacity(0.12), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Guide Card (legacy compat)

struct GuideCard: View {
    let guide: MiniGuide
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GuideFlashCard(guide: guide)
    }
}

#Preview {
    MiniGuidesView()
}
