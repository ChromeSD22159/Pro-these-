//
//  Prothese.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 04.08.23.
//

import SwiftUI

extension Prothese {
    var identifier: String {
        return self.protheseID ?? "NOID"
    }
    
    
    var generateID: String {
        return UUID().uuidString
    }
    
    
    var maintainceDateComponents: DateComponents {
        
        let nextDate = Calendar.current.date(byAdding: .month, value: Int(self.maintageInterval), to: self.maintage ?? Date())!
        
        let today = Date()
        
        var diff = Calendar.current.dateComponents([.month, .day], from: nextDate, to: today)
        
        if nextDate > today {
            diff = Calendar.current.dateComponents([.month, .day], from: today, to: nextDate)
        }
        
        return diff
    }
    
    var prosthesisKind: LocalizedStringKey {
        switch self.kind {
        case "Everyday" : return "Everyday Prosthesis"
        case "Waterproof" : return "Waterproof Prosthesis"
        case "Replacement" : return "Replacement Prosthesis"
        case "Sport" : return "Sports Prosthesis"
        case "Sports" : return "Sports Prosthesis"
        case "No Kind" : return "No Prosthesis"
        default:
            return "No Prosthesis"
        }
    }
    
    var prosthesisKindString: String {
        switch self.kind {
        case "Everyday" : return "Everyday Prosthesis"
        case "Waterproof" : return "Waterproof Prosthesis"
        case "Replacement" : return "Replacement Prosthesis"
        case "Sport" : return "Sports Prosthesis"
        case "Sports" : return "Sports Prosthesis"
        case "No Kind" : return "No Prosthesis"
        default:
            return "No Prosthesis"
        }
    }
    
    var prosthesisKindLineBreak: LocalizedStringKey {
        switch self.kind {
        case "Everyday" : return "Everyday\nProsthesis"
        case "Waterproof" : return "Waterproof\nProsthesis"
        case "Replacement" : return "Replacement\nProsthesis"
        case "Sport" : return "Sports\nProsthesis"
        case "Sports" : return "Sports\nProsthesis"
        case "No Kind" : return "No\nProsthesis"
        default:
            return "No Prosthesis"
        }
    }
    
    var prosthesisType: LocalizedStringKey {
        switch self.type {
        case "Above knee Prothesis": return "Above knee Prothesis"
        case "Below knee Prothesis": return "Below knee Prothesis"
        case "No Type": return "No Type"
        default:
            return "No Type"
        }
    }
    
    var prosthesisIcon: String {
        switch self.type {
        case "Above knee Prothesis": return "prothese.above"
        case "Below knee Prothesis": return "prothese.below"
        case "No Type": return "prothese.below"
        default:
            return "prothese.below"
        }
    }
    
    var nextMaintenanceDateString: String {
        return self.nextMaintenanceDate.dateFormatte(date: "dd.MM.yy", time: "").date
    }
    
    var nextMaintenanceDate: Date {
        return Calendar.current.date(byAdding: .month, value: Int(self.maintageInterval), to: self.maintage ?? Date())!
    }
    
    var nextMaintenanceDateIsInFuture: Bool {
        let next = self.nextMaintenanceDate
        let date = Date()
        
        return next > date ? true : false
    }
    
    var nextMaintenanceIsInLessThan90Days: Bool {
        let days = self.getDaysToMaintenance
        
        return days < 91 ? true : false
    }
    
    var getDaysToMaintenance: Int {
        let nextDate = Calendar.current.date(byAdding: .month, value: Int(self.maintageInterval), to: self.maintage ?? Date())!
        
        let today = Date()
        
        var diff = Calendar.current.dateComponents([.day], from: nextDate, to: Date())
        
        if nextDate > today {
            diff = Calendar.current.dateComponents([.day], from: today, to: nextDate)
        }
        
        return diff.day ?? 0
    }
    
    var MaintenanceCounterText: LocalizedStringKey {
        if nextMaintenanceDateIsInFuture {
            if self.getDaysToMaintenance == 1 {
                return "in \( self.getDaysToMaintenance) day"
            } else {
                return "in \( self.getDaysToMaintenance) days"
            }
        } else {
            if self.getDaysToMaintenance == 1 {
               return "\(self.getDaysToMaintenance) day ago"
            } else {
               return "\(self.getDaysToMaintenance) days ago"
            }
            
        }
        
    }
    
    var hasMaintage: Bool {
        switch self.type {
        case "Above knee Prothesis": return true
        case "Below knee Prothesis": return false
        case "No Type": return false
        default:
            return false
        }
    }
    
    var prosthesisMaintageDate: String {
        return self.maintage!.dateFormatte(date: "dd.MM.yyyy", time: "").date
    }
    
    var prosthesisMaintageInterval: LocalizedStringKey {
        return "\(Int(self.maintageInterval)) Mths."
    }
    
    func removeAndRegisterNewProtheseNotification() {
        self.removeProtheseNotification()
        self.registerNewProtheseNotification()
    }
    
    func registerNewProtheseNotification() {
        
        let username = AppConfig.shared.username
        
        let title = username == "" ? LocalizedStringKey("Hello!").localizedstring() : String(format: NSLocalizedString("Hello %@!", comment: ""), username)

        let string4Weekssbefore = String(format: NSLocalizedString("Reminder: The next maintenance of your %@ is due in 4 weeks.", comment: ""), self.prosthesisKind.localizedstring())

        PushNotificationManager().PushNotificationLiner(
            identifier: "PROTHESE_REMINDER_4WEEKSBEFORE_" + self.identifier,
            title: title,
            body: string4Weekssbefore,
            triggerDate: Calendar.current.date(bySettingHour: 12, minute: 30, second: 0, of: Calendar.current.date(byAdding: .weekOfYear, value: -4, to: self.nextMaintenanceDate)!)!
        )
        
        let string2Weekssbefore = String(format: NSLocalizedString("Reminder: The next maintenance of your %@ is due in 2 weeks.", comment: ""), self.prosthesisKind.localizedstring())
        
        PushNotificationManager().PushNotificationLiner(
            identifier: "PROTHESE_REMINDER_2WEEKSBEFORE_" + self.identifier,
            title: title,
            body: string2Weekssbefore,
            triggerDate: Calendar.current.date(bySettingHour: 12, minute: 30, second: 0, of: Calendar.current.date(byAdding: .weekOfYear, value: -2, to: self.nextMaintenanceDate)!)!
        )
        
        
        let nextmaintenanceIsDelayed = String(format: NSLocalizedString("Reminder: The next maintenance of your %@ is overdue. Is there a delay? 😔", comment: ""), self.prosthesisKind.localizedstring())
        
        PushNotificationManager().PushNotificationLiner( // Erinnerung: Die nächste Wartung deiner Alltagsprothese wird in 4 Wochen fällig.
            identifier: "PROTHESE_REMINDER_" + self.identifier,
            title: title,
            body: nextmaintenanceIsDelayed,
            triggerDate: Calendar.current.date(bySettingHour: 12, minute: 30, second: 0, of: self.nextMaintenanceDate)!
        )
    }
    
    func removeProtheseNotification() {
        PushNotificationManager().removeNotification(identifier: "PROTHESE_REMINDER_" + self.identifier)
        PushNotificationManager().removeNotification(identifier: "PROTHESE_REMINDER_2WEEKSBEFORE_" + self.identifier)
        PushNotificationManager().removeNotification(identifier: "PROTHESE_REMINDER_4WEEKSBEFORE_" + self.identifier)
    }
}
