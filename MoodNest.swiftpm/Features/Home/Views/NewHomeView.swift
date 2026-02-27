import SwiftUI

struct AchievementOverlayView: View {
    var achievementTitle: String
    var onDismiss: () -> Void

    @State private var isVisible = false

    var body: some View {
        ZStack {
            Color.black.opacity(isVisible ? 0.4 : 0)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "star.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.yellow)

                Text("Achievement Unlocked")
                    .font(.headline)

                Text(achievementTitle)
                    .font(.subheadline)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .scaleEffect(isVisible ? 1 : 0.8)
            .opacity(isVisible ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring()) {
                isVisible = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    isVisible = false
                }
                onDismiss()
            }
        }
    }
}


struct NewHomeView: View {
    @State private var selectedTab: TabItem = .home
    @State private var showCheckIn = false
    @State private var showSelfCare = false
    @State private var showGratitude = false
    @State private var showJournal = false
    @StateObject private var achievementManager = AchievementManager.shared
    @State private var showAchievementOverlay = false
    @State private var pendingAchievement: Achievement? = nil
    @State private var hasAppeared = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        ZStack {
            // Main content based on selected tab
            Group {
                switch selectedTab {
                case .home:
                    homeContent
                case .awareness:
                    ModernAwarenessView(selectedTab: $selectedTab)
                case .focus:
                    FocusView(selectedTab: $selectedTab)
                case .calendar:
                    ModernCalendarView(selectedTab: $selectedTab)
                case .stories:
                    StoriesView(selectedTab: $selectedTab)
                case .profile:
                    ProfileView()
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            CustomTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 20)
                .padding(.bottom, 4)
                .background(.clear)
        }
        .sheet(isPresented: $showCheckIn) {
            ModernCheckInView(selectedTab: $selectedTab)
        }
        .sheet(isPresented: $showSelfCare) {
            SelfCareView()
        }
        .sheet(isPresented: $showGratitude) {
            GratitudeView()
        }
        .sheet(isPresented: $showJournal) {
            JournalView()
        }
        .onChange(of: achievementManager.newlyUnlocked, perform: { newValue in
            if let achievement = newValue {
                pendingAchievement = achievement
                showAchievementOverlay = true
            }
        })
        .overlay(
            Group {
                if showAchievementOverlay, let achievement = pendingAchievement {
                    AchievementOverlayView(
                        achievementTitle: achievement.title,
                        onDismiss: {
                            showAchievementOverlay = false
                            pendingAchievement = nil
                            achievementManager.clearNewlyUnlocked()
                        }
                    )
                }
            }
        )
    }
    
    private var adaptiveGradient: LinearGradient {
        let avg = GreetingManager.weeklyAverageScore()
        let colors: [Color] = avg > 0.2
            ? [Color.lightSky, Color.softAqua.opacity(0.25)]
            : avg < -0.2
                ? [Color.lightSky.opacity(0.85), Color.softAqua.opacity(0.08)]
                : [Color.lightSky, Color.softAqua.opacity(0.15)]
        return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
    }
    
