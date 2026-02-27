import SwiftUI
import AVFoundation
import Combine

// MARK: - FocusView (Shell)

struct FocusView: View {
    @State private var selectedMode: FocusMode = .breathe
    @Binding var selectedTab: TabItem
    @State private var ambientPlayer = AmbientSoundPlayer()
    @State private var selectedAmbient: AmbientSoundType? = nil
    @State private var breathingSessionProgress: Double = 0

    enum FocusMode {
        case breathe, timer
    }

    private var focusBackgroundGradient: LinearGradient {
        let start = Color.lightSky
        let end = Color.softAqua.opacity(0.15)
        if selectedMode == .timer || breathingSessionProgress <= 0 {
            return LinearGradient(colors: [start, end], startPoint: .top, endPoint: .bottom)
        }
        let blend = Color.cyanBlue.opacity(0.08 + breathingSessionProgress * 0.12)
        return LinearGradient(
            colors: [start, blend, end],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var body: some View {
        ZStack {
            DecorativeBackground(gradient: focusBackgroundGradient)

            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()

                    VStack(spacing: 4) {
                        Image(systemName: "wind")
                            .font(.system(size: 24))
                            .foregroundColor(.cyanBlue)

                        Text("Focus & Breathe")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.deepTeal)
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(Color.lightSky)

                // Mode Selector
                Picker("Mode", selection: $selectedMode) {
                    Text("Breathe").tag(FocusMode.breathe)
                    Text("Focus Timer").tag(FocusMode.timer)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                // Content
                GeometryReader { geometry in
                    ScrollView {
                        VStack(spacing: 16) {
                            // Ambient Sound Card
                            AmbientSoundCard(
                                selectedAmbient: $selectedAmbient,
                                player: ambientPlayer
                            )

                            if selectedMode == .breathe {
                                BreathingCardView(sessionProgress: $breathingSessionProgress)
                            } else {
                                FocusTimerView()
                            }
                        }
                        .frame(minHeight: geometry.size.height)
                    }
                }
            }
        }
        .ignoresSafeArea(.keyboard)
        .onDisappear {
            ambientPlayer.stop()
        }
    }
}

// MARK: - Breathing Pattern

struct BreathingPattern: Equatable {
    let name: String
    let label: String
    let inhale: Double
    let hold: Double
    let exhale: Double

    static let box        = BreathingPattern(name: "Box",  label: "4-4-4", inhale: 4, hold: 4, exhale: 4)
    static let relaxing   = BreathingPattern(name: "4-7-8", label: "4-7-8", inhale: 4, hold: 7, exhale: 8)
    static let calm       = BreathingPattern(name: "Calm", label: "5-5",   inhale: 5, hold: 0, exhale: 5)
    /// Slower inhale, longer exhale for low/anxious mood
    static let lowMood    = BreathingPattern(name: "Gentle", label: "5-7", inhale: 5, hold: 0, exhale: 7)

    static let all: [BreathingPattern] = [.box, .relaxing, .calm]
}

// MARK: - Breathing Phase

enum BreathingPhase: String {
    case inhale  = "Inhale..."
    case hold    = "Hold..."
    case exhale  = "Exhale..."
    case ready   = "Ready"

    var color: Color {
        switch self {
        case .inhale: return .cyanBlue
        case .hold:   return .softAqua
        case .exhale: return .deepTeal
        case .ready:  return .cyanBlue
        }
    }

    var shadowColor: Color {
        switch self {
        case .inhale: return .cyanBlue.opacity(0.35)
        case .hold:   return .softAqua.opacity(0.2)
        case .exhale: return .deepTeal.opacity(0.35)
        case .ready:  return .cyanBlue.opacity(0.2)
        }
    }
}

// MARK: - Breathing Card View

struct BreathingCardView: View {
    @Binding var sessionProgress: Double
    @State private var currentPhase: BreathingPhase = .ready
    @State private var isBreathing = false
    @State private var orbScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.3
    @State private var cycleCount = 0
    @State private var selectedPattern: BreathingPattern = .relaxing
    @State private var effectivePattern: BreathingPattern = .relaxing
    @State private var breathTask: Task<Void, Never>? = nil
    @State private var sessionStartTime: Date? = nil
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    private static let sessionDuration: TimeInterval = 120

    init(sessionProgress: Binding<Double> = .constant(0)) {
        _sessionProgress = sessionProgress
    }

    var body: some View {
        VStack(spacing: 28) {

            // MARK: Pattern Selector
            patternSelector
                .padding(.top, 24)

            // MARK: Description
            VStack(spacing: 6) {
                Text(effectivePattern.name)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.deepTeal)

                Text(patternDescription)
                    .font(.system(size: 13))
                    .foregroundColor(.softAqua)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            // MARK: Breathing Orb (soft phase-based background shift)
            ZStack {
                Circle()
                    .fill(currentPhase.color.opacity(reduceMotion ? 0.04 : 0.08))
                    .frame(width: 220, height: 220)
                    .scaleEffect(orbScale)
                    .animation(reduceMotion ? .none : .easeInOut(duration: 0.5), value: currentPhase)
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                currentPhase.color.opacity(glowOpacity * 0.5),
                                currentPhase.color.opacity(0)
                            ],
                            center: .center,
                            startRadius: 40,
                            endRadius: 140
                        )
                    )
                    .frame(width: 280, height: 280)
                    .scaleEffect(orbScale)
                    .animation(orbAnimation, value: orbScale)

                // Main orb
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                currentPhase.color.opacity(0.6),
                                currentPhase.color.opacity(0.25),
                                currentPhase.color.opacity(0.08)
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 100
                        )
                    )
                    .frame(width: 180, height: 180)
                    .scaleEffect(orbScale)
                    .shadow(color: currentPhase.shadowColor, radius: 10, x: 0, y: 0)
                    .animation(orbAnimation, value: orbScale)

