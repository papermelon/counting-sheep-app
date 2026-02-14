//
//  NotificationScheduler.swift
//  Counting Sheep
//
//  Created by Ngawang Chime on 5/1/26.
//

import Foundation
import UserNotifications

enum NotificationScheduler {
    
    static func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    static func scheduleBedtimeAndMorning(
        bedtimeStart: Date,
        bedtimeEnd: Date,
        enabled: Bool
    ) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        guard enabled else { return }
        
        // Bedtime reminder
        let bedtimeContent = UNMutableNotificationContent()
        bedtimeContent.title = "Sheep are heading out to graze"
        bedtimeContent.body = "Wind down now to earn more stars in the morning."
        bedtimeContent.sound = .default
        
        if let bedtimeTrigger = calendarTrigger(for: bedtimeStart) {
            let request = UNNotificationRequest(
                identifier: "bedtime-reminder",
                content: bedtimeContent,
                trigger: bedtimeTrigger
            )
            center.add(request)
        }
        
        // Morning check-in reminder
        let morningContent = UNMutableNotificationContent()
        morningContent.title = "Your sheep have returned!"
        morningContent.body = "Open Counting Sheep to see how they did overnight."
        morningContent.sound = .default
        
        if let morningTrigger = calendarTrigger(for: bedtimeEnd) {
            let request = UNNotificationRequest(
                identifier: "morning-reminder",
                content: morningContent,
                trigger: morningTrigger
            )
            center.add(request)
        }
    }
    
    private static func calendarTrigger(for date: Date) -> UNCalendarNotificationTrigger? {
        var components = Calendar.current.dateComponents([.hour, .minute], from: date)
        components.second = 0
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
    }
}

