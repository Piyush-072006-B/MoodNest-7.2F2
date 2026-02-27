import Foundation
import UserNotifications

// MARK: - Notification Manager

@MainActor
final class NotificationManager: ObservableObject {
    private static let isPreview: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    private let notificationIdentifier = "moodnest.daily.checkin"
    
    private init() {
        guard !Self.isPreview else { return }
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        guard !Self.isPreview else { return false }
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        
        switch settings.authorizationStatus {
        case .notDetermined:
            do {
                let granted = try await UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .sound, .badge])
                isAuthorized = granted
                return granted
            } catch {
                isAuthorized = false
                return false
            }
        case .denied:
            isAuthorized = false
            return false
        case .authorized, .provisional, .ephemeral:
            isAuthorized = true
            return true
        @unknown default:
            return false
        }
    }
    
    func checkAuthorizationStatus() async {
        guard !Self.isPreview else { return }
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }
    
    // MARK: - Scheduling
    
    func scheduleDailyReminder(hour: Int, minute: Int) async {
        guard !Self.isPreview else { return }
        // 1) Remove any existing pending request with same ID
        cancelDailyReminder()
        
        // 2) Request authorization if needed
        let granted = await requestAuthorization()
        guard granted else { return }
        
        // 3) Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Daily Check-In"
        content.body = "How are you feeling today? Don't forget to check in 💙"
        content.sound = .default
        
        // 4) Create repeating calendar trigger
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // 5) Create & add request
        let request = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch { }
    }
    
    func cancelDailyReminder() {
        guard !Self.isPreview else { return }
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
    }
    
    // MARK: - Launch Re-registration
    
    /// Call on app launch to re-schedule if reminder is enabled
    func reRegisterIfNeeded() async {
        guard !Self.isPreview else { return }
        let enabled = UserDefaults.standard.bool(forKey: "moodnest_reminderEnabled")
        guard enabled else { return }
        
        let hour = UserDefaults.standard.integer(forKey: "moodnest_reminderHour")
        let minute = UserDefaults.standard.integer(forKey: "moodnest_reminderMinute")
        
        // Default hour 9 if never set
        let safeHour = (hour == 0 && minute == 0 && !UserDefaults.standard.bool(forKey: "moodnest_reminderTimeSet")) ? 9 : hour
        
        await scheduleDailyReminder(hour: safeHour, minute: minute)
    }
    
    // MARK: - Helper
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        guard !Self.isPreview else { return [] }
        return await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
}