                // Inner ring
                Circle()
                    .stroke(
                        currentPhase.color.opacity(0.4),
                        lineWidth: 2
                    )
                    .frame(width: 180, height: 180)
                    .scaleEffect(orbScale)
                    .animation(orbAnimation, value: orbScale)

                // Phase label + cycle count
                VStack(spacing: 6) {
                    Text(currentPhase.rawValue)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(currentPhase.color)
                        .id(currentPhase) // drives crossfade
                        .transition(.opacity)

                    if isBreathing && cycleCount > 0 {
                        Text("Cycle \(cycleCount)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.softAqua)
                            .transition(.opacity)
                    }
                }
                .animation(reduceMotion ? .none : .easeInOut(duration: 0.3), value: currentPhase)
                .animation(reduceMotion ? .none : .easeInOut(duration: 0.3), value: cycleCount)
            }
            .accessibilityLabel(isBreathing ? currentPhase.rawValue : "Breathing exercise")
            .padding(.vertical, 8)

            // MARK: Start / Stop Button
            Button(action: toggleBreathing) {
                HStack(spacing: 10) {
                    Image(systemName: isBreathing ? "stop.fill" : "play.fill")
                        .font(.system(size: 16, weight: .semibold))

                    Text(isBreathing ? "Stop" : "Start Breathing")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isBreathing
                              ? LinearGradient(colors: [Color.red.opacity(0.85), Color.red], startPoint: .leading, endPoint: .trailing)
                              : LinearGradient(colors: [Color.cyanBlue, Color.deepTeal], startPoint: .leading, endPoint: .trailing)
                        )
                )
                .shadow(color: isBreathing ? Color.red.opacity(0.2) : Color.cyanBlue.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 20)
        }
        .padding(20)
        .glassCard(cornerRadius: 20, borderWidth: 1)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 120)
        .onAppear {
            effectivePattern = selectedPattern
        }
        .onChange(of: selectedPattern, perform: { _ in
            if !isBreathing { effectivePattern = selectedPattern }
        })
        .onDisappear {
            stopBreathing()
        }
    }

    // MARK: - Subviews

    private var patternSelector: some View {
        HStack(spacing: 10) {
            ForEach(BreathingPattern.all, id: \.name) { pattern in
                Button(action: {
                    guard !isBreathing else { return }
                    selectedPattern = pattern
                    HapticManager.light()
                }) {
                    Text(pattern.label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(selectedPattern == pattern ? .white : .cyanBlue)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background(
                            Capsule()
                                .fill(selectedPattern == pattern
                                      ? Color.cyanBlue
                                      : Color.softAqua.opacity(0.18))
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder(selectedPattern == pattern ? Color.cyanBlue : Color.softAqua.opacity(0.3), lineWidth: 1)
                        )
                }
                .disabled(isBreathing)
                .opacity(isBreathing && selectedPattern != pattern ? 0.4 : 1.0)
            }
        }
    }

    private var patternDescription: String {
        if effectivePattern.hold == 0 {
            return "Inhale for \(Int(effectivePattern.inhale))s, exhale for \(Int(effectivePattern.exhale))s"
        }
        return "Inhale \(Int(effectivePattern.inhale))s · Hold \(Int(effectivePattern.hold))s · Exhale \(Int(effectivePattern.exhale))s"
    }

    private var orbAnimation: Animation? {
        guard !reduceMotion else { return .none }
        switch currentPhase {
        case .inhale: return .easeInOut(duration: effectivePattern.inhale)
        case .hold:   return .easeInOut(duration: 0.3)
        case .exhale: return .easeInOut(duration: effectivePattern.exhale)
        case .ready:  return .easeInOut(duration: 0.4)
        }
    }

    // MARK: - Control

    private func toggleBreathing() {
        if isBreathing {
            stopBreathing()
        } else {
            startBreathing()
        }
    }

    private func startBreathing() {
        isBreathing = true
        cycleCount = 0
        currentPhase = .inhale
        sessionProgress = 0
        sessionStartTime = Date()
        let latestMood = EmotionalArchive.shared.loadAll().sorted { $0.timestamp > $1.timestamp }.first
        let moodScore = latestMood.map { InsightComposer.moodScore(for: $0.emoji) } ?? 0
        effectivePattern = moodScore < RecoveryEngine.lowMoodThreshold ? .lowMood : selectedPattern
        HapticManager.light()

        breathTask = Task { @MainActor in
            await runCycle()
        }
    }

    private func stopBreathing() {
        let hadCycles = cycleCount >= 1
        breathTask?.cancel()
        breathTask = nil
        isBreathing = false
        orbScale = 1.0
        glowOpacity = 0.3
        currentPhase = .ready
        sessionProgress = 0
        sessionStartTime = nil
        if hadCycles {
            HapticManager.medium()
        }
    }

    // MARK: - Async Breath Cycle

    @MainActor
    private func runCycle() async {
        let pattern = effectivePattern

        while !Task.isCancelled && isBreathing {

            // --- Inhale ---
            currentPhase = .inhale
            orbScale = 1.25
            glowOpacity = 0.6
            HapticManager.light()
            try? await Task.sleep(nanoseconds: UInt64(pattern.inhale * 1_000_000_000))
            guard !Task.isCancelled && isBreathing else { break }

            // --- Hold (skip if duration is 0, e.g. Calm pattern) ---
            if pattern.hold > 0 {
                currentPhase = .hold
                HapticManager.light()
                try? await Task.sleep(nanoseconds: UInt64(pattern.hold * 1_000_000_000))
                guard !Task.isCancelled && isBreathing else { break }
            }

            // --- Exhale (softer haptic) ---
            currentPhase = .exhale
            orbScale = 1.0
            glowOpacity = 0.3
            HapticManager.selection()
            try? await Task.sleep(nanoseconds: UInt64(pattern.exhale * 1_000_000_000))
            guard !Task.isCancelled && isBreathing else { break }

            // --- Cycle complete ---
            cycleCount += 1
            if let start = sessionStartTime {
                let elapsed = Date().timeIntervalSince(start)
                sessionProgress = min(1.0, elapsed / Self.sessionDuration)
            }
            HapticManager.notification(.success)
        }
    }
}

