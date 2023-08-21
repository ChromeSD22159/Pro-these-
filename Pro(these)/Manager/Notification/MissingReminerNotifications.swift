//
//  MissingReminerNotifications.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 15.08.23.
//

import SwiftUI

class MissingReminerNotifications {
    static var shared = MissingReminerNotifications()
    
    private var notifications: [NotificationByTimer] {
        return [
            NotificationByTimer(
                identifier: "PROTHESE_MISSING_REMINDER",
                title: AppConfig().username.isEmpty ? String(format: NSLocalizedString("Good morning out there! 👋", comment: "")) :  String(format: NSLocalizedString("Good morning, %@! 👋", comment: ""), AppConfig().username),
                body: LocalizedStringKey("You didn't even stop by yesterday. Just get back into your plan today.").localizedstring(),
                triggerTimer: Int.random(in: (10*60)...(120*60)), // between 10 min - 2h
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
    
    private var count: Int {
        let c = self.notifications.count
        return c == 0 ? 0 : self.notifications.count - 1
    }
}
