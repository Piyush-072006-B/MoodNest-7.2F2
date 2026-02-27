import SwiftUI

struct ModernAwarenessView: View {
    @State private var expandedTopic: String?
    @Binding var selectedTab: TabItem
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    let topics = [
        Topic(
            title: "Mindfulness Meditation",
            icon: "figure.mind.and.body",
            color: Color.deepTeal,
            category: "Mindfulness",
            content: "Mindfulness meditation is the practice of focusing your attention on the present moment with an attitude of openness and non-judgment. It involves observing thoughts, feelings, and sensations as they arise without trying to change them. Research shows that regular practice can significantly reduce symptoms of anxiety and depression by training the brain to respond less reactively to stress.\n\nTo begin, find a quiet space and sit comfortably. Focus on the sensation of your breath—the rise and fall of your chest or the feeling of air entering your nostrils. When your mind inevitably wanders, gently and kindly bring your attention back to your breath. Over time, this builds 'mental muscle' that helps you stay grounded even in challenging situations.",
            pros: ["Reduces stress", "Improves focus", "Better sleep"],
            cons: ["Requires practice", "Time commitment"]
        ),
        Topic(
            title: "Cognitive Behavioral Therapy",
            icon: "brain.head.profile",
            color: Color.cyanBlue,
            category: "Therapy",
            content: "CBT is a highly effective, evidence-based form of psychological treatment that focuses on the relationship between thoughts, feelings, and behaviors. The core principle is that our interpretations of events—rather than the events themselves—shape our emotional experiences. By identifying and challenging 'cognitive distortions' (unhelpful thought patterns), individuals can learn to respond to life's stressors more effectively.\n\nCBT often involves practical exercises like thought recording, where you document a distressing situation, the automatic thoughts that followed, and rational alternatives. This process helps 'rewire' the brain's baseline responses, leading to long-term improvements in mood and functioning. It is widely considered the gold standard for treating various mental health conditions.",
            pros: ["Evidence-based", "Practical tools", "Long-term benefits"],
            cons: ["Needs professional", "Can be challenging"]
        ),
        Topic(
            title: "Gratitude Practice",
            icon: "heart.text.square.fill",
            color: Color.softAqua,
            category: "Self-Care",
            content: "Gratitude is more than just saying 'thank you.' It is a conscious effort to acknowledge the goodness in your life and recognize that the source of that goodness often lies outside yourself. Scientific studies have demonstrated that consistent gratitude practice can increase levels of dopamine and serotonin, the brain's 'feel-good' neurotransmitters, while reducing the stress hormone cortisol.\n\nA simple way to start is by keeping a daily gratitude journal. Each evening, write down three specific things you are thankful for from that day. They don't have to be major life events; even a warm cup of coffee or a kind word from a stranger counts. By training your brain to scan for the positive, you naturally become more resilient and optimistic.",
            pros: ["Boosts happiness", "Easy to start", "Free"],
            cons: ["Consistency needed", "May feel forced initially"]
        ),
        Topic(
            title: "Sleep Hygiene",
            icon: "moon.stars.fill",
            color: Color.deepTeal.opacity(0.8),
            category: "Wellness",
            content: "Sleep hygiene refers to a variety of practices and habits that are necessary to have good nighttime sleep quality and full daytime alertness. Since sleep and mental health are closely linked, improving your 'hygiene' can have a profound impact on your emotional stability. The body thrives on consistency, so maintaining a regular sleep-wake cycle is one of the most important factors.\n\nKey recommendations include creating a dark, cool, and quiet sleep environment, limiting caffeine and alcohol in the hours leading up to bed, and establishing a 'tech-free' buffer zone before sleep. Exposure to blue light from screens can suppress melatonin production, making it harder to fall asleep. By respecting your body's natural circadian rhythm, you allow your brain to perform critical restorative functions.",
            pros: ["Better rest", "More energy", "Improved mood"],
            cons: ["Lifestyle changes", "Takes time to adjust"]
        ),
        Topic(
            title: "Breathing Exercises",
            icon: "lungs.fill",
            color: Color.cyanBlue.opacity(0.8),
            category: "Mindfulness",
            content: "Controlled breathing is one of the fastest ways to influence your nervous system. When we are stressed, our 'fight or flight' response (sympathetic nervous system) takes over, leading to shallow breaths and a rapid heart rate. By consciously slowing down our breathing, we activate the 'rest and digest' response (parasympathetic nervous system), sending a signal to the brain that we are safe.\n\nA popular technique is 'Box Breathing': inhale for four seconds, hold for four, exhale for four, and hold for four. Another is the '4-7-8' method: inhale for four, hold for seven, and exhale forcefully for eight. These techniques provide an immediate physiological anchor, helping to manage acute anxiety or panic in the moment.",
            pros: ["Instant calm", "No equipment", "Anywhere, anytime"],
            cons: ["Easy to forget", "Requires focus"]
        ),
        Topic(
            title: "Setting Boundaries",
            icon: "shield.fill",
            color: Color.deepTeal.opacity(0.7),
            category: "Relationships",
            content: "Boundaries are essentially the 'rules of engagement' we establish for our relationships and ourselves. They are not about keeping people out, but about clearly communicating what behaviors we find acceptable and what we do not. Healthy boundaries protect our emotional energy and prevent the resentment that often grows from over-extending ourselves or saying 'yes' when we mean 'no.'\n\nBoundaries can be physical, emotional, or digital. For example, setting an emotional boundary might involve telling a friend, 'I care about you, but I don't have the capacity to discuss this heavy topic right now.' Learning to set boundaries requires self-awareness and the courage to prioritize your well-being, but it ultimately leads to more honest and sustainable connections with others.",
            pros: ["Protects energy", "Reduces stress", "Better relationships"],
            cons: ["Can feel uncomfortable", "May upset others"]
        ),
        Topic(
            title: "Emotional Regulation",
            icon: "heart.circle.fill",
            color: Color.cyanBlue.opacity(0.7),
            category: "Self-Care",
            content: "Emotional regulation is the ability to monitor and manage your internal emotional state. It doesn't mean suppressing feelings; rather, it's about being able to feel an emotion and choose how to respond to it effectively. This skill is critical for navigating conflict, making sound decisions, and maintaining a sense of inner balance during life's ups and downs.\n\nOne powerful strategy is the 'STOP' technique: Stop what you're doing, Take a breath, Observe what's happening in your body and mind, and Proceed with awareness. By creating a small space between the emotion and your reaction, you regain control over your behavior. Developing this 'emotional agility' allows you to live more intentionally.",
            pros: ["Manage intense emotions", "Better decision-making", "Improved relationships"],
            cons: ["Takes practice", "Can be difficult at first"]
        ),
        Topic(
            title: "Social Anxiety",
            icon: "person.2.fill",
            color: Color.softAqua.opacity(0.9),
            category: "Anxiety",
            content: "Social anxiety is more than just shyness; it involves an intense fear of being judged, evaluated, or rejected by others in social or performance situations. This can lead to avoiding activities or enduring them with significant distress. Understanding that social anxiety is a common experience and that most people are focused on their own insecurities can help reduce the pressure we put on ourselves.\n\nTreatment often involves 'gradual exposure,' where you slowly face feared situations in a controlled way. Combined with mindfulness and CBT, exposure helps desensitize the fear response. Remember that social skills are like muscles—they get stronger with practice. Focusing on the person you're talking to rather than your own performance can also significantly lower anxiety levels.",
            pros: ["Navigate social situations", "Build confidence", "Reduce avoidance"],
            cons: ["Gradual progress", "May need support"]
        ),
        Topic(
            title: "Mind-Body Connection",
            icon: "figure.yoga",
            color: Color.deepTeal.opacity(0.6),
            category: "Wellness",
            content: "The mind and body are not separate entities; they are part of a continuous feedback loop. What we think and feel has a direct impact on our physical health, and our physical state profoundly influences our mental wellbeing. For instance, chronic stress can manifest as muscle tension, headaches, or digestive issues, while physical movement can release endorphins that alleviate depression.\n\nHolistic practices like Yoga, Tai Chi, or even mindful walking emphasize this connection. By paying attention to bodily sensations while moving, you can release stored emotional tension. Taking care of your physical health through nutrition, hydration, and movement is a fundamental part of maintaining a healthy mind.",
            pros: ["Holistic wellness", "Physical benefits", "Mental clarity"],
            cons: ["Requires commitment", "Not a quick fix"]
        ),
        Topic(
            title: "Burnout Prevention",
            icon: "flame.fill",
            color: Color.cyanBlue.opacity(0.6),
            category: "Burnout",
            content: "Burnout is a state of emotional, physical, and mental exhaustion caused by excessive and prolonged stress. It occurs when you feel overwhelmed, emotionally drained, and unable to meet constant demands. Preventing burnout requires a proactive approach to workload management and regular 'recharging' of your internal battery before it hits zero.\n\nEarly warning signs include chronic fatigue, cynicism towards work, and a sense of reduced accomplishment. Prevention involves setting clear work-life boundaries, taking regular breaks, and engaging in activities that bring you joy outside of your primary responsibilities. Remember that self-care is not a luxury; it is a vital necessity for long-term health and productivity.",
            pros: ["Recognize warning signs", "Protect well-being", "Sustainable energy"],
            cons: ["Lifestyle changes needed", "May require boundaries"]
        ),
        Topic(
            title: "Digital Wellbeing",
            icon: "iphone.slash",
            color: Color.deepTeal.opacity(0.9),
            category: "Wellness",
            content: "In an age of constant connectivity, digital wellbeing is about having a healthy relationship with technology. It involves being intentional about how and when we use our devices to ensure they serve our lives rather than distract from them. High 'screen time' and social media comparison are often linked to increased anxiety and a distorted sense of reality.\n\nStrategies for digital wellbeing include setting 'no-tech' times (like during meals), turning off non-essential notifications, and curating your social media feeds to follow accounts that inspire rather than deflate you. A 'digital detox'—even for just a few hours—can help reset your focus and allow you to reconnect with the physical world around you.",
            pros: ["Healthy tech habits", "Better focus", "Improved sleep"],
            cons: ["FOMO challenges", "Requires discipline"]
        ),
        Topic(
            title: "Affirmations",
            icon: "quote.bubble.fill",
            color: Color.softAqua.opacity(0.8),
            category: "Self-Care",
            content: "Affirmations are positive statements that you repeat to yourself to challenge negative thoughts and build self-esteem. While they may feel simple, the neurological impact is significant; repeating positive phrases can help strengthen the 'reward centers' in the brain and create new, more supportive neural pathways.\n\nEfficient affirmations are usually in the present tense, personal, and positive. Instead of saying 'I will be brave,' try 'I am capable of handling this challenge.' For affirmations to be effective, they should feel realistic to you. Combining them with deep breathing or looking in a mirror can enhance their impact. Over time, these small shifts in self-talk become the foundation of a more resilient self-image.",
            pros: ["Positive self-talk", "Boost confidence", "Easy to practice"],
            cons: ["May feel awkward", "Consistency needed"]
        )
    ]

    
    var body: some View {
        NavigationView {
            ZStack {
                DecorativeBackground(
                    gradient: LinearGradient(
                        colors: [Color.lightSky, Color.softAqua.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            VStack(spacing: 0) {
                // Compact Back Button Header
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
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.lightSky.opacity(0.9))
                
                // Scrollable Content
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Title Section
                        VStack(spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.cyanBlue)
                            
                            Text("Mental Wellness Library")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.deepTeal)
                            
                            Text("Explore topics to support your journey")
                                .font(.system(size: 14))
                                .foregroundColor(.cyanBlue)
                            
                            // Mini-Guides Button
                            NavigationLink(destination: MiniGuidesView()) {
                                HStack {
                                    Image(systemName: "book.pages.fill")
                                        .font(.system(size: 16))
                                    Text("Wellness Guides")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(MoodGradients.button)
                                .cornerRadius(12)
                            }
                            .padding(.top, 8)
                        }
                        .padding(.top, 20)
                        
                        // Topic Flashcards — vertical stack
                        ForEach(topics) { topic in
                            TopicFlashCard(
                                topic: topic,
                                isExpanded: expandedTopic == topic.id,
                                reduceMotion: reduceMotion,
                                onTap: {
                                    HapticManager.light()
                                    withAnimation(reduceMotion ? .none : .spring(response: 0.4, dampingFraction: 0.75)) {
                                        expandedTopic = expandedTopic == topic.id ? nil : topic.id
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
            }
            .onDisappear {
                VoiceReaderManager.shared.stop()
            }
            .navigationBarHidden(true)
        }
    }
}

struct Topic: Identifiable {
    let id = UUID().uuidString
    let title: String
    let icon: String
    let color: Color
    var category: String = ""
    let content: String
    let pros: [String]
    let cons: [String]
}

// MARK: - Flashcard Component

struct TopicFlashCard: View {
    let topic: Topic
    let isExpanded: Bool
    let reduceMotion: Bool
    let onTap: () -> Void
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var voiceReader = VoiceReaderManager.shared
    
    private var isPlaying: Bool {
        voiceReader.currentlyPlayingID == topic.id
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card Header — always visible
            Button(action: onTap) {
                HStack(spacing: 16) {
                    // Icon circle
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [topic.color.opacity(0.3), topic.color.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 52)
                        
                        Image(systemName: topic.icon)
                            .font(.system(size: 24))
                            .foregroundColor(topic.color)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(topic.title)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.deepTeal)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        HStack(spacing: 8) {
                            if !topic.category.isEmpty {
                                Text(topic.category)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(topic.color)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(topic.color.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                            
                            Text("3 min read")
                                .font(.system(size: 11))
                                .foregroundColor(.softAqua)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.deepTeal.opacity(0.5))
                }
                .padding(16)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Listen button — always visible
            HStack {
                Spacer()
                
                Button {
                    HapticManager.light()
                    VoiceReaderManager.shared.toggle(
                        text: topic.content,
                        storyID: topic.id
                    )
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: isPlaying ? "stop.fill" : "speaker.wave.2.fill")
                            .font(.system(size: 12))
                            .scaleEffect(isPlaying && !reduceMotion ? 1.1 : 1.0)
                            .animation(isPlaying && !reduceMotion ? Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default, value: isPlaying)
                        Text(isPlaying ? "Stop" : "Listen")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(isPlaying ? .red : .deepTeal)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Color.softAqua.opacity(0.15))
                    .cornerRadius(16)
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel(isPlaying ? "Stop reading" : "Listen to topic")
                .accessibilityHint(isPlaying ? "Stops reading aloud" : "Reads this topic aloud")
                
                Spacer()
            }
            .padding(.bottom, 4)
            
            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    Divider()
                        .padding(.horizontal, 16)
                    
                    Text(topic.content)
                        .font(.system(size: 14))
                        .foregroundColor(.deepTeal.opacity(0.85))
                        .lineSpacing(5)
                        .padding(.horizontal, 16)
                    
                    // Pros
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 13))
                                .foregroundColor(.green)
                            Text("Benefits")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.deepTeal)
                        }
                        
                        ForEach(topic.pros, id: \.self) { pro in
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.green.opacity(0.5))
                                    .frame(width: 5, height: 5)
                                Text(pro)
                                    .font(.system(size: 13))
                                    .foregroundColor(.deepTeal.opacity(0.8))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Cons
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 13))
                                .foregroundColor(.orange)
                            Text("Considerations")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.deepTeal)
                        }
                        
                        ForEach(topic.cons, id: \.self) { con in
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.orange.opacity(0.5))
                                    .frame(width: 5, height: 5)
                                Text(con)
                                    .font(.system(size: 13))
                                    .foregroundColor(.deepTeal.opacity(0.8))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
            }
        }
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
                        colors: [topic.color.opacity(0.4), topic.color.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: topic.color.opacity(0.12), radius: 8, x: 0, y: 4)
        .scaleEffect(isExpanded ? 1.0 : (reduceMotion ? 1.0 : 1.0))
    }
}

struct ModernAwarenessView_Previews: PreviewProvider {
    static var previews: some View {
        ModernAwarenessView(selectedTab: .constant(.awareness))
    }
}