     var homeContent: some View {
        ZStack {
            // Root background — must ignore safe area to prevent white gap on scroll bounce
            adaptiveGradient
                .ignoresSafeArea()

            // Solid teal fill behind the header — matches the header's top color exactly
            VStack(spacing: 0) {
                Color(hex: "#064E6E")
                    .frame(height: 200)
                LinearGradient(
                    colors: [Color(hex: "#064E6E"), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 60)
                Spacer()
            }
            .ignoresSafeArea()

            DecorativeBackground(gradient: adaptiveGradient)
            
            ScrollView {
                VStack(spacing: 24) {
                    // 1. Premium hero header
                    PremiumHomeHeader()
                    
                    SmartMoodBanner()
                    
                    // 2. Mood Energy Ring (hero)
                    MoodEnergyRingWithLongPress()
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                    
                    LiveInsightCard()
                    
                    DailyFlowCard()
                    
                    // Insight of the Week
                    InsightOfTheWeekCard()
                    
                    // 4. Quick Actions
                    QuickActionsGrid(
                        showCheckIn: $showCheckIn,
                        showSelfCare: $showSelfCare,
                        showGratitude: $showGratitude,
                        showJournal: $showJournal
                    )
                    
                    // Collapsible below: Motivational, Quote, Mini Insights, Behavioral insight, Voice, Your Week, Explore
                    MotivationalBanner()
                    DailyQuoteCard()
                    MiniInsightsCard()
                    MiniBehavioralInsightCard()
                    VoiceOfTheDayCard()
                        .padding(.horizontal, 16)
                    YourWeekCard()
                    ExploreSection(selectedTab: $selectedTab)
                }
               
                .opacity(hasAppeared || reduceMotion ? 1 : 0)
                .offset(y: hasAppeared || reduceMotion ? 0 : 20)
            }
            .background(ScrollBounceKiller())
            .noScrollBounce()
            .onAppear {
                guard !hasAppeared else { return }
                withAnimation(reduceMotion ? .none : .spring(response: 0.6, dampingFraction: 0.8)) {
                    hasAppeared = true
                }
            }

            // Top safe-area cover — sits ON TOP of everything to hide white gap
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#064E6E"), Color.deepTeal, Color.cyanBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 62)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea(edges: .top)
        }
    }
}

/// Finds the parent UIScrollView and disables bounce so content can't over-scroll upward.
private struct ScrollBounceKiller: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        DispatchQueue.main.async {
            if let scrollView = view.findEnclosingScrollView() {
                scrollView.bounces = false
                scrollView.alwaysBounceVertical = false
                scrollView.alwaysBounceHorizontal = false
            }
        }
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

private extension UIView {
    func findEnclosingScrollView() -> UIScrollView? {
        var current: UIView? = superview
        while let view = current {
            if let sv = view as? UIScrollView { return sv }
            current = view.superview
        }
        return nil
    }
}

struct HeroHeader: View {
    @AppStorage("moodnest_userName") private var userName: String = ""

    private var headerGradient: LinearGradient {
        // Use app-wide header gradient so colors automatically follow the current theme.
        MoodGradients.header
    }

    var body: some View {
        ZStack {
            // Gradient background with rounded bottom corners
            BottomRoundedRectangle(radius: 24)
                .fill(headerGradient)

            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(GreetingManager.greeting(name: userName.isEmpty ? nil : userName))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Text(GreetingManager.subtitle())
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 60, height: 60)

                    Image(systemName: "leaf.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.white.opacity(0.95))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .frame(maxWidth: .infinity, minHeight: 150, maxHeight: 160, alignment: .bottom)
    }
}

/// Simple shape that rounds only the bottom corners by the given radius.
struct BottomRoundedRectangle: Shape {
    var radius: CGFloat = 24

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let topLeft = CGPoint(x: rect.minX, y: rect.minY)
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)

        path.move(to: topLeft)
        path.addLine(to: topRight)

        // Bottom right corner
        path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y - radius))
        path.addQuadCurve(
            to: CGPoint(x: bottomRight.x - radius, y: bottomRight.y),
            control: bottomRight
        )

        // Bottom left corner
        path.addLine(to: CGPoint(x: bottomLeft.x + radius, y: bottomLeft.y))
        path.addQuadCurve(
            to: CGPoint(x: bottomLeft.x, y: bottomLeft.y - radius),
            control: bottomLeft
        )

        path.addLine(to: topLeft)
        path.closeSubpath()

        return path
    }
}

// MARK: - Premium Home Header

struct PremiumHomeHeader: View {
    @AppStorage("moodnest_userName") private var userName: String = ""
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    @State private var appeared = false
    @State private var shimmerOffset: CGFloat = -200
    @State private var glowPhase: CGFloat = 0
    @State private var bubbleFloat: Bool = false

