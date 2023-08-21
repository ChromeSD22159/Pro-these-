//
//  MoodReminderNotifications.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 14.08.23.
//

import SwiftUI

class MoodReminderNotifications {
    static var shared = MoodReminderNotifications()
    
    private var notifications: [NotificationByDate] {
        return [
            
            NotificationByDate(
                identifier: "PROTHESE_MOOD_REMINDER_DAILY_1",
                title: LocalizedStringKey("Pro Prothese").localizedstring(),
                body: LocalizedStringKey("Hey! How are you feeling today? ✌️").localizedstring(),
                triggerHour: Calendar.current.component(.hour, from: AppConfig.shared.PushNotificationDailyMoodRememberingDate),
                triggerMinute: Calendar.current.component(.minute, from: AppConfig.shared.PushNotificationDailyMoodRememberingDate),
                repeater: true,
                url: "",
                userInfo: ["Tab" : Tab.feeling.rawValue]
            ),
            
            NotificationByDate(
                identifier: "PROTHESE_MOOD_REMINDER_DAILY_2",
                title: LocalizedStringKey("Pro Prothese").localizedstring(),
                body: LocalizedStringKey("Hey! A new day, new experiences, don't you want to save them? ✌️").localizedstring(),
                triggerHour: Calendar.current.component(.hour, from: AppConfig.shared.PushNotificationDailyMoodRememberingDate),
                triggerMinute: Calendar.current.component(.minute, from: AppConfig.shared.PushNotificationDailyMoodRememberingDate),
                repeater: true,
                url: "",
                userInfo: ["Tab" : Tab.feeling.rawValue]
            ),
            
            NotificationByDate(
                identifier: "PROTHESE_MOOD_REMINDER_DAILY_3",
                title: LocalizedStringKey("Tell me about your day 🦾 🦾").localizedstring(),
                body: LocalizedStringKey("Don't leave a blank page in your prosthesis diary. ✌️").localizedstring(),
                triggerHour: Calendar.current.component(.hour, from: AppConfig.shared.PushNotificationDailyMoodRememberingDate),
                triggerMinute: Calendar.current.component(.minute, from: AppConfig.shared.PushNotificationDailyMoodRememberingDate),
                repeater: true,
                url: "",
                userInfo: ["Tab" : Tab.feeling.rawValue]
            ),
        
        ]
    }
    
    var randomNotification: NotificationByDate {
        let index = self.count
        let randomIndex = Int.random(in: 0...index)
        return notifications[randomIndex]
    }
    
    private var count: Int {
        let c = self.notifications.count
        return c == 0 ? 0 : self.notifications.count - 1
    }
}
