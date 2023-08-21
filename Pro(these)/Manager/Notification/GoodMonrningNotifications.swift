//
//  GoodMonrningNotifications.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 14.08.23.
//

import SwiftUI

class GoodMonrningNotifications {
    static var shared = GoodMonrningNotifications()
    
    var notifications: [NotificationByDate] {
        return [
            
            NotificationByDate(
                identifier: "PROTHESE_MOOD_GOOD_MORNING_1",
                title: LocalizedStringKey("Start the day well 🦾 🦾").localizedstring(), // -> Starte gut in den Tag 🦾 🦾
                body: LocalizedStringKey("Think of your prosthesis diary and behave in your time. ✌️").localizedstring(),
                triggerHour: Calendar.current.component(.hour, from: AppConfig.shared.PushNotificationGoodMorningDate),
                triggerMinute: Calendar.current.component(.minute, from: AppConfig.shared.PushNotificationGoodMorningDate),
                repeater: true,
                url: ""
            ),
            
            NotificationByDate(
                identifier: "PROTHESE_MOOD_GOOD_MORNING_2",
                title: LocalizedStringKey("A little Motivation for a great day 🦾 🦾").localizedstring(), // -> Eine kleine Motivation für einen tollen Tag 🦾 🦾
                body: LocalizedStringKey("Happiness is not a goal. Happiness is a way of life. Be happy today and share it with us... ✌️").localizedstring(),
                triggerHour: Calendar.current.component(.hour, from: AppConfig.shared.PushNotificationGoodMorningDate),
                triggerMinute: Calendar.current.component(.minute, from: AppConfig.shared.PushNotificationGoodMorningDate),
                repeater: true,
                url: "",
                userInfo: ["Tab" : Tab.feeling.rawValue]
            ),
            
            NotificationByDate(
                identifier: "PROTHESE_MOOD_GOOD_MORNING_3", //
                title: LocalizedStringKey("Have a good morning 😃").localizedstring(),
                body: LocalizedStringKey("Don't go where the path may lead you, go where there is no path and write down your notes. ✌️").localizedstring(),
                triggerHour: Calendar.current.component(.hour, from: AppConfig.shared.PushNotificationGoodMorningDate),
                triggerMinute: Calendar.current.component(.minute, from: AppConfig.shared.PushNotificationGoodMorningDate),
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
    
    var count: Int {
        let c = self.notifications.count
        return c == 0 ? 0 : self.notifications.count - 1
    }
}
