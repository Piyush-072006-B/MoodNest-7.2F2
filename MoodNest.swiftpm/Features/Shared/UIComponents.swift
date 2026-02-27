import SwiftUI

// MARK: - ScaleButtonStyle

// Shared button style with spring bounce + shadow deepen on press
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .shadow(
                color: Color.black.opacity(configuration.isPressed ? 0.18 : 0.06),
                radius: configuration.isPressed ? 4 : 8,
                x: 0, y: configuration.isPressed ? 1 : 3
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.55), value: configuration.isPressed)
    }
}

// MARK: - PrimaryButton

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    isEnabled ? 
                    MoodGradients.button : 
                    LinearGradient(colors: [Color.softAqua.opacity(0.3)], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(12)
                .shadow(color: Color.shadowColor.opacity(isEnabled ? 1.0 : 0.5), radius: isEnabled ? 14 : 8, x: 0, y: isEnabled ? 6 : 4)
        }
        .disabled(!isEnabled)
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel(title)
    }
}

#Preview {
    ZStack {
        Color.lightSky
        
        VStack(spacing: 20) {
            PrimaryButton(title: "Save Mood", action: {})
            PrimaryButton(title: "Disabled", action: {}, isEnabled: false)
        }
        .padding()
    }
}

// MARK: - EmptyStateView

// Empty state component with friendly illustrations (Teal/Aqua theme)
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    @State private var isAnimating = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(.softAqua.opacity(0.7))
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(
                    reduceMotion ? .none : .easeInOut(duration: 2).repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.deepTeal)
                
                Text(message)
                    .font(.system(size: 15))
                    .foregroundColor(.cyanBlue)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.cyanBlue, .deepTeal],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(40)
        .onAppear {
            if !reduceMotion {
                isAnimating = true
            }
        }
    }
}

#Preview {
    ZStack {
        Color.lightSky
        
        VStack(spacing: 40) {
            EmptyStateView(
                icon: "book.closed.fill",
                title: "Start journaling today",
                message: "Capture your thoughts and reflect on your day"
            )
            
            EmptyStateView(
                icon: "sparkles",
                title: "No gratitude entries yet",
                message: "Begin your gratitude practice and watch positivity grow",
                actionTitle: "Add First Entry",
                action: {}
            )
        }
    }
}

// MARK: - AchievementOverlayView

//struct AchievementOverlayView: View {
//    var achievementTitle: String
//    var onDismiss: () -> Void
//
//    @State private var isVisible = false
//
//    var body: some View {
//        ZStack {
//            Color.black.opacity(isVisible ? 0.4 : 0)
//                .ignoresSafeArea()
//
//            VStack(spacing: 16) {
//                Image(systemName: "star.fill")
//                    .font(.system(size: 50))
//                    .foregroundColor(.yellow)
//
//                Text("Achievement Unlocked")
//                    .font(.headline)
//
//                Text(achievementTitle)
//                    .font(.subheadline)
//            }
//            .padding()
//            .background(.ultraThinMaterial)
//            .cornerRadius(20)
//            .scaleEffect(isVisible ? 1 : 0.8)
//            .opacity(isVisible ? 1 : 0)
//        }
//        .onAppear {
//            withAnimation(.spring()) {
//                isVisible = true
//            }
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
//                withAnimation {
//                    isVisible = false
//                }
//                onDismiss()
//            }
//        }
//    }
//}

// MARK: - QuickActionCard

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isTapped = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            if !reduceMotion {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isTapped = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isTapped = false
                    }
                }
            }
            
            action()
        }) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(.deepTeal)
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.deepTeal)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 120, height: 120)
            .thickBorderCard(
                backgroundColor: color.opacity(0.3),
                cornerRadius: 20
            )
            .scaleEffect(isTapped ? 0.95 : 1.0)
            .rotation3DEffect(
                .degrees(isTapped ? 5 : 0),
                axis: (x: 1, y: 1, z: 0)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ZStack {
        Color.lightSky
        
        HStack(spacing: 12) {
            QuickActionCard(
                title: "Daily Check-in",
                icon: "heart.fill",
                color: .softAqua,
                action: {}
            )
            
            QuickActionCard(
                title: "Self-Care",
                icon: "sparkles",
                color: .cyanBlue,
                action: {}
            )
        }
        .padding()
    }
}

// MARK: - ArticleCard

struct ArticleCard: View {
    let title: String
    let illustration: String // SF Symbol name
    let color: Color
    let action: () -> Void
    