// MARK: - Focus Engine (internal: timer + breathing logic)

private struct FocusEngine {
    @MainActor
    final class TimerEngine: ObservableObject {
        @Published var isRunning = false
        @Published var timeRemaining = 25 * 60
        @Published var selectedDuration = 25
        @Published var isBreakMode = false
        private var timerCancellable: AnyCancellable?

        var progress: CGFloat {
            let totalTime = Double(selectedDuration * 60)
            return CGFloat(1.0 - (Double(timeRemaining) / totalTime))
        }

        var timeString: String {
            let minutes = timeRemaining / 60
            let seconds = timeRemaining % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }

        func toggleTimer() {
            if isRunning { pauseTimer() } else { startTimer() }
        }

        func startTimer() {
            isRunning = true
            timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    guard let self = self else { return }
                    if self.timeRemaining > 0 {
                        self.timeRemaining -= 1
                    }
                    if self.timeRemaining == 0 {
                        self.timerCompleted()
                    }
                }
        }

        func pauseTimer() {
            isRunning = false
            timerCancellable?.cancel()
            timerCancellable = nil
        }

        func resetTimer() {
            isRunning = false
            timerCancellable?.cancel()
            timerCancellable = nil
            timeRemaining = selectedDuration * 60
            isBreakMode = false
        }

