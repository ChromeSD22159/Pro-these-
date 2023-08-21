//
//  ReportNotifications.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 14.08.23.
//

import SwiftUI

class ReportNotification {
    static var shared = ReportNotification()
    
    var notifications: [NotificationByTimer] {
        return [
            
            NotificationByTimer(
                identifier: "NEW_REPORT_AVAIBLE",
                title: LocalizedStringKey("Your weekly progress is available").localizedstring(),
                body: LocalizedStringKey("The summary of your current progress for the last week is now available.").localizedstring(),
                triggerTimer: 10,
                url: "",
                userInfo: ["Tab" : Tab.home.rawValue]
            ),
            
            NotificationByTimer(
                identifier: "NEW_REPORT_AVAIBLE",
                title: LocalizedStringKey("Your personal weekly report").localizedstring(),
                body: LocalizedStringKey("Find out how your last week was. 💪").localizedstring(),
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