    private var todayFormatted: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: Date())
    }

    private var timeIcon: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<6: return "moon.stars.fill"
        case 6..<12: return "sun.and.horizon.fill"
        case 12..<17: return "sun.max.fill"
        case 17..<21: return "sunset.fill"
        default: return "moon.stars.fill"
        }
    }

    var body: some View {
        ZStack {
            // Layer 1 — Deep aurora gradient
            HeaderWaveShape(waveHeight: 14)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color(hex: "#064E6E"), location: 0.0),
                            .init(color: Color.deepTeal, location: 0.25),
                            .init(color: Color.cyanBlue, location: 0.55),
                            .init(color: Color(hex: "#5EC4C4"), location: 0.8),
                            .init(color: Color.softAqua.opacity(0.7), location: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Layer 2 — Subtle noise texture via overlapping radial blobs
            HeaderWaveShape(waveHeight: 14)
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.06), Color.clear],
                        center: .topTrailing,
                        startRadius: 20,
                        endRadius: 200
                    )
                )

            // Layer 3 — Floating decorative bubbles
            floatingBubbles

            // Layer 4 — Animated shimmer streak
            if !reduceMotion {
                shimmerStreak
            }

            // Layer 5 — Content
            VStack(spacing: 0) {
                // Top row: date badge + time icon
                HStack(spacing: 8) {
                    // Time-of-day icon
                    Image(systemName: timeIcon)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))

                    Spacer()

                    Text(todayFormatted)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .tracking(0.5)
                        .textCase(.uppercase)
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.12))
                                .overlay(
                                    Capsule()
                                        .strokeBorder(Color.white.opacity(0.15), lineWidth: 0.5)
                                )
                        )
                }
                .padding(.top, 0)
                .padding(.horizontal, 22)

                Spacer(minLength: 6)

                // Main greeting row
                HStack(alignment: .bottom, spacing: 14) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(GreetingManager.greeting(name: userName.isEmpty ? nil : userName))
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                            .minimumScaleFactor(0.8)

                        Text(GreetingManager.subtitle())
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                    }

                    Spacer()

                    // Glowing icon badge
                    iconBadge
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 22)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 150, maxHeight: 185)
        .shadow(color: Color.deepTeal.opacity(0.35), radius: 12, x: 0, y: 8)
        .opacity(appeared || reduceMotion ? 1 : 0)
        .offset(y: appeared || reduceMotion ? 0 : -12)
        .onAppear {
            guard !appeared else { return }
            if reduceMotion {
                appeared = true
            } else {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.7)) {
                    appeared = true
                }
                // Shimmer sweep
                withAnimation(.easeInOut(duration: 1.8).delay(0.3)) {
                    shimmerOffset = 400
                }
                // Glow pulse
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 1.2)) {
                        glowPhase = 1
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            glowPhase = 0
                        }
                    }
                }
                // Bubble drift
                withAnimation(.easeInOut(duration: 2.0).delay(0.2)) {
                    bubbleFloat = true
                }
            }
        }
    }

    // MARK: - Glowing Icon Badge

    private var iconBadge: some View {
        ZStack {
            // Soft glow halo
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.softAqua.opacity(glowPhase * 0.3),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 45
                    )
                )
                .frame(width: 90, height: 90)

            // Outer ring
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.35 + glowPhase * 0.15),
                            Color.softAqua.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .frame(width: 66, height: 66)
                .scaleEffect(1.0 + glowPhase * 0.08)

            // Inner circle — glass
            Circle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.22),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    Circle()
                        .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                )
                .frame(width: 54, height: 54)

            // Leaf icon
            Image(systemName: "leaf.fill")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .white.opacity(0.4), radius: 6, x: 0, y: 0)
        }
    }

    // MARK: - Floating Bubbles

    private var floatingBubbles: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            // Bubble 1 — large, left area
            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 70, height: 70)
                .blur(radius: 1)
                .offset(
                    x: w * 0.08,
                    y: h * 0.15 + (bubbleFloat ? -8 : 0)
                )

            // Bubble 2 — medium, center-right
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 45, height: 45)
                .blur(radius: 0.5)
                .offset(
                    x: w * 0.55,
                    y: h * 0.05 + (bubbleFloat ? -5 : 3)
                )

            // Bubble 3 — small accent
            Circle()
                .fill(Color.softAqua.opacity(0.08))
                .frame(width: 30, height: 30)
                .offset(
                    x: w * 0.35,
                    y: h * 0.55 + (bubbleFloat ? -6 : 2)
                )

            // Bubble 4 — tiny sparkle
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 16, height: 16)
                .offset(
                    x: w * 0.78,
                    y: h * 0.35 + (bubbleFloat ? -4 : 1)
                )

            // Bubble 5 — subtle large blur
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.cyanBlue.opacity(0.08), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 55
                    )
                )
                .frame(width: 110, height: 110)
                .offset(
                    x: w * 0.65,
                    y: h * 0.55 + (bubbleFloat ? -3 : 5)
                )
        }
        .clipped()
    }

    // MARK: - Shimmer Streak

    private var shimmerStreak: some View {
        HeaderWaveShape(waveHeight: 14)
            .fill(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.white.opacity(0.08),
                        Color.white.opacity(0.15),
                        Color.white.opacity(0.08),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .mask(
                Rectangle()
                    .frame(width: 120)
                    .offset(x: shimmerOffset)
            )
    }
}

