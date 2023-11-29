//
//  AppRemoveNotifications.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 13.08.23.
//

import SwiftUI

enum AppRemoveNotifications {
    
    @AppStorage("PushNotificationDailyMoodRemembering") static var PushNotificationDailyMoodRemembering = true
    
    @AppStorage("PushNotificationGoodMorning") static var PushNotificationGoodMorning = true
    
    @AppStorage("PushNotificationComebackReminder") static var PushNotificationComebackReminder = true
    
    static func removeNotifications(keyworks: [String], notes: [UNNotificationRequest]) {
        for keyword in keyworks {
            let note = notes.filter({  $0.identifier.contains(keyword)  })
          
            if note.count > 0 {
                let _ = note.map {
                    PushNotificationManager().removeNotification(identifier: $0.identifier)
                }
            }
            
        }
    }
    
    static func setMoodReminderNotifications(printConsole: Bool? = nil) {
        if PushNotificationDailyMoodRemembering {
            let note = MoodReminderNotifications.shared.randomNotification
            
            PushNotificationManager().PushNotificationByDate(
                identifier: note.identifier,
                title: note.title,
                body: note.body,
                triggerHour: note.triggerHour,
                triggerMinute: note.triggerMinute,
                repeater: note.repeater,
                url: note.url,
                printConsole: printConsole
            )
        }
    }
    
    static func setGoodMorningNotifications(printConsole: Bool? = nil) {
        if PushNotificationGoodMorning {
            let note = GoodMonrningNotifications.shared.randomNotification
            
            PushNotificationManager().PushNotificationByDate(
                identifier: note.identifier,
                title: note.title,
                body: note.body,
                triggerHour: note.triggerHour,
                triggerMinute: note.triggerMinute,
                repeater: note.repeater,
                url: note.url,
                printConsole: printConsole
            )
        }
    }
    
    static func setComebackNotifications(delay: Int, printConsole: Bool? = nil) {
        if PushNotificationComebackReminder {
            let targetTriggerDate = Calendar.current.date(byAdding: .second, value: delay, to: Date())!
            let startNotificationWindow = Calendar.current.date(bySetting: .hour, value: 8, of: Date())!
            let endNotificationWindow = Calendar.current.date(bySetting: .hour, value: 21, of: Date())!
            
            if Date.now > startNotificationWindow && targetTriggerDate < endNotificationWindow {
                let note = ComebackReminderNotifications.shared.randomNotification
                
                PushNotificationManager().PushNotificationByTimer(
                    identifier: note.identifier,
                    title: note.title,
                    body: note.body,
                    triggerTimer: delay,
                    url: note.url,
                    printConsole: printConsole
                )
                
                print("[AppRemoveNotifications] Next ComebackNotification: \(targetTriggerDate)")
            }  else {
                print("[AppRemoveNotifications] ComebackNotification not in date range")
            }
        }
    }
}
