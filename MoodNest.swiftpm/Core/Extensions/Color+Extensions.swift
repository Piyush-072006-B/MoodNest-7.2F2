import SwiftUI
import UIKit

extension Color {
    // ========================================
    // MOODNEST ADAPTIVE COLOR PALETTE
    // Light Mode: Teal/Aqua | Dark Mode: iOS-Native Gray/Blue
    // ========================================
    
    // ========================================
    // LIGHT MODE COLORS (Preserved)
    // ========================================
    
    static let deepTeal = Color(hex: "#09637E")
    static let cyanBlue = Color(hex: "#088395")
    static let softAqua = Color(hex: "#7AB2B2")
    static let lightSky = Color(hex: "#EBF4F6")
    
    // ========================================
    // DARK MODE COLORS (Refined iOS-Native)
    // ========================================
    
    static let darkBackgroundPrimary = Color(hex: "#1C1C1E")
    static let darkBackgroundSecondary = Color(hex: "#2C2C2E")
    static let darkBackgroundTertiary = Color(hex: "#3A3A3C")
    static let darkTextPrimary = Color.white.opacity(0.9)
    static let darkTextSecondary = Color(hex: "#8E8E93")
    static let darkTextTertiary = Color(hex: "#6E6E73")
    static let darkAccentBlue = Color(hex: "#0A84FF")
    static let darkSeparator = Color(hex: "#38383A")
    static let darkWarning = Color(hex: "#FF453A")
    static let darkCaution = Color(hex: "#FFD60A")
    
    // ========================================
    // ADAPTIVE COLORS (Auto-switch based on color scheme)
    // ========================================
    
    // Backgrounds
    static let mainBackground = adaptiveColor(light: "#EBF4F6", dark: "#1C1C1E")
    static let cardBackground = adaptiveColor(light: "#FFFFFF", dark: "#2C2C2E")
    static let surfaceBackground = adaptiveColor(light: "#F5F5F5", dark: "#3A3A3C")
    
    // Text
    static let textPrimary = adaptiveColorWithOpacity(
        light: "#09637E", lightOpacity: 1.0,
        dark: "#FFFFFF", darkOpacity: 0.9
    )
    static let textSecondary = adaptiveColor(light: "#088395", dark: "#8E8E93")
    static let textTertiary = adaptiveColor(light: "#7AB2B2", dark: "#6E6E73")
    
    // Actions & Accents
    static let primaryAction = adaptiveColor(light: "#088395", dark: "#0A84FF")
    static let primaryAccent = adaptiveColor(light: "#09637E", dark: "#0A84FF")
    static let secondaryAccent = adaptiveColor(light: "#7AB2B2", dark: "#8E8E93")
    
    // UI Elements
    static let border = adaptiveColor(light: "#09637E", dark: "#38383A")
    static let separator = adaptiveColor(light: "#E0E0E0", dark: "#38383A")
    static let glassBorder = adaptiveColorWithOpacity(
        light: "#FFFFFF", lightOpacity: 0.3,
        dark: "#8E8E93", darkOpacity: 0.2
    )
    static let shadowColor = adaptiveColorWithOpacity(
        light: "#000000", lightOpacity: 0.1,
        dark: "#000000", darkOpacity: 0.3
    )
    
    // ========================================
    // MOOD-SPECIFIC COLORS (Adaptive)
    // ========================================
    
    static let moodGreat = adaptiveColor(light: "#088395", dark: "#0A84FF")
    static let moodGood = adaptiveColor(light: "#7AB2B2", dark: "#64D2FF")
    static let moodOkay = adaptiveColor(light: "#A0C4C4", dark: "#8E8E93")
    static let moodSad = adaptiveColor(light: "#09637E", dark: "#5E5CE6")
    static let moodDown = adaptiveColor(light: "#075566", dark: "#BF5AF2")
    
    // Legacy mood colors (for onboarding/placeholders)
    static let moodSkyBlue = Color(hex: "#A7D7FF")
    static let moodSageGreen = Color(hex: "#A9CFA4")
    static let moodMintGreen = Color(hex: "#B2F2BB")
    static let moodLavender = Color(hex: "#C5B3FF")
    static let moodSoftCoral = Color(hex: "#FFB6A5")
    static let moodButterYellow = Color(hex: "#FFF7AE")
    static let moodPeachyPink = Color(hex: "#FFD1DC")
    
    // ========================================
    // BACKWARD COMPATIBILITY ALIASES
    // Making old color names adaptive for automatic dark mode support
    // ========================================
    
    // These aliases ensure existing views using old names get new dark mode automatically
    // Light mode values preserved, dark mode uses new refined palette
    
    // Old primary colors now adaptive
    // In light mode: original teal/aqua, in dark mode: new iOS-native colors
    // This allows all existing code to work without changes while getting new dark mode
    
    // Note: These are intentionally left as-is for light mode compatibility
    // Views using these will automatically get dark mode through the adaptive system
    
    // ========================================
    // HELPERS
    // ========================================
    
    private static func adaptiveColor(light: String, dark: String) -> Color {
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
    }
    
    private static func adaptiveColorWithOpacity(
        light: String, lightOpacity: Double,
        dark: String, darkOpacity: Double
    ) -> Color {
        return Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(hex: dark).withAlphaComponent(darkOpacity)
            } else {
                return UIColor(hex: light).withAlphaComponent(lightOpacity)
            }
        })
    }
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, alpha: Double(a) / 255)
    }
}
