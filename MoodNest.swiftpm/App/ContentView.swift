import SwiftUI

struct ContentView: View {
    @State private var showOnboarding = true
    @AppStorage("moodnest_appTheme") private var appTheme: String = "System"
    
    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView(onComplete: {
                    showOnboarding = false
                })
            } else {
                NewHomeView()
            }
        }
        .preferredColorScheme(colorScheme)
        .task {
            // Phase 1: Re-register daily reminder on launch if enabled
            await NotificationManager.shared.reRegisterIfNeeded()
        }
    }
    
    private var colorScheme: ColorScheme? {
        switch appTheme {
        case "Light": return .light
        case "Dark": return .dark
        default: return nil // System
        }
    }
}
