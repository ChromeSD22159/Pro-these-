//
//  PushNotificationManager.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 24.04.23.
//

import SwiftUI
import UserNotifications

class PushNotificationManager : ObservableObject {
    
    var PushNotification = PushNotifications()
    
    var pendingNotification: [String] = []
    
    init(){
        if !AppConfig().PushNotificationDisable {
            setUpDailyNotifications()
        }
    }
    
    
    /// Register Push Notification and ask for Authorizarion.
    func registerForPushNotifications(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
               // print("Notification Authorization successful")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    /// Write the Notification Settings into the debug console.
    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
      }
    }
    
    /// Remove Notifications when the App appear or change in foreground.
    ///
    /// Important
    /// The func is fired as soon as the scene is in the foreground and when the app is started.
    ///
    /// ```swift
    ///   .onChange(of: scenePhase) { newPhase in
    ///       if newPhase == .active {  // APP is in Foreground / Active
    ///         pushNotificationManager.removeNotifications()
    ///       } else if newPhase == .inactive { // // APP changed to Inactive
    ///         pushNotificationManager.setUpNotifications()
    ///    } else if newPhase == .background { // APP changed to Background
    ///         print("APP changed to Background")
    ///    }
    /// ```
    func removeNotificationsWhenAppLoads(){
        removeNotification(identifier: "PROTHESE_COMEBACK_REMINDER1")
        removeNotification(identifier: "PROTHESE_COMEBACK_REMINDER2")
    }
    
    func setUpDailyNotifications(){
        if AppConfig().PushNotificationDailyMoodRemembering {
            PushNotificationByDate(
                identifier:     PushNotification.MoodReminder["identifier"]!,
                title:          PushNotification.MoodReminder["titel"]!,
                body:           PushNotification.MoodReminder["body"]!,
                triggerHour:    Int(PushNotification.MoodReminder["triggerHour"]!)!,
                triggerMinute:  Int(PushNotification.MoodReminder["triggerMinute"]!)!,
                repeater:       Bool(PushNotification.MoodReminder["repeater"]!) ?? false,
                url:            PushNotification.MoodReminder["url"]!
            )
        }

        if AppConfig().PushNotificationGoodMorning {
            PushNotificationByDate(
                identifier:     PushNotification.GoodMorning["identifier"]!,
                title:          PushNotification.GoodMorning["titel"]!,
                body:           PushNotification.GoodMorning["body"]!,
                triggerHour:    Int(PushNotification.GoodMorning["triggerHour"]!)!,
                triggerMinute:  Int(PushNotification.GoodMorning["triggerMinute"]!)!,
                repeater:       Bool(PushNotification.GoodMorning["repeater"]!) ?? false,
                url:            PushNotification.GoodMorning["url"]!
            )
        }
    }
    
    /// Set Notifications new Notifications when the App getting starting or change to foreground.
    ///
    /// Important
    /// The func is fired as soon as the scene is in the foreground and when the app is started.
    ///
    func setUpNonPermanentNotifications() {
        // Random Time between 2-4hours
        let random = Int.random(in: 7200..<14400)
        //let random = Int.random(in: 10...20)
        let randomNotification = Int.random(in: 1...2)
        if randomNotification == 1 {
            let comeback = PushNotification.ComeBack1
            PushNotificationByTimer(
                identifier: comeback["identifier"]!,
                title: comeback["titel"]!,
                body: comeback["body"]!,
                triggerTimer: random,
                url: comeback["url"]!
            )
        }
        
        if randomNotification == 2 {
            let comeback = PushNotification.ComeBack2
            PushNotificationByTimer(
                identifier: comeback["identifier"]!,
                title: comeback["titel"]!,
                body: comeback["body"]!,
                triggerTimer: random,
                url: comeback["url"]!
            )
        }
        
        
    }
    
    /// Setup a new Notification with an Timer Trigger
    ///
    /// - Parameter identifier:    (String)     - Set Notification Identifier - To search for it or delele
    /// - Parameter title:         (String)     - Set Notification Headline (String)
    /// - Parameter body:          (String)     - Set Notification Body Text (String)
    /// - Parameter triggerTimer:  (String)     - Set Notification Timer (Int) in seconds after trigger/ register the Notification
    func PushNotificationByTimer(identifier: String, title: String, body: String, triggerTimer: Int, url: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(triggerTimer), repeats: false)
        // choose a random identifier
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
        
        
        if let url = URL(string: url) {
            // Ask the system to open that URL.
            UIApplication.shared.open(url)
        }
        
        print("Register Notification:  \(identifier)")
    }
    
    /// Setup a new Notification with an Date Trigger
    ///
    /// - Parameter identifier:    (String)     - Set Notification Identifier - To search for it or delele
    /// - Parameter title:         (String)     - Set Notification Headline (String)
    /// - Parameter body:          (String)     - Set Notification Body Text (String)
    /// - Parameter triggerTimer:  (String)     - Set Notification Timer (Int) in seconds after trigger/ register the Notification
    func PushNotificationByDate(identifier: String, title: String, body: String, triggerHour: Int, triggerMinute: Int, repeater: Bool, url: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        var date = DateComponents()
        date.hour = triggerHour
        date.minute = triggerMinute
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: repeater)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
        
        if let url = URL(string: url) {
            // Ask the system to open that URL.
            UIApplication.shared.open(url)
        }
        
        print("Register Notification:  \(identifier)")
    }
    
    func PushNotificationByAddEvent(identifier: String, title: String, body: String, triggerDate: Date, repeater: Bool) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        //let comps = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
        print("input: \(triggerDate)")
        let nextTriggerDate = Calendar.current.date(byAdding: .day, value: -3, to: triggerDate)!
        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: nextTriggerDate)
        print("trigger: \(comps)")
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: repeater)

        if Calendar.current.date(byAdding: .day, value: 3, to: Date())! > Calendar.current.date(byAdding: .day, value: -3, to: triggerDate)! {
            // choose a random identifier
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            // add our notification request
            UNUserNotificationCenter.current().add(request)
            
            print("Register Notification:  \(identifier) für: \(trigger)")
        }
       
    }
    
    func PushNotificationByAddEvent2(identifier: String, title: String, body: String, triggerDate: Date, repeater: Bool) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        //let comps = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
        print("input: \(triggerDate)")
        
        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        print("trigger: \(comps)")
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: repeater)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
    }
    
    
    
    func PushNotificationRepeater(identifier: String, title: String, body: String, interval: Double){
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) {
            (error: Error?) in
        }
        
        print("Register Notification:  \(identifier) für: \(trigger)")
    }
    
    // MARK: Remove all pending Notifications
    func removeAllPendingNotificationRequests(){
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: Remove an registered Notification by the identifier
    func removeNotification(identifier: String){
        let strIdentifier = identifier
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(strIdentifier)"])
        print("Removed Notification:  \(identifier)")
    }
    
    // MARK: Print all Array for all Registered Notifications
    func getAllNotifications() {
        UNUserNotificationCenter.current().getDeliveredNotifications { (notifications) in
            for notification:UNNotification in notifications {
                print(notification.request.content)
                print(notification.request.identifier)
            }
        }
    }
    
    // MARK: Returns an Array for all Pending Notifications
    func getAllPendingNotifications() -> [String] {
        let center = UNUserNotificationCenter.current()
        var note: [String] = []
        
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                note.append(request.identifier)
                print("Pending Notification: \(request.identifier)")
            }
        })
        return note
    }
    
    
    
    
    
    
    
    // MARK: TEST
    func schedule(title: String, subtitle: String, body: String, hour: Int, minute: Int, identifier: Int, repeatX: Bool){
        let content = UNMutableNotificationContent()
        
        let strIdentifier = "FK_PROTHESE_\(identifier)"
        
        content.title = title
        if subtitle != "" {
            content.subtitle = subtitle
        }
        content.subtitle = body
        content.sound = UNNotificationSound.default

        var date = DateComponents()
        date.hour = hour
        date.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: repeatX)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: strIdentifier, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
    }
    
    func testSchedule(title: String, subtitle: String, body:String, sec: String, repeatX: Bool){
        let content = UNMutableNotificationContent()
        
        let strIdentifier = UUID().uuidString
        
        if title != "" {
            content.title = title
        }
        if subtitle != "" {
            content.subtitle = subtitle
        }
        if body != "" {
            content.body = body
        }
        
       
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(Int(sec)!), repeats: repeatX)


        // choose a random identifier
        let request = UNNotificationRequest(identifier: strIdentifier, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
      
    }
    
   
}


class Random {
//   Random().int(between: 1, and: 10)
    func int(between: Int, and: Int) -> Int {
      return Int.random(in: between...and)
    }

    func double(between: Double, and: Double) -> Double {
      return Double.random(in: between...and)
    }
}

    
    
