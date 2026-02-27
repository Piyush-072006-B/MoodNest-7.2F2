import SwiftUI

struct StoriesView: View {
    @Binding var selectedTab: TabItem
    @StateObject private var voicesManager = VoicesManager.shared
    @State private var selectedStory: String? = nil
    @State private var selectedVoice: MentalHealthVoice? = nil
    @State private var showingVoiceDetail = false
    @State private var filterMode: FilterMode = .all
    
    enum FilterMode: String, CaseIterable {
        case all = "All"
        case historical = "Historical"
        case modern = "Modern"
        case bookmarked = "Bookmarked"
    }
    
    let modernStories = [
        Story(
            id: "selena",
            name: "Selena Gomez",
            title: "Breaking the Silence",
            emoji: "💜",
            icon: "heart.text.square.fill",
            color: .moodSoftCoral,
            content: """
            In 2020, Selena Gomez publicly revealed her bipolar disorder diagnosis, becoming one of the most prominent advocates for mental health awareness in the entertainment industry. Her openness about living with bipolar disorder has helped millions of fans feel less alone in their own struggles. Rather than hiding her diagnosis, she chose to use her platform to educate and de-stigmatize mental illness.
            
            Gomez co-founded Wondermind, a mental health media company and platform designed to make mental fitness tools accessible to everyone. The platform offers resources, articles, and expert insights on topics ranging from anxiety and depression to trauma and self-care. Her mission is clear: mental health is not something to be ashamed of, but something to actively nurture and support.
            
            Through her advocacy, Selena emphasizes the importance of seeking help, whether through therapy, medication, or community support. Her message is simple yet powerful: speaking openly about mental health challenges is an act of courage, and everyone deserves access to the resources they need to thrive.
            """,
            takeaway: "Openness and de-stigmatization empower healing and community."
        ),
        Story(
            id: "harry",
            name: "Prince Harry",
            title: "The Power of Vulnerability",
            emoji: "🌱",
            icon: "figure.mind.and.body",
            color: .moodSkyBlue,
            content: """
            Prince Harry's journey with mental health began with unprocessed grief following the death of his mother, Princess Diana. For years, he struggled silently, unable to confront the trauma and pain. It wasn't until his late twenties that he sought therapy, a decision he describes as life-changing. Through therapy, he learned to process his emotions, confront his past, and build emotional resilience.
            
            In recent years, Harry has become a vocal advocate for mental health, co-creating the documentary series "The Me You Can't See" with Oprah Winfrey. The series explores the importance of mental wellness, featuring personal stories from individuals around the world. He also serves as Chief Impact Officer at BetterUp, a coaching and mental health platform dedicated to helping people reach their full potential.
            
            Harry's message centers on the power of vulnerability. He believes that sharing our struggles—rather than hiding them—is essential for healing. By speaking openly about therapy, trauma, and emotional well-being, he encourages others to prioritize their mental health and seek the support they deserve.
            """,
            takeaway: "Vulnerability and therapy are pathways to emotional strength."
        ),
        Story(
            id: "kristen",
            name: "Kristen Bell",
            title: "Living with Balance",
            emoji: "🌸",
            icon: "sparkles",
            color: .moodLavender,
            content: """
            Kristen Bell has been open about her lifelong struggle with depression and anxiety, particularly challenging the misconception that success and happiness eliminate mental health challenges. Despite her thriving career and loving family, Bell continues to manage her mental health through a combination of therapy, medication, and self-care practices.
            
            She speaks candidly about the importance of not suffering in silence. Bell emphasizes that mental health conditions are medical issues, not character flaws, and should be treated with the same seriousness as physical health. Her honesty helps normalize conversations about depression and anxiety, especially for women balancing careers, motherhood, and personal well-being.
            
            Bell's approach to mental wellness is holistic: she prioritizes therapy, maintains open communication with her family, and practices self-compassion. Her message is one of hope and balance—mental health is an ongoing journey, not a destination, and seeking help is a sign of strength, not weakness.
            """,
            takeaway: "Balance, therapy, and self-compassion are key to daily wellness."
        )
    ]
    
    var filteredVoices: [MentalHealthVoice] {
        switch filterMode {
        case .all:
            return voicesManager.historicalVoices
        case .historical:
            return voicesManager.historicalVoices.filter { $0.isHistorical }
        case .modern:
            return voicesManager.historicalVoices.filter { !$0.isHistorical }
        case .bookmarked:
            return voicesManager.bookmarkedVoices
        }
    }
    
    var filteredModernStories: [Story] {
        filterMode == .all || filterMode == .modern ? modernStories : []
    }
    
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
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Image(systemName: "quote.bubble.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.moodLavender)
                        
                        Text("Voices")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.deepTeal)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(Color.lightSky)
                
