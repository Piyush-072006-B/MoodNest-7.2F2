import Foundation

/// Manages onboarding state using UserDefaults
@MainActor
class OnboardingManager: ObservableObject {
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "moodnest_hasCompletedOnboarding")
        }
    }
    
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "moodnest_hasCompletedOnboarding")
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
    }
    
    // Static helper methods for convenience
    static func hasCompletedOnboarding() -> Bool {
        return UserDefaults.standard.bool(forKey: "moodnest_hasCompletedOnboarding")
    }
    
    static func markOnboardingComplete() {
        UserDefaults.standard.set(true, forKey: "moodnest_hasCompletedOnboarding")
    }
    
    static func resetOnboarding() {
        UserDefaults.standard.removeObject(forKey: "moodnest_hasCompletedOnboarding")
    }
}
