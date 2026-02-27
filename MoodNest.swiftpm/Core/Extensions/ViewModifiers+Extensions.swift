import SwiftUI

// MARK: - Text Style Extensions

extension Text {
    /// Large title style for headers
    func titleStyle() -> some View {
        self
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.textPrimary)
    }
    
    /// Section header style
    func sectionHeaderStyle() -> some View {
        self
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.textPrimary)
    }
    
    /// Body text style
    func bodyStyle() -> some View {
        self
            .font(.system(size: 16))
            .foregroundColor(.textPrimary)
    }
    
    /// Secondary text style for subtitles
    func subtitleStyle() -> some View {
        self
            .font(.system(size: 14))
            .foregroundColor(.textSecondary)
    }
    
    /// Caption style for small text
    func captionStyle() -> some View {
        self
            .font(.system(size: 12))
            .foregroundColor(.textTertiary)
    }
}

// MARK: - View Style Extensions

extension View {
    /// Standard card styling
    func cardStyle() -> some View {
        self
            .background(Color.cardBackground)
            .cornerRadius(12)
            .shadow(color: Color.shadowColor, radius: 4, x: 0, y: 2)
    }
    
    /// Glass morphism card effect
    func glassCardStyle() -> some View {
        self
            .background(Color.cardBackground.opacity(0.8))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.glassBorder, lineWidth: 1)
            )
            .shadow(color: Color.shadowColor, radius: 8, x: 0, y: 4)
    }
    
    /// Standard padding for content
    func contentPadding() -> some View {
        self.padding(20)
    }
    
    /// Small padding for compact layouts
    func compactPadding() -> some View {
        self.padding(12)
    }
}

// MARK: - Button Style Extensions

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [Color.primaryAction, Color.primaryAccent],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.primaryAccent)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.primaryAccent.opacity(0.1))
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Common Modifiers

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Color.cardBackground)
            .cornerRadius(12)
            .shadow(color: Color.shadowColor, radius: 4, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.border.opacity(0.2), lineWidth: 1)
            )
    }
}

extension View {
    func asCard() -> some View {
        modifier(CardModifier())
    }

    /// Disables scroll bounce on iOS 16.4+; no-ops on earlier versions.
    @ViewBuilder
    func noScrollBounce() -> some View {
        if #available(iOS 16.4, *) {
            self.scrollBounceBehavior(.basedOnSize)
        } else {
            self
        }
    }
}