// MARK: - Header Wave Shape

/// A shape with a flat top and a gentle wave along the bottom edge.
struct HeaderWaveShape: Shape {
    var waveHeight: CGFloat = 12

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - waveHeight))

        // Gentle wave across the bottom
        path.addCurve(
            to: CGPoint(x: rect.maxX * 0.5, y: rect.maxY),
            control1: CGPoint(x: rect.maxX * 0.82, y: rect.maxY - waveHeight * 2.2),
            control2: CGPoint(x: rect.maxX * 0.68, y: rect.maxY + waveHeight * 0.6)
        )
        path.addCurve(
            to: CGPoint(x: 0, y: rect.maxY - waveHeight),
            control1: CGPoint(x: rect.maxX * 0.32, y: rect.maxY + waveHeight * 0.3),
            control2: CGPoint(x: rect.maxX * 0.18, y: rect.maxY - waveHeight * 1.5)
        )

        path.addLine(to: .zero)
        path.closeSubpath()
        return path
    }
}


struct QuickActionsGrid: View {
    @Binding var showCheckIn: Bool
    @Binding var showSelfCare: Bool
    @Binding var showGratitude: Bool
    @Binding var showJournal: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                QuickActionCard(
                    title: "Daily Check-in",
                    icon: "heart.fill",
                    color: .cyanBlue,
                    action: { showCheckIn = true }
                )
                
                QuickActionCard(
                    title: "Self-Care",
                    icon: "sparkles",
                    color: .softAqua,
                    action: { showSelfCare = true }
                )
                
                QuickActionCard(
                    title: "Gratitude",
                    icon: "star.fill",
                    color: .cyanBlue.opacity(0.8),
                    action: { showGratitude = true }
                )
                
                QuickActionCard(
                    title: "Journal",
                    icon: "book.fill",
                    color: .deepTeal,
                    action: { showJournal = true }
                )
            }
        }
        .padding(.horizontal, 16)
    }
}

struct DailyQuoteCard: View {
    @State private var quote = QuoteManager.shared.quoteOfTheDay()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.primaryAccent)
                
                Text("Today's Inspiration")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            
            Text(quote.text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textPrimary)
                .lineSpacing(4)
                .italic()
            
            Text("— \(quote.author)")
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 16)
    }
}

struct InsightOfTheWeekCard: View {
    @State private var insight: Insight? = nil
    @State private var insightVisible = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Group {
            if let insight = insight {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Insight of the Week")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.deepTeal)
                        .padding(.horizontal, 16)
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 20))
                            .foregroundColor(.cyanBlue)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(insight.title)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.deepTeal)
                            Text(insight.description)
                                .font(.system(size: 13))
                                .foregroundColor(.softAqua)
                                .lineLimit(2)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(14)
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.08), radius: 6, x: 0, y: 2)
                }
                .padding(.horizontal, 16)
                .opacity(insightVisible ? 1 : 0)
                .offset(y: insightVisible ? 0 : 8)
            }
        }
        .onAppear {
            let entries = EmotionalArchive.shared.loadAll()
            insight = MoodRhythmLogic.analyzeWeeklyMoods(entries).first
            if !reduceMotion {
                withAnimation(.easeOut(duration: 0.4)) {
                    insightVisible = true
                }
            } else {
                insightVisible = true
            }
        }
    }
}

