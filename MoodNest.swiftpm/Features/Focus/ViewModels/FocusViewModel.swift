import SwiftUI
import AVFoundation

/// ViewModel for the focus/breathing screen — manages mode selection,
/// ambient sound state, and breathing session progress.
@MainActor
final class FocusViewModel: ObservableObject {
    @Published var selectedMode: FocusView.FocusMode = .breathe
    @Published var selectedAmbient: AmbientSoundType? = nil
    @Published var breathingSessionProgress: Double = 0

    let ambientPlayer = AmbientSoundPlayer()

    func stopAmbientSound() {
        ambientPlayer.stop()
    }
}
