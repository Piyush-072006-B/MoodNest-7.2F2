import SwiftUI

// MARK: - Mood Energy Ring (Phase 2 — Home Hero Feature)

struct MoodEnergyRing: View {
    @State private var progress: CGFloat = 0
    @State private var weeklyAverage: Double = 0
    @State private var animatedScore: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.colorScheme) var colorScheme
    
    /// Normalized 0–1 ring fill based on weekly average
    private var ringFill: CGFloat {
        // Map -1…1 → 0…1
        CGFloat((weeklyAverage + 1.0) / 2.0)
    }
    
    private var ringGradient: AngularGradient {
        let colors: [Color]
        if weeklyAverage > 0.2 {
            colors = [.cyanBlue, .softAqua, Color.green.opacity(0.7), .cyanBlue]
        } else if weeklyAverage > -0.2 {
            colors = [Color.yellow.opacity(0.7), Color.orange.opacity(0.5), Color.yellow.opacity(0.7)]
        } else {
            colors = [Color.red.opacity(0.6), Color.orange.opacity(0.5), Color.red.opacity(0.6)]
        }
        return AngularGradient(colors: colors, center: .center, startAngle: .degrees(-90), endAngle: .degrees(270))
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Track ring
                Circle()
                    .stroke(
                        Color.softAqua.opacity(0.15),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 140, height: 140)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        ringGradient,
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))
                
                // Center content
                VStack(spacing: 2) {
                    Text(formattedAverage)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.deepTeal)
                    
                    Text("Mood Energy")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.softAqua)
                }
                .scaleEffect(pulseScale)
            }
            .shadow(color: ringGlowColor.opacity(0.2), radius: 10, x: 0, y: 0)
        }
        .padding(.vertical, 8)
        .onAppear {
            computeWeeklyAverage()
            animateRing()
            if !reduceMotion { startPulse() }
        }
    }

    private var formattedAverage: String {
        if animatedScore > 0 {
            return "+\(String(format: "%.1f", animatedScore))"
        }
        return String(format: "%.1f", animatedScore)
    }

    private var ringGlowColor: Color {
        if weeklyAverage > 0.2 { return .cyanBlue }
        if weeklyAverage > -0.2 { return .yellow }
        return .red
    }

    private func computeWeeklyAverage() {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let entries = EmotionalArchive.shared.loadAll().filter { $0.timestamp >= weekAgo }
        guard !entries.isEmpty else {
            weeklyAverage = 0
            return
        }
        let total = entries.map { moodScore($0.emoji) }.reduce(0, +)
        weeklyAverage = total / Double(entries.count)
        HapticManager.light()
    }

    private func moodScore(_ emoji: String) -> Double {
        switch emoji {
        case "😃": return 1.0
        case "😊", "🙂": return 0.5
        case "😐": return 0.0
        case "🙁", "😔": return -0.5
        case "😢": return -1.0
        default: return 0.0
        }
    }

    private func animateRing() {
        let target = max(0.05, ringFill)
        withAnimation(reduceMotion ? .none : .easeOut(duration: 1.2)) {
            progress = target
            animatedScore = weeklyAverage
        }
    }

    private func startPulse() {
        withAnimation(
            .easeInOut(duration: 2.0)
            .repeatForever(autoreverses: true)
        ) {
            pulseScale = 1.05
        }
    }
}

// MARK: - Long-Press Wrapper (Distinguished: blur, haptic, "Take a breath." overlay)

struct MoodEnergyRingWithLongPress: View {
    @State private var showBreathOverlay = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        ZStack {
            MoodEnergyRing()
                .blur(radius: showBreathOverlay ? 4 : 0)
                .animation(reduceMotion ? .none : .easeInOut(duration: 0.4), value: showBreathOverlay)

            if showBreathOverlay {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                Text("Take a breath.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.deepTeal)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: 0.8) {
            guard !reduceMotion else { return }
            HapticManager.light()
            withAnimation(.easeInOut(duration: 0.3)) {
                showBreathOverlay = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeOut(duration: 0.25)) {
                    showBreathOverlay = false
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.lightSky.ignoresSafeArea()
        MoodEnergyRing()
    }
}