    @State private var isTapped = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            if !reduceMotion {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isTapped = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isTapped = false
                    }
                }
            }
            
            action()
        }) {
            HStack(spacing: 16) {
                // Illustration side
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: illustration)
                        .font(.system(size: 28))
                        .foregroundColor(.deepTeal)
                }
                
                // Text side
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.deepTeal)
                        .lineLimit(2)
                    
                    Text("2 min read")
                        .font(.system(size: 12))
                        .foregroundColor(.cyanBlue)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.deepTeal)
            }
            .padding(16)
            .frame(height: 100)
            .thickBorderCard(
                backgroundColor: color.opacity(0.3),
                cornerRadius: 16
            )
            .scaleEffect(isTapped ? 0.98 : 1.0)
            .rotation3DEffect(
                .degrees(isTapped ? 3 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ZStack {
        Color.lightSky
        
        VStack(spacing: 12) {
            ArticleCard(
                title: "Why happiness?",
                illustration: "balloon.fill",
                color: .softAqua,
                action: {}
            )
            
            ArticleCard(
                title: "Mindful breathing",
                illustration: "lungs.fill",
                color: .cyanBlue,
                action: {}
            )
        }
        .padding()
    }
}

// MARK: - MoodInputMode

// Prepared for the Phase 3 custom mood slider
enum MoodInputMode: String, CaseIterable {
    case emoji = "Emoji"
    case slider = "Slider"
}

// MARK: - MoodSelectionView

// Delegates to MoodEmojiSelector; slider mode is wired up for Phase 3
struct MoodSelectionView: View {
    @Binding var selectedMood: String?
    var reduceMotion: Bool = false

    @State private var inputMode: MoodInputMode = .emoji

    var body: some View {
        VStack(spacing: 16) {
            // Mode picker — hidden for now to avoid visible UI regression.
            // Uncomment in Phase 3 full implementation:
            // Picker("Input Mode", selection: $inputMode) {
            //     ForEach(MoodInputMode.allCases, id: \.self) { mode in
            //         Text(mode.rawValue).tag(mode)
            //     }
            // }
            // .pickerStyle(SegmentedPickerStyle())
            // .padding(.horizontal, 20)

            switch inputMode {
            case .emoji:
                MoodEmojiSelector(selectedMood: $selectedMood, reduceMotion: reduceMotion)

            case .slider:
                // Phase 3 placeholder — slider implementation pending
                VStack(spacing: 8) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 32))
                        .foregroundColor(.softAqua)
                    Text("Mood slider coming soon")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.cyanBlue)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            }
        }
    }
}

// MARK: - MoodEmojiSelector

struct MoodEmojiSelector: View {
    @Binding var selectedMood: String?
    var reduceMotion: Bool = false
    
    // Using the new teal/aqua palette
    let moods = [
        ("😃", "Great", Color.cyanBlue),
        ("🙂", "Good", Color.softAqua),
        ("😐", "Okay", Color.softAqua.opacity(0.6)),
        ("🙁", "Sad", Color.deepTeal),
        ("😢", "Down", Color.deepTeal.opacity(0.8))
    ]
    
    var body: some View {
        HStack(spacing: 16) {
            ForEach(moods, id: \.0) { emoji, label, color in
                VStack(spacing: 8) {
                    Text(emoji)
                        .font(.system(size: 60))
                        .frame(width: 80, height: 80)
                        .background(
                            Circle()
                                .fill(color.opacity(0.2)) // Softer background
                                .overlay(
                                    Circle()
                                        .strokeBorder(color, lineWidth: selectedMood == emoji ? 4 : 2)
                                )
                                .shadow(
                                    color: selectedMood == emoji ? color.opacity(0.4) : .clear,
                                    radius: selectedMood == emoji ? 8 : 0
                                )
                        )
                        .scaleEffect(selectedMood == emoji ? 1.1 : 1.0)
                        .animation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.7), value: selectedMood)
                    
                    Text(label)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.deepTeal) // Unified text color
                }
                .onTapGesture {
                    withAnimation {
                        selectedMood = emoji
                    }
                    HapticManager.light()
                }
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedMood: String? = "🙂"
        
        var body: some View {
            VStack {
                MoodEmojiSelector(selectedMood: $selectedMood)
                
                Text(selectedMood ?? "None")
                    .padding()
            }
        }
    }
    
    return PreviewWrapper()
}
