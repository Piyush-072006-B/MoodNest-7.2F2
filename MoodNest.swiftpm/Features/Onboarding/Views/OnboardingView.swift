import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var selectedCards: [OnboardingCard] = []
    var onComplete: () -> Void
    
    // 10 motivational thoughts and mental health concepts
    let allOnboardingContent = [
        OnboardingCard(
            title: "Mindfulness",
            description: "Take a moment to check in with yourself. Your mental health matters.",
            iconName: "brain.head.profile",
            color: .moodSkyBlue
        ),
        OnboardingCard(
            title: "Resilience",
            description: "Track your emotions and build emotional awareness over time.",
            iconName: "shield.fill",
            color: .moodMintGreen
        ),
        OnboardingCard(
            title: "Self-Care",
            description: "Understanding your moods is the first step to better well-being.",
            iconName: "heart.circle.fill",
            color: .moodSageGreen
        ),
        OnboardingCard(
            title: "Gratitude",
            description: "Practicing gratitude can shift your perspective and improve your mood.",
            iconName: "sparkles",
            color: .moodButterYellow
        ),
        OnboardingCard(
            title: "Emotional Intelligence",
            description: "Recognizing and naming your emotions helps you manage them better.",
            iconName: "lightbulb.fill",
            color: .moodLavender
        ),
        OnboardingCard(
            title: "Self-Compassion",
            description: "Be kind to yourself. You deserve the same compassion you give others.",
            iconName: "hand.holding.heart",
            color: .moodPeachyPink
        ),
        OnboardingCard(
            title: "Present Moment",
            description: "The present moment is all we truly have. Stay grounded in the now.",
            iconName: "clock.arrow.circlepath",
            color: .moodSoftCoral
        ),
        OnboardingCard(
            title: "Inner Peace",
            description: "Finding calm within yourself is a powerful tool for mental wellness.",
            iconName: "wind",
            color: .moodSkyBlue
        ),
        OnboardingCard(
            title: "Growth Mindset",
            description: "Every challenge is an opportunity to learn and grow stronger.",
            iconName: "arrow.up.right.circle.fill",
            color: .moodSageGreen
        ),
        OnboardingCard(
            title: "Emotional Balance",
            description: "All emotions are valid. Balance comes from acknowledging them all.",
            iconName: "scale.3d",
            color: .moodLavender
        )
    ]
    
    var body: some View {
        ZStack {
            // Decorative background
            DecorativeBackground()
            
            VStack(spacing: 0) {
                Spacer(minLength: 60)
                
                if !selectedCards.isEmpty {
                    // Card content
                    VStack(spacing: 32) {
                        // Icon with enhanced glassmorphism
                        ZStack {
                            // Outer glow
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            selectedCards[currentPage].color.opacity(0.4),
                                            selectedCards[currentPage].color.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 180, height: 180)
                                .blur(radius: 20)
                            
                            // Glass circle background
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 140, height: 140)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.6),
                                                    Color.white.opacity(0.2)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .shadow(color: selectedCards[currentPage].color.opacity(0.3), radius: 10, x: 0, y: 10)
                            
                            // Icon
                            Image(systemName: selectedCards[currentPage].iconName)
                                .font(.system(size: 70, weight: .medium))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            .deepTeal,
                                            .cyanBlue
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .symbolRenderingMode(.hierarchical)
                        }
                        .scaleEffect(currentPage == 0 ? 1.0 : 1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: currentPage)
                        .transition(.scale.combined(with: .opacity))
                        .id("icon-\(currentPage)")
                        .accessibilityLabel(selectedCards[currentPage].title)
                        .onAppear {
                            // Subtle pulse animation on appear
                            withAnimation(
                                .easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: true)
                            ) {
                                // Animation handled by SwiftUI
                            }
                        }
                        
                        // Title
                        Text(selectedCards[currentPage].title)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.deepTeal, .cyanBlue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .transition(.move(edge: .trailing).combined(with: .opacity))

                        
                        // Description Card with glassmorphism
                        Text(selectedCards[currentPage].description)
                            .font(.system(size: 18, weight: .medium))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.deepTeal.opacity(0.9))
                            .padding(.horizontal, 32)
                            .padding(.vertical, 28)
                            .glassCard(cornerRadius: 20, borderWidth: 1.5)
                            .shadow(color: selectedCards[currentPage].color.opacity(0.2), radius: 10, x: 0, y: 8)
                            .padding(.horizontal, 32)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                            .id("description-\(currentPage)")
                    }
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentPage)
                }
                
                Spacer(minLength: 60)
                
                // Page Indicators
                HStack(spacing: 10) {
                    ForEach(0..<selectedCards.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.moodSkyBlue : Color.gray.opacity(0.3))
                            .frame(width: 10, height: 10)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.bottom, 32)
                
                // Button
                PrimaryButton(
                    title: currentPage < selectedCards.count - 1 ? "Next" : "Get Started",
                    action: handleButtonTap,
                    isEnabled: true
                )
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            // Randomly select 3 non-repeating cards
            selectedCards = allOnboardingContent.shuffled().prefix(3).map { $0 }
        }
    }
    
    func handleButtonTap() {
        if currentPage < selectedCards.count - 1 {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                currentPage += 1
            }
        } else {
            // Mark onboarding complete and dismiss
            OnboardingManager.markOnboardingComplete()
            withAnimation {
                onComplete()
            }
        }
    }
}

struct OnboardingCard: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let iconName: String
    let color: Color
}

#Preview {
    OnboardingView(onComplete: {})
}
