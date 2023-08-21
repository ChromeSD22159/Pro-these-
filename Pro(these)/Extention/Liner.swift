//
//  Liner.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 03.08.23.
//

import SwiftUI

extension Liner {
    
    var identifier: String {
        return self.linerID ?? "NOID"
    }
    
    var generateID: String {
        return UUID().uuidString
    }
    
    var linerDateComponents: DateComponents {
       
        let nextDate = Calendar.current.date(byAdding: .month, value: Int(self.interval), to: self.date ?? Date())!
        
        let today = Date()
        
        var diff = Calendar.current.dateComponents([.month, .day], from: nextDate, to: today)
        
        if nextDate > today {
            diff = Calendar.current.dateComponents([.month, .day], from: today, to: nextDate)
        }
        
        return diff
    }
    
    var nextLinerDate: Date {
        return Calendar.current.date(byAdding: .month, value: Int(self.interval), to: self.date ?? Date())!
    }
    
    var nextLinerDateIsInFuture: Bool {
        let next = self.nextLinerDate
        let date = Date()
        
        return next > date ? true : false
    }
    
    var nextLinerDateIsInLessThan90Days: Bool {
        let days = self.getDaysToNewLiner
        
        return days < 91 ? true : false
    }
    
    var nextLinerCounterText: LocalizedStringKey {
        if self.nextLinerDateIsInFuture {
            if self.getDaysToNewLiner == 1 {
                return "in \( self.getDaysToNewLiner) day"
            } else {
                return "in \( self.getDaysToNewLiner) days"
            }
        } else {
            if self.getDaysToNewLiner == 1 {
               return "\(self.getDaysToNewLiner) day ago"
            } else {
               return "\(self.getDaysToNewLiner) days ago"
            }
            
        }
        
    }
    
    var calcDifferentDays: LocalizedStringKey {
        let nextDate = Calendar.current.date(byAdding: .month, value: Int(self.interval), to: self.date ?? Date())!
        
        let today = Date()
        
        var diff = Calendar.current.dateComponents([.day], from: nextDate, to: Date())
        
        if nextDate > today {
            diff = Calendar.current.dateComponents([.day], from: today, to: nextDate)
        }
        
        if let dayCount = diff.day {
            if dayCount == 1 {
                return LocalizedStringKey("\(dayCount) Day")
            } else {
                return LocalizedStringKey("\(dayCount) Days")
            }
        } else {
            return LocalizedStringKey("0 Days")
        }
    }
    
    var getDaysToNewLiner: Int {
        let nextDate = Calendar.current.date(byAdding: .month, value: Int(self.interval), to: self.date ?? Date())!
        
        let today = Date()
        
        var diff = Calendar.current.dateComponents([.day], from: nextDate, to: Date())
        
        if nextDate > today {
            diff = Calendar.current.dateComponents([.day], from: today, to: nextDate)
        }
        
        return diff.day ?? 0
    }
    
    func removeAndRegisterNewLinerNotification() {
        self.removeLinerNotification()
        self.registerNewLinerNotification()
    }
    
    func registerNewLinerNotification() {
        
        let username = AppConfig.shared.username
        
        let title = username == "" ? LocalizedStringKey("Hello!").localizedstring() : String(format: NSLocalizedString("Hello %@!", comment: ""), username)
        
        let prothesen = self.prothese?.allObjects as? [Prothese]

        if let pro = prothesen?.first {
            
            let prothesenKind = pro.prosthesisKind
            
            let string3daysbefore = String(format: NSLocalizedString("You can apply for your new liner for your %@ in 3 days.", comment: ""), prothesenKind.localizedstring())
            let threeDaysBefore = Calendar.current.date(byAdding: .day, value: -3, to: self.nextLinerDate)!
            PushNotificationManager().PushNotificationLiner(
                identifier: "LINER_REMINDER_3DAYSBEFORE_" + self.identifier,
                title: title,
                body: string3daysbefore,
                triggerDate: Calendar.current.date(bySettingHour: 12, minute: 30, second: 0, of: threeDaysBefore)!
            )
            
            
            
            let nextLinerisAvaible = String(format: NSLocalizedString("Your next liner for your %@ can now be requested.", comment: ""), prothesenKind.localizedstring())
            
            PushNotificationManager().PushNotificationLiner(
                identifier: "LINER_REMINDER_" + self.identifier,
                title: title,
                body: nextLinerisAvaible,
                triggerDate: Calendar.current.date(bySettingHour: 12, minute: 30, second: 0, of: self.nextLinerDate)!
            )
             
        }
        
        
    }
    
    func removeLinerNotification() {
        PushNotificationManager().removeNotification(identifier: "LINER_REMINDER_" + self.identifier)
        PushNotificationManager().removeNotification(identifier: "LINER_REMINDER_3DAYSBEFORE_" + self.identifier)
    }
}


extension String {
    static func localizedString(for key: String, locale: Locale = .current) -> String {
        let language = locale.language.languageCode!.identifier
        let path = Bundle.main.path(forResource: language, ofType: "lproj")!
        let bundle = Bundle(path: path)!
        let localizedString = NSLocalizedString(key, bundle: bundle, comment: "")
        
        return localizedString
    }
}

extension LocalizedStringKey {
    var stringKey: String? {
        Mirror(reflecting: self).children.first(where: { $0.label == "key" })?.value as? String
    }
    
    var string: String? {
        Mirror(reflecting: self).children.first(where: { $0.label == "key" })?.value as? String
    }
    
    func localizedstring(locale: Locale = .current) -> String {
        return .localizedString(for: self.stringKey ?? "", locale: locale)
    }
    
    /*
     let localizedKey = LocalizedStringKey("KEY_NAME_HERE")

     print(localizedKey.stringKey)
     //prints `KEY_NAME_HERE`

     print(localizedKey.stringValue())
     // prints Localized value of `KEY_NAME_HERE`
     // DOESNT print `KEY_NAME_HERE`
     */
}
