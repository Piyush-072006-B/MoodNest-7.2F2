import SwiftUI

enum TabItem: String, CaseIterable {
    case home = "Home"
    case awareness = "Library"
    case focus = "Focus"
    case calendar = "Calendar"
    case stories = "Voices"
    case profile = "You"
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .awareness: return "lightbulb.fill"
        case .focus: return "wind"
        case .calendar: return "calendar"
        case .stories: return "quote.bubble.fill"
        case .profile: return "person.fill"
        }
    }
    
    var color: Color {
        // Teal/Aqua theme colors
        switch self {
        case .home: return .cyanBlue
        case .awareness: return .softAqua
        case .focus: return .deepTeal
        case .calendar: return .deepTeal
        case .stories: return .moodLavender
        case .profile: return .cyanBlue
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: TabItem
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                FloatingTabButton(
                    tab: tab,
                    isSelected: selectedTab == tab
                ) {
                    HapticManager.light()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            ZStack {
                // Glassmorphism background
                if colorScheme == .dark {
                    Color.black.opacity(0.6)
                } else {
                    Color.white.opacity(0.7)
                }
                
                // Blur effect
                Rectangle()
                    .fill(.ultraThinMaterial)
            }
        )
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.5 : 0.15), radius: 10, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(colorScheme == .dark ? 0.2 : 0.5),
                            Color.white.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

struct FloatingTabButton: View {
    let tab: TabItem
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    // Selection indicator background
                    if isSelected {
                        Circle()
                            .fill(tab.color.opacity(0.15))
                            .frame(width: 50, height: 50)
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Icon
                    Image(systemName: tab.icon)
                        .font(.system(size: isSelected ? 24 : 22, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(
                            isSelected
                                ? LinearGradient(
                                    colors: [tab.color, tab.color.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .scaleEffect(isSelected ? 1.15 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                }
                
                // Label
                Text(tab.rawValue)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? tab.color : Color.gray.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    ZStack {
        Color.lightSky.ignoresSafeArea()
        
        VStack {
            Spacer()
            CustomTabBar(selectedTab: .constant(.home))
        }
    }
}