        func setDuration(_ mins: Int) {
            selectedDuration = mins
            timeRemaining = mins * 60
        }

        private func timerCompleted() {
            isRunning = false
            timerCancellable?.cancel()
            timerCancellable = nil
            HapticManager.medium()
            if !isBreakMode {
                // Focus session completed
                let todayString = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
                var dict = UserDefaults.standard.dictionary(forKey: "moodnest_focusTracker") as? [String: Int] ?? [:]
                let current = dict[todayString] ?? 0
                dict[todayString] = current + selectedDuration
                UserDefaults.standard.set(dict, forKey: "moodnest_focusTracker")

                isBreakMode = true
                selectedDuration = 5
                timeRemaining = 5 * 60
            } else {
                isBreakMode = false
                selectedDuration = 25
                timeRemaining = 25 * 60
            }
        }
    }
}

// MARK: - Focus Timer View

struct FocusTimerView: View {
    @StateObject private var engine = FocusEngine.TimerEngine()
    @Environment(\.scenePhase) var scenePhase

    let durations = [5, 15, 25, 45]

    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 12) {
                Text(engine.isBreakMode ? "Break Time" : "Focus Session")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.deepTeal)

                Text(engine.isBreakMode ? "Take a well-deserved break" : "Stay focused on your task")
                    .font(.system(size: 14))
                    .foregroundColor(.softAqua)
            }
            .padding(.top, 40)

            ZStack {
                Circle()
                    .stroke(Color.softAqua.opacity(0.2), lineWidth: 20)
                    .frame(width: 250, height: 250)

                Circle()
                    .trim(from: 0, to: engine.progress)
                    .stroke(
                        engine.isBreakMode ? Color.green : Color.cyanBlue,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.5), value: engine.progress)

                VStack(spacing: 8) {
                    Text(engine.timeString)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.deepTeal)
                        .monospacedDigit()

                    Text("\(engine.selectedDuration) min session")
                        .font(.system(size: 14))
                        .foregroundColor(.softAqua)
                }
            }
            .accessibilityLabel("Timer: \(engine.timeString)")

            if !engine.isRunning {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Session Duration")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.deepTeal)

                    HStack(spacing: 12) {
                        ForEach(durations, id: \.self) { duration in
                            Button(action: {
                                engine.setDuration(duration)
                            }) {
                                Text("\(duration)m")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(engine.selectedDuration == duration ? .white : .cyanBlue)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(engine.selectedDuration == duration ? Color.cyanBlue : Color.softAqua.opacity(0.2))
                                    .cornerRadius(20)
                            }
                        }
                    }
                }
                .padding(.horizontal, 40)
            }

            HStack(spacing: 16) {
                if engine.isRunning {
                    Button(action: { engine.resetTimer() }) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.red)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Stop timer")
                }

                Button(action: { engine.toggleTimer() }) {
                    Image(systemName: engine.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(Color.cyanBlue)
                        .clipShape(Circle())
                }
                .accessibilityLabel(engine.isRunning ? "Pause timer" : "Start timer")
            }
            .padding(.bottom, 120)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onChange(of: scenePhase, perform: { newPhase in
            if newPhase == .background && engine.isRunning {
                // Timer continues in background
            }
        })
    }
}


