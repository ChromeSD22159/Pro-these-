//
//  ComebackReminderNotifications.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 14.08.23.
//

import SwiftUI

class ComebackReminderNotifications {
    static var shared = ComebackReminderNotifications()
    
    var notifications: [NotificationByTimer] {
        return [

            NotificationByTimer(
                identifier: "PROTHESE_COMEBACK_REMINDER_1",
                title: LocalizedStringKey("We haven't seen you today 😢").localizedstring(),
                body: LocalizedStringKey("Come back soon, it will be exciting ✌️").localizedstring(),
                triggerTimer: 10,
                url: "",
                userInfo: ["Tab" : Tab.home.rawValue]
            ),
            
            NotificationByTimer(
                identifier: "PROTHESE_COMEBACK_REMINDER_2",
                title: LocalizedStringKey("How are you doing? 🤔").localizedstring(),
                body: LocalizedStringKey("It's so quiet here without you...😢").localizedstring(),
                triggerTimer: 10,
                url: "",
                userInfo: ["Tab" : Tab.home.rawValue]
            )
        
        ]
    }
    
    var randomNotification: NotificationByTimer {
        let index = self.count
        let randomIndex = Int.random(in: 0...index)
        return notifications[randomIndex]
    }
    
    var count: Int {
        let c = self.notifications.count
        return c == 0 ? 0 : self.notifications.count - 1
    }
}
