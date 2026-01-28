import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                continuation.resume(returning: granted)
            }
        }
    }

    func scheduleNextNotification(quote: Quote, minutesAfterMidnight: Int) {
        let nextDate = nextTriggerDate(minutesAfterMidnight: minutesAfterMidnight)
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: nextDate)

        let content = UNMutableNotificationContent()
        content.title = "Daily Motivation"
        content.body = "\"\(quote.text)\" - \(quote.author)"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "dailyQuote", content: content, trigger: trigger)

        center.removePendingNotificationRequests(withIdentifiers: ["dailyQuote"])
        center.add(request)
    }

    func cancelNotifications() {
        center.removePendingNotificationRequests(withIdentifiers: ["dailyQuote"])
    }

    private func nextTriggerDate(minutesAfterMidnight: Int) -> Date {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let scheduled = calendar.date(byAdding: .minute, value: minutesAfterMidnight, to: today) ?? Date()
        if scheduled > Date() {
            return scheduled
        }
        return calendar.date(byAdding: .day, value: 1, to: scheduled) ?? scheduled
    }
}

