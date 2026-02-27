import SwiftUI

// Glassmorphism card modifier
struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var borderWidth: CGFloat = 1
    var borderColor: Color = Color.glassBorder
    var shadowRadius: CGFloat = 10
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.softAqua.opacity(0.1))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(borderColor, lineWidth: borderWidth)
            )
            .shadow(color: Color.shadowColor, radius: shadowRadius, x: 0, y: 4)
    }
}

// Thick border card modifier (matching reference design with teal theme)
struct ThickBorderCardModifier: ViewModifier {
    var backgroundColor: Color
    var borderColor: Color = Color.deepTeal
    var cornerRadius: CGFloat = 24
    var borderWidth: CGFloat = 3
    var shadowRadius: CGFloat = 8
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(borderColor, lineWidth: borderWidth)
            )
            .shadow(color: Color.shadowColor, radius: shadowRadius, x: 0, y: 4)
    }
}

// Pill button modifier (matching reference design with teal theme)
struct PillButtonModifier: ViewModifier {
    var backgroundColor: Color
    var borderColor: Color = Color.deepTeal
    var isSelected: Bool = false
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(isSelected ? backgroundColor : backgroundColor.opacity(0.3))
            )
            .overlay(
                Capsule()
                    .strokeBorder(borderColor, lineWidth: isSelected ? 4 : 3)
            )
    }
}

extension View {
    func glassCard(
        cornerRadius: CGFloat = 20,
        borderWidth: CGFloat = 1,
        borderColor: Color = Color.glassBorder,
        shadowRadius: CGFloat = 10
    ) -> some View {
        modifier(GlassCardModifier(
            cornerRadius: cornerRadius,
            borderWidth: borderWidth,
            borderColor: borderColor,
            shadowRadius: shadowRadius
        ))
    }
    
    func thickBorderCard(
        backgroundColor: Color,
        borderColor: Color = Color.deepTeal,
        cornerRadius: CGFloat = 24,
        borderWidth: CGFloat = 3,
        shadowRadius: CGFloat = 8
    ) -> some View {
        modifier(ThickBorderCardModifier(
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            cornerRadius: cornerRadius,
            borderWidth: borderWidth,
            shadowRadius: shadowRadius
        ))
    }
    
    func pillButton(
        backgroundColor: Color,
        borderColor: Color = Color.deepTeal,
        isSelected: Bool = false
    ) -> some View {
        modifier(PillButtonModifier(
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            isSelected: isSelected
        ))
    }
}

#Preview {
    ZStack {
        Color.lightSky
        
        VStack(spacing: 20) {
            Text("Glassmorphism Card")
                .foregroundColor(.deepTeal)
                .padding(40)
                .glassCard()
            
            Text("Thick Border Card")
                .foregroundColor(.deepTeal)
                .padding(40)
                .thickBorderCard(backgroundColor: .softAqua.opacity(0.3))
            
            HStack(spacing: 12) {
                Text("8:30")
                    .foregroundColor(.deepTeal)
                    .pillButton(backgroundColor: .softAqua, isSelected: false)
                
                Text("9:30")
                    .foregroundColor(.white)
                    .pillButton(backgroundColor: .cyanBlue, isSelected: true)
            }
        }
        .padding()
    }
}