struct MiniBehavioralInsightCard: View {
    @State private var insight: BehavioralInsight? = nil
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Group {
            if let insight = insight {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Insight")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.deepTeal)
                    BehavioralInsightCard(insight: insight, showConfidence: false, compact: true)
                }
                .padding(.horizontal, 16)
            }
        }
        .onAppear {
            let moods = EmotionalArchive.shared.loadAll()
            let journals = JournalDataStore.shared.loadAll()
            let selfCare = SelfCareDataStore.shared.loadAll()
            insight = InsightComposer.analyze(moods: moods, journals: journals, selfCare: selfCare).first
        }
    }
}

struct MiniInsightsCard: View {
    @State private var moodEntries: [MoodEntry] = []
    @State private var streak = 0
    @State private var displayedStreak = 0
    @State private var displayedCount = 0
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Week")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.deepTeal)
            
            HStack(spacing: 8) {
                ForEach(last7Days(), id: \.self) { date in
                    VStack(spacing: 4) {
                        if let entry = moodEntries.first(where: { Calendar.current.isDate($0.timestamp, inSameDayAs: date) }) {
                            Image(systemName: entry.iconName)
                                .font(.system(size: 20))
                                .foregroundColor(.deepTeal)
                                .accessibilityLabel(MoodEntry.label(for: entry.emoji))
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 20, height: 20)
                        }
                        Text(dayLetter(for: date))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            HStack(spacing: 16) {
                StatPill(icon: "flame.fill", value: "\(displayedStreak)", label: "Streak", color: .orange)
                StatPill(icon: "checkmark.circle.fill", value: "\(displayedCount)", label: "Entries", color: .cyanBlue)
                
                if let mostUsedMood = mostUsedMood() {
                    HStack(spacing: 6) {
                        Image(systemName: MoodEntry.iconName(for: mostUsedMood))
                            .font(.system(size: 16))
                            .foregroundColor(.deepTeal)
                            .accessibilityLabel(MoodEntry.label(for: mostUsedMood))
                        Text("Most felt")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.softAqua.opacity(0.2))
                    .cornerRadius(20)
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 16)
        .onAppear {
            loadMoodData()
        }
    }
    
    private func loadMoodData() {
        moodEntries = EmotionalArchive.shared.loadAll()
        streak = calculateStreak(from: moodEntries)
        if reduceMotion {
            displayedStreak = streak
            displayedCount = moodEntries.count
        } else {
            animateCountUp(toStreak: streak, toCount: moodEntries.count)
        }
    }

    private func animateCountUp(toStreak targetStreak: Int, toCount targetCount: Int) {
        let steps = 20
        let duration: Double = 0.6
        let stepInterval = duration / Double(steps)
        let streakStep = max(1, targetStreak / steps)
        let countStep = max(1, targetCount / steps)
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepInterval * Double(i)) {
                displayedStreak = min(targetStreak, displayedStreak + streakStep)
                displayedCount = min(targetCount, displayedCount + countStep)
                if i == steps {
                    displayedStreak = targetStreak
                    displayedCount = targetCount
                }
            }
        }
    }
    
    private func last7Days() -> [Date] {
        let calendar = Calendar.current
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: Date())
        }.reversed()
    }
    
    private func dayLetter(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
    
    private func mostUsedMood() -> String? {
        let last7DaysEntries = moodEntries.filter { entry in
            Calendar.current.dateComponents([.day], from: entry.timestamp, to: Date()).day ?? 0 <= 7
        }
        
        let moodCounts = Dictionary(grouping: last7DaysEntries, by: { $0.emoji })
            .mapValues { $0.count }
        
        return moodCounts.max(by: { $0.value < $1.value })?.key
    }
    
    private func calculateStreak(from entries: [MoodEntry]) -> Int {
        guard !entries.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let sortedEntries = entries.sorted { $0.timestamp > $1.timestamp }
        
        var streak = 0
        var currentDate = Date()
        
        for entry in sortedEntries {
            if calendar.isDate(entry.timestamp, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else if calendar.isDate(entry.timestamp, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
}

struct StatPill: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color.opacity(0.15))
        .cornerRadius(20)
    }
}

struct ExploreSection: View {
    @Binding var selectedTab: TabItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Explore")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.deepTeal)
                .padding(.horizontal, 16)
            
            VStack(spacing: 12) {
                ArticleCard(
                    title: "Mental Wellness Library",
                    illustration: "lightbulb.fill",
                    color: .softAqua,
                    action: { 
                        withAnimation {
                            selectedTab = .awareness
                        }
                    }
                )
                
                ArticleCard(
                    title: "Your Mood Calendar",
                    illustration: "calendar",
                    color: .cyanBlue,
                    action: { 
                        withAnimation {
                            selectedTab = .calendar
                        }
                    }
                )
            }
            .padding(.horizontal, 16)
        }
    }
}

