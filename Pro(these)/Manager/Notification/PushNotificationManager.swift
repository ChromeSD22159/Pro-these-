//
//  PushNotificationManager.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 24.04.23.
//

import SwiftUI
import UserNotifications

class PushNotificationManager : ObservableObject {
    
    var pendingNotification: [String] = []
    
    var debugNotification: Bool = true
    
    var deviceLanguage: String {
        Bundle.main.preferredLocalizations.first!
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
    func removeNotificationsWhenAppLoads(debug: Bool){
        if debug {
            removeNotification(identifier: "PROTHESE_COMEBACK_REMINDER1")
            removeNotification(identifier: "PROTHESE_COMEBACK_REMINDER2")
            removeNotification(identifier: "PROTHESE_MOOD_GOOD_MORNING")
            
            for i in 1...3 {
                removeNotification(identifier: "PROTHESE_MOOD_GOOD_MORNING_\(i)")
            }
            
        }
    }

    /// Setup a new Notification with an Timer Trigger
    ///
    /// - Parameter identifier:    (String)     - Set Notification Identifier - To search for it or delele
    /// - Parameter title:         (String)     - Set Notification Headline (String)
    /// - Parameter body:          (String)     - Set Notification Body Text (String)
    /// - Parameter triggerTimer:  (String)     - Set Notification Timer (Int) in seconds after trigger/ register the Notification
    func PushNotificationByTimer(identifier: String, title: String, body: String, triggerTimer: Int, url: String, userInfo: [String:String]? = nil, printConsole: Bool? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        if userInfo != nil {
            content.userInfo = userInfo!
        } else {
            content.userInfo = ["Tab" : Tab.home.rawValue]
        }
      
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(triggerTimer), repeats: false)
        // choose a random identifier
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
        
        if printConsole ?? false {
            print("Register Notification:  \(identifier) - \(title) - \((triggerTimer))")
        }
        
    }
    
    
    func allowReminderByDate(triggerTimer: Int?, notificationStateBinding: String, complition: @escaping(Bool, Int?) -> Void) {
        @AppStorage(notificationStateBinding) var binding:Bool = true
        
        // IF trippertimer set
        if let tr = triggerTimer {
            let morning = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
            let evening = Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: Date())!
            
            let trigger = Calendar.current.date(byAdding: .second, value: tr, to: Date())
            
            if binding {
                trigger! > morning && trigger! < evening ? complition(true, tr) : complition(false, nil)
            } else {
                complition(false, nil)
            }
        } else {
            binding ? complition(true, nil) : complition(false, nil)
        }
    }
    
    /// Setup a new Notification with an Date Trigger
    ///
    /// - Parameter identifier:    (String)     - Set Notification Identifier - To search for it or delele
    /// - Parameter title:         (String)     - Set Notification Headline (String)
    /// - Parameter body:          (String)     - Set Notification Body Text (String)
    /// - Parameter triggerTimer:  (String)     - Set Notification Timer (Int) in seconds after trigger/ register the Notification
    func PushNotificationByDate(identifier: String, title: String, body: String, triggerHour: Int, triggerMinute: Int, repeater: Bool, url: String, userInfo: [String:String]? = nil, printConsole: Bool? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        if userInfo != nil {
            content.userInfo = userInfo!
        } else {
            content.userInfo = ["Tab" : Tab.home.rawValue]
        }
        
        var date = DateComponents()
        date.hour = triggerHour
        date.minute = triggerMinute
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: repeater)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
        
        if printConsole ?? false {
            print("Register Notification:  \(identifier) - \(title) - Trigger: \(trigger.dateComponents.hour!):\(trigger.dateComponents.minute!)")
        }
        
    }
    
    func PushNotificationByAddEvent(identifier: String, title: String, body: String, triggerDate: Date, repeater: Bool) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.userInfo = ["Tab" : Tab.event.rawValue]
        
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
            
            print("Register Notification:  \(identifier)  - \(title) für: \(trigger)")
        }
    }
    
    func PushNotificationByAddEvent2(identifier: String, title: String, body: String, triggerDate: Date, repeater: Bool) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.userInfo = ["Tab" : Tab.event.rawValue]
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
    
    func PushNotificationLiner(identifier: String, title: String, body: String, triggerDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.userInfo = ["Tab" : Tab.home.rawValue]
        //let comps = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
        print("input: \(triggerDate)")
        
        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        print("trigger: \(comps)")
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

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
        
        print("Register Notification:  \(identifier) - \(title) - Trigger: \(trigger.timeInterval)")
    }
    
    // MARK: Remove all pending Notifications
    func removeAllPendingNotificationRequests(){
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: Remove an registered Notification by the identifier
    func removeNotification(identifier: String, printConsole: Bool? = nil){
        let strIdentifier = identifier
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(strIdentifier)"])
        
        if printConsole ?? false {
            print("Removed Notification:  \(identifier)")
        }
    }
    
    // MARK: Print all Array for all Registered Notifications
    func getAllNotifications(debug: Bool) {
        UNUserNotificationCenter.current().getDeliveredNotifications { (notifications) in
            for notification:UNNotification in notifications {
                print(notification.request.content)
                print(notification.request.identifier)
                if debug == true {
                    print("Pending Notification: \(notification.request.identifier), Body: \(notification.request.content)")
                }
            }
        }
    }
    
    // MARK: Returns an Array for all Pending Notifications
    func getAllPendingNotifications(debug: Bool, completion: @escaping (UNNotificationRequest) -> Void) {
        let center = UNUserNotificationCenter.current()
        var note: [UNNotificationRequest] = []
        
        center.getPendingNotificationRequests(completionHandler: { requests in
            DispatchQueue.main.async {
                for request in requests {
                    note.append(request)
                    
                    completion(request)
                    
                    if debug == true {
                        print("--- --- ---")
                        print("Pending Notification: \(request.identifier)")
                        print("Title: \(request.content.title)")
                        print("Body: \(request.content.body)")
                        
                        if let trigger = request.trigger {
                            print("trigger: \(trigger))")
                        }
                        
                    }
                }
            }
        })
    }

    func refreshNotification() async {
        let content = UNMutableNotificationContent()
        content.title = "BG TASK Refresh Notification"
        content.subtitle = "Your App Refreshed in Background"
        try? await UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "test", content: content, trigger: UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)))
    }
    
    func reachedHalfOfTargetStepsNotification(steps: Int) {
        let notification = Pro_these_.StepsNotifications.shared.randomHalfNotification(steps: steps)
        
        PushNotificationManager().PushNotificationByTimer(
            identifier: notification.identifier,
            title: notification.title,
            body: notification.body,
            triggerTimer: Int.random(in: 1...20),
            url: ""
        )
    }
    
    func reachedFullOfTargetStepsNotification(steps: Int) {
        let notification = StepsNotifications.shared.randomFullNotification(steps: steps)
        
        PushNotificationManager().PushNotificationByTimer(
            identifier: notification.identifier,
            title: notification.title,
            body: notification.body,
            triggerTimer: Int.random(in: 20...40),
            url: ""
        )
    }
    
    func ReportNotification() async {
        let notification = Pro_these_.ReportNotification.shared.randomNotification
        PushNotificationManager().PushNotificationByTimer(
            identifier: notification.identifier,
            title: notification.title,
            body: notification.body,
            triggerTimer: Int.random(in: 2...10),
            url: ""
        )
    }
    
    func MissingNotification() async {
        let notification = Pro_these_.MissingReminerNotifications.shared.randomNotification
        PushNotificationManager().PushNotificationByTimer(
            identifier: notification.identifier,
            title: notification.title,
            body: notification.body,
            triggerTimer: 10,
            url: ""
        )
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

    
    
enum notificationView: String, Identifiable {
    case home, healthCenter, addFeeling
    
    var id: String {
        self.rawValue
    }
    
    var option: String {
        return "OPEN"
    }
    
    var rawValue: String {
        switch self {
            case .home: return ".home"
            case .healthCenter: return ".healthCenter"
            case .addFeeling : return ".feeling"
        }
    }
    
    func view() -> some View {
        switch self {
            case .home: return Text("Home")
            case .healthCenter: return Text("healthCenter")
            case .addFeeling : return Text("addFeeling")
        }
    }
}