// MARK: - Ambient Sound System (Phase 7)

enum AmbientSoundType: String, CaseIterable {
    case rain   = "Rain"
    case forest = "Forest"
    case waves  = "Waves"

    var icon: String {
        switch self {
        case .rain:   return "cloud.rain.fill"
        case .forest: return "leaf.fill"
        case .waves:  return "water.waves"
        }
    }

    /// Frequency band center used for filtered noise
    var filterFrequency: Float {
        switch self {
        case .rain:   return 4000
        case .forest: return 2200
        case .waves:  return 600
        }
    }

    /// Bandwidth multiplier for the band-pass
    var bandwidth: Float {
        switch self {
        case .rain:   return 6000
        case .forest: return 3000
        case .waves:  return 800
        }
    }
}

/// Generates procedural ambient noise using AVAudioEngine —
/// no bundled audio files required (offline, .swiftpm compatible).
final class AmbientSoundPlayer {
    private var engine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private(set) var isPlaying = false
    private(set) var currentSound: AmbientSoundType?

    func play(_ type: AmbientSoundType) {
        stop()

        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        let eq = AVAudioUnitEQ(numberOfBands: 1)

        // Configure band-pass filter for the sound type
        let band = eq.bands[0]
        band.filterType = .bandPass
        band.frequency = type.filterFrequency
        band.bandwidth = type.bandwidth / type.filterFrequency
        band.gain = 0
        band.bypass = false

        engine.attach(player)
        engine.attach(eq)

        guard let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1) else { return }
        engine.connect(player, to: eq, format: format)
        engine.connect(eq, to: engine.mainMixerNode, format: format)
        engine.mainMixerNode.outputVolume = 0.25

        // Generate white noise buffer
        let bufferSize: AVAudioFrameCount = 44100 * 2 // 2 seconds
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: bufferSize) else { return }
        buffer.frameLength = bufferSize

        if let data = buffer.floatChannelData?[0] {
            for i in 0..<Int(bufferSize) {
                data[i] = Float.random(in: -0.3...0.3)
            }
        }

        do {
            try engine.start()
            player.play()
            player.scheduleBuffer(buffer, at: nil, options: .loops)
            self.engine = engine
            self.playerNode = player
            self.isPlaying = true
            self.currentSound = type
        } catch {
            // Fail silently; UI can show playing state false
        }
    }

    func stop() {
        playerNode?.stop()
        engine?.stop()
        engine = nil
        playerNode = nil
        isPlaying = false
        currentSound = nil
    }
}

// MARK: - Ambient Sound Card

struct AmbientSoundCard: View {
    @Binding var selectedAmbient: AmbientSoundType?
    let player: AmbientSoundPlayer

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.cyanBlue)
                Text("Ambient Sounds")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.deepTeal)
            }

            HStack(spacing: 10) {
                ForEach(AmbientSoundType.allCases, id: \.self) { type in
                    Button(action: {
                        if selectedAmbient == type {
                            selectedAmbient = nil
                            player.stop()
                        } else {
                            selectedAmbient = type
                            player.play(type)
                        }
                        HapticManager.light()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: type.icon)
                                .font(.system(size: 14))
                            Text(type.rawValue)
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(selectedAmbient == type ? .white : .cyanBlue)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedAmbient == type ? Color.cyanBlue : Color.softAqua.opacity(0.18))
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder(
                                    selectedAmbient == type ? Color.cyanBlue : Color.softAqua.opacity(0.3),
                                    lineWidth: 1
                                )
                        )
                    }
                }

                Spacer()
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 16)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

#Preview {
    FocusView(selectedTab: .constant(.home))
}