struct MotivationalBanner: View {
    @State private var isVisible = true
    
    var body: some View {
        if isVisible {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("You're doing great!")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Keep tracking to see your progress.")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isVisible = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Color.cyanBlue, Color.softAqua],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: Color.cyanBlue.opacity(0.3), radius: 8, x: 0, y: 4)
            .padding(.horizontal, 16)
            .transition(.scale.combined(with: .opacity))
        }
    }
}

// MARK: - SmartMoodBanner
struct SmartMoodBanner: View {
    @State private var message: String = "You’re building something beautiful."
    @State private var isVisible = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        Group {
            if isVisible {
                HStack {
                    Text(message)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.deepTeal)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    Spacer()
                }
                .glassCard(cornerRadius: 12)
                .padding(.horizontal, 20)
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .onAppear {
            determineMessage()
            if !reduceMotion {
                withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                    isVisible = true
                }
            } else {
                isVisible = true
            }
            HapticManager.light()
        }
    }
    
    private func determineMessage() {
        let moods = EmotionalArchive.shared.loadAll()
        let today = Calendar.current.startOfDay(for: Date())
        let hasMoodToday = moods.contains { Calendar.current.isDate($0.timestamp, inSameDayAs: today) }
        
        if !hasMoodToday {
            message = "Let’s check in today 🌿"
            return
        }
        
        let streak = calculateStreak(from: moods)
        if streak >= 5 {
            message = "🔥 You're on fire! \(streak)-day streak!"
            return
        }
        
        if GreetingManager.weeklyAverageScore() < -0.3 {
            message = "It’s okay to slow down. Try a 5-minute reset."
            return
        }
        
        message = "You’re building something beautiful."
    }
    
    private func calculateStreak(from entries: [MoodEntry]) -> Int {
        guard !entries.isEmpty else { return 0 }
        let calendar = Calendar.current
        let sortedEntries = entries.sorted { $0.timestamp > $1.timestamp }
        var streak = 0
        var currentDate = Date()
        for entry in sortedEntries {
            if calendar.isDate(entry.timestamp, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else if calendar.isDate(entry.timestamp, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        return streak
    }
}

// MARK: - DailyFlowCard
struct DailyFlowCard: View {
    @State private var hasMood = false
    @State private var hasGratitude = false
    @State private var hasJournal = false
    @State private var hasFocus = false
    @State private var showCompletion = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Flow")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.deepTeal)
            
            VStack(spacing: 12) {
                FlowChecklistItem(title: "Mood Check-in", isCompleted: hasMood)
                FlowChecklistItem(title: "Gratitude Entry", isCompleted: hasGratitude)
                FlowChecklistItem(title: "Journal Reflection", isCompleted: hasJournal)
                FlowChecklistItem(title: "5 min Focus", isCompleted: hasFocus)
            }
            
            if showCompletion {
                Text("✨ Daily Flow Complete!")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.cyanBlue)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
                    .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 16)
        .padding(.horizontal, 20)
        .onAppear {
            checkCompletion()
        }
        .overlay(
            ZStack {
                if showCompletion {
                    ConfettiView(particleCount: 30).allowsHitTesting(false)
                }
            }
        )
    }
    
    private func checkCompletion() {
        let today = Calendar.current.startOfDay(for: Date())
        let moods = EmotionalArchive.shared.loadAll()
        let grats = GratitudeDataStore.shared.loadAll()
        let journals = JournalDataStore.shared.loadAll()
        
        hasMood = moods.contains { Calendar.current.isDate($0.timestamp, inSameDayAs: today) }
        hasGratitude = grats.contains { Calendar.current.isDate($0.timestamp, inSameDayAs: today) }
        hasJournal = journals.contains { Calendar.current.isDate($0.timestamp, inSameDayAs: today) }
        
        let todayString = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let focusDict = UserDefaults.standard.dictionary(forKey: "moodnest_focusTracker") as? [String: Int] ?? [:]
        let focusMins = focusDict[todayString] ?? 0
        hasFocus = focusMins >= 5
        
        let allDone = hasMood && hasGratitude && hasJournal && hasFocus
        if allDone && !showCompletion {
            HapticManager.success()
            withAnimation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.7)) {
                showCompletion = true
            }
        } else if allDone {
            showCompletion = true
        }
    }
}

