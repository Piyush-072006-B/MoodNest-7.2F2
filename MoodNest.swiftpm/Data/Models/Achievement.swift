import Foundation

// MARK: - Achievement Model

/// Achievement model
struct Achievement: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let icon: String
    
    // MARK: - Achievement Definitions
    
    // Journal achievements
    static let firstJournal = Achievement(
        id: "first_journal",
        title: "First Entry",
        description: "Started your journaling journey",
        icon: "pencil.circle.fill"
    )
    
    static let journal5 = Achievement(
        id: "journal_5",
        title: "Reflective Writer",
        description: "Wrote 5 journal entries",
        icon: "book.circle.fill"
    )
    
    static let journal10 = Achievement(
        id: "journal_10",
        title: "Dedicated Journaler",
        description: "Wrote 10 journal entries",
        icon: "books.vertical.circle.fill"
    )
    
    static let journal25 = Achievement(
        id: "journal_25",
        title: "Master Journaler",
        description: "Wrote 25 journal entries",
        icon: "text.book.closed.fill"
    )
    
    // Gratitude achievements
    static let firstGratitude = Achievement(
        id: "first_gratitude",
        title: "Grateful Heart",
        description: "Shared your first gratitude",
        icon: "heart.circle.fill"
    )
    
    static let gratitude5 = Achievement(
        id: "gratitude_5",
        title: "Thankful Soul",
        description: "Shared 5 gratitudes",
        icon: "star.circle.fill"
    )
    
    static let gratitude10 = Achievement(
        id: "gratitude_10",
        title: "Gratitude Master",
        description: "Shared 10 gratitudes",
        icon: "sparkles"
    )
    
    // Streak achievements
    static let streak3 = Achievement(
        id: "streak_3",
        title: "Building Momentum",
        description: "3-day check-in streak",
        icon: "flame.fill"
    )
    
    static let streak7 = Achievement(
        id: "streak_7",
        title: "Week Warrior",
        description: "7-day check-in streak",
        icon: "flame.circle.fill"
    )
    
    static let streak30 = Achievement(
        id: "streak_30",
        title: "Consistency Champion",
        description: "30-day check-in streak",
        icon: "crown.fill"
    )
    
    static let allAchievements: [Achievement] = [
        firstJournal, journal5, journal10, journal25,
        firstGratitude, gratitude5, gratitude10,
        streak3, streak7, streak30
    ]
}
