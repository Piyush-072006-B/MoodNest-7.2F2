import SwiftUI

/// Predefined gradients for MoodNest app
/// All gradients now use adaptive colors that automatically adjust for dark mode
struct MoodGradients {
    // Header gradient: Adaptive colors (Teal in light, Blue in dark)
    static let header = LinearGradient(
        colors: [Color.primaryAction, Color.primaryAccent],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // Button gradient: Adaptive primary action colors
    static let button = LinearGradient(
        colors: [Color.primaryAction, Color.primaryAccent],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // Primary button gradient (alias for compatibility)
    static let primaryButton = button
    
    // Card gradient: Subtle adaptive background gradient
    static let card = LinearGradient(
        colors: [Color.cardBackground, Color.surfaceBackground],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Mood gradient: Adaptive mood colors
    static let mood = LinearGradient(
        colors: [Color.moodGreat, Color.moodGood],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Background gradient: Main app background
    static let background = LinearGradient(
        colors: [Color.mainBackground, Color.surfaceBackground],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Soft background (alias for compatibility)
    static let softBackground = background
}