struct FlowChecklistItem: View {
    let title: String
    let isCompleted: Bool
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(isCompleted ? Color.cyanBlue : Color.softAqua.opacity(0.5), lineWidth: 2)
                    .frame(width: 24, height: 24)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.cyanBlue)
                        .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
                }
            }
            .animation(reduceMotion ? .none : .spring(response: 0.4, dampingFraction: 0.6), value: isCompleted)
            
            Text(title)
                .font(.system(size: 15, weight: isCompleted ? .medium : .regular))
                .foregroundColor(isCompleted ? .deepTeal : .gray)
            Spacer()
        }
    }
}

// MARK: - Live Insight Card (Jury Demo)
struct LiveInsightCard: View {
    @State private var insightResult: LiveInsightResult = LiveInsightResult(message: "Loading...", tone: .neutral)
    @State private var appear = false
    @State private var pulseOpacity = 0.4
    @State private var entries: [MoodEntry] = []
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                if !reduceMotion {
                    Circle()
                        .fill(accentColor.opacity(pulseOpacity * 0.5))
                        .frame(width: 44, height: 44)
                        .scaleEffect(1.3)
                }
                
                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundColor(accentColor)
                    .frame(width: 44, height: 44)
                    .background(accentColor.opacity(0.15))
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Live Mood Insight")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.deepTeal)
                
                Text(insightResult.message)
                    .font(.system(size: 14))
                    .foregroundColor(.softAqua)
                    .lineSpacing(4)
            }
            Spacer(minLength: 0)
        }
        .padding(20)
        .glassCard(cornerRadius: 16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(
                        colors: [accentColor.opacity(0.4), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
        )
        .padding(.horizontal, 16)
        .opacity(appear || reduceMotion ? 1 : 0)
        .offset(y: appear || reduceMotion ? 0 : 10)
        .scaleEffect(appear || reduceMotion ? 1 : 0.98)
        .onAppear {
            entries = EmotionalArchive.shared.loadAll()
            insightResult = MoodRhythmLogic.liveInsight(from: entries)
            if !reduceMotion {
                withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                    appear = true
                }
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    pulseOpacity = 0.15
                }
            } else {
                appear = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            let newEntries = EmotionalArchive.shared.loadAll()
            if newEntries.count != entries.count {
                entries = newEntries
            }
        }
        .onChange(of: entries.count, perform: { _ in
            refreshWithAnimation()
        })
        
        
    }
    
    private func refreshWithAnimation() {
        if !reduceMotion {
            withAnimation(.easeIn(duration: 0.2)) {
                appear = false
                
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (reduceMotion ? 0 : 0.2)) {
            insightResult = MoodRhythmLogic.liveInsight(from: entries)
            HapticManager.light()
            
            if !reduceMotion {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    appear = true
                }
            } else {
                appear = true
            }
        }
        
    }
    
    private var accentColor: Color {
        switch insightResult.tone {
        case .positive: return .green
        case .caution: return .orange.opacity(0.9)
        case .neutral: return .teal
        }
    }
    
    private var iconName: String {
        switch insightResult.tone {
        case .positive: return "arrow.up.right"
        case .neutral: return "minus"
        case .caution: return "arrow.down.right"
        }
    }
       
}
    

#Preview {
    NewHomeView()
}