                // Filter Tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(FilterMode.allCases, id: \.self) { mode in
                            FilterTab(
                                title: mode.rawValue,
                                isSelected: filterMode == mode,
                                action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        filterMode = mode
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 16)
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Historical Voices Grid
                        if !filteredVoices.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Historical Figures")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.deepTeal)
                                    .padding(.horizontal, 20)
                                
                                LazyVGrid(
                                    columns: [
                                        GridItem(.flexible(), spacing: 16),
                                        GridItem(.flexible(), spacing: 16)
                                    ],
                                    spacing: 16
                                ) {
                                    ForEach(filteredVoices) { voice in
                                        VoiceCard(
                                            voice: voice,
                                            isBookmarked: voicesManager.isBookmarked(voice.id),
                                            onTap: {
                                                selectedVoice = voice
                                                showingVoiceDetail = true
                                            },
                                            onBookmark: {
                                                voicesManager.toggleBookmark(voice.id)
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // Modern Stories
                        if !filteredModernStories.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Modern Voices")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.deepTeal)
                                    .padding(.horizontal, 20)
                                
                                VStack(spacing: 16) {
                                    ForEach(filteredModernStories) { story in
                                        StoryCard(
                                            story: story,
                                            isExpanded: selectedStory == story.id,
                                            onTap: {
                                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                    selectedStory = selectedStory == story.id ? nil : story.id
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        // Empty state
                        if filteredVoices.isEmpty && filteredModernStories.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "bookmark.slash")
                                    .font(.system(size: 48))
                                    .foregroundColor(.softAqua)
                                
                                Text("No bookmarked voices yet")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.deepTeal)
                                
                                Text("Tap the bookmark icon on any story to save it")
                                    .font(.system(size: 14))
                                    .foregroundColor(.cyanBlue)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 60)
                            .padding(.horizontal, 40)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .onDisappear {
            VoiceReaderManager.shared.stop()
        }
        .sheet(isPresented: $showingVoiceDetail) {
            if let voice = selectedVoice {
                VoiceDetailView(voice: voice)
            }
        }
    }
}

struct FilterTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? .white : .deepTeal)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.moodLavender : Color.white.opacity(0.5))
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct Story: Identifiable {
    let id: String
    let name: String
    let title: String
    let emoji: String
    let icon: String
    let color: Color
    let content: String
    let takeaway: String
}

struct StoryCard: View {
    let story: Story
    let isExpanded: Bool
    let onTap: () -> Void
    @StateObject private var voiceReader = VoiceReaderManager.shared
    
    private var isPlaying: Bool {
        voiceReader.currentlyPlayingID == story.id
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Button(action: onTap) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(story.color.opacity(0.2))
                            .frame(width: 56, height: 56)
                        
                        Text(story.emoji)
                            .font(.system(size: 28))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(story.name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.deepTeal)
                        
                        Text(story.title)
                            .font(.system(size: 14))
                            .foregroundColor(.cyanBlue)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.deepTeal)
                }
                .padding(16)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Listen button — ALWAYS visible
            HStack {
                Spacer()
                
                Button {
                    VoiceReaderManager.shared.toggle(
                        text: story.content,
                        storyID: story.id
                    )
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: isPlaying ? "stop.fill" : "speaker.wave.2.fill")
                        Text(isPlaying ? "Stop" : "Listen")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(isPlaying ? .red : .deepTeal)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.softAqua.opacity(0.15))
                    .cornerRadius(20)
                }
                .buttonStyle(ScaleButtonStyle())
                .accessibilityLabel(isPlaying ? "Stop reading" : "Listen to story")
                .accessibilityHint(isPlaying ? "Stops reading aloud" : "Reads this story aloud")
                
                Spacer()
            }
            .padding(.top, 0)
            .padding(.bottom, 4)
            
            // Expanded Content
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    Text(story.content)
                        .font(.system(size: 15))
                        .foregroundColor(.deepTeal.opacity(0.8))
                        .lineSpacing(6)
                        .padding(.horizontal, 16)
                    
                    // Key Takeaway
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 14))
                                .foregroundColor(story.color)
                            Text("Key Takeaway")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.deepTeal)
                        }
                        
                        Text(story.takeaway)
                            .font(.system(size: 14))
                            .foregroundColor(.cyanBlue)
                            .italic()
                    }
                    .padding(12)
                    .background(story.color.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.white.opacity(0.7))
        .cornerRadius(20)
        .shadow(color: Color.deepTeal.opacity(0.08), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(story.color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    StoriesView(selectedTab: .constant(.stories))
}
