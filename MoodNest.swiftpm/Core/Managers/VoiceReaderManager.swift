import AVFoundation
import SwiftUI

@MainActor
final class VoiceReaderManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {

    static let shared = VoiceReaderManager()

    // Stored property — retaining the synthesizer is required for audio to play
    private let synthesizer = AVSpeechSynthesizer()

    @Published var currentlyPlayingID: String? = nil

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    // MARK: - Public API

    func toggle(text: String, storyID: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        HapticManager.light()

        if currentlyPlayingID == storyID {
            stop()
        } else {
            speak(text: text, id: storyID)
        }
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        currentlyPlayingID = nil
        deactivateSession()
    }

    // MARK: - Core Speak Logic

    private func speak(text: String, id: String) {
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else { return }

        // Stop any currently playing speech before starting new one
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        // Override any previous .record session with .playback
        configureAudioSession()

        let utterance = AVSpeechUtterance(string: text)

        // Dynamic voice: prefer device locale, fall back to en-US, then first available
        if let voice = AVSpeechSynthesisVoice(language: Locale.current.identifier) {
            utterance.voice = voice
        } else if let voice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = voice
        } else {
            utterance.voice = AVSpeechSynthesisVoice.speechVoices().first
        }

        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.volume = 1.0
        utterance.pitchMultiplier = 1.0

        synthesizer.speak(utterance)
        currentlyPlayingID = id
    }

    // MARK: - Audio Session

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? session.setActive(true)
    }

    private func deactivateSession() {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    // MARK: - AVSpeechSynthesizerDelegate

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                                       didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.currentlyPlayingID = nil
            self.deactivateSession()
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                                       didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.currentlyPlayingID = nil
            self.deactivateSession()
        }
    }
}
