//
//  MoodCalendar.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 24.05.23.
//

import SwiftUI

class MoodCalendar: ObservableObject {
    // MARK: - Calendar States
    @Published var currentMonth:Int = 0
    @Published var currentDate: Date = Date()
    @Published var currentDates: [DateValue] = []
   
    
    
    // MARK: - Add Feeling State for the Sheet
    @Published var isFeelingSheet = false
    @Published var selectedFeeling = ""
    @Published var addFeelingDate: Date = Date()
    @Published var showDatePicker = false
    
    // delete confirm
    @Published var isPresentingConfirmDeleteItem: Bool = false
    @Published var isPresentingConfirmDialog: Bool = false
    @Published var isCalendar: Bool = true
    @Published var scrollTo: String = ""
    
    // MARK: - Feelings
    @Published var feelingItems: [Mood] = [
        Mood(image: "1", name: "Sehr Gut", color: .green),
        Mood(image: "2", name: "Gut", color: .green),
        Mood(image: "3", name: "Geht", color: .yellow),
        Mood(image: "4", name: "Schlecht", color: .orange),
        Mood(image: "5", name: "Sehr Schlecht", color: .red),
    ]
    
    @Published var editFeeling: Feeling?
    
    // MARK: - Formatte Date to "May 2023"
    func extractDate() -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM YYYY"
        let date = formatter.string(from: self.currentDate)
        return date.components(separatedBy: " ")
    }
    
    // MARK: - Get the Current Month by the Date
    func getCurrentMonth() -> Date {
        let calendar = Calendar.current
        
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else {
            return Date()
        }
        
        let firstDayOfMonth = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: currentMonth))
        
        if calendar.isDateInThisMonth(firstDayOfMonth!) {
            return Date()
        } else {
            return firstDayOfMonth!
        }
        
    }
    
    // MARK: - Extract the month
    func extractMonth() -> [DateValue] {
       
        let calendar = Calendar.current
        
        /// get current month
        let currentMonth = getCurrentMonth()
        
        /// get only the daynumber and save it as Model Array
        var days = currentMonth.getAllDatesdeomMonth().compactMap{ date -> DateValue in
            let day = calendar.component(.day, from: date)
            return DateValue(day: day, date: date)
        }
        
        /// Get the first day of the Month
        let firstWeekDay = calendar.component(.weekday, from: days.first?.date ?? Date())
        
        for _ in 0..<(firstWeekDay - 1) - 1 {
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        
        return days
    }
    
    // MARK: - check if two dates are the same day
    func isSameDay(d1: Date, d2: Date) -> Bool {
       return Calendar.current.isDate(d1, inSameDayAs: d2)
    }
    
    // MARK: - check for reminder notification is already registerd, remove all reminders and set a new random reminder
    func checkNotificationExistAndRegister(identifier: String) {
        let center = UNUserNotificationCenter.current()
        var note: [String] = []
        
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                note.append(request.identifier)
            }
        })
        
        PushNotificationManager().removeNotification(identifier: "PROTHESE_MOOD_REMINDER_DAILY_1")
        PushNotificationManager().removeNotification(identifier: "PROTHESE_MOOD_REMINDER_DAILY_2")
        
        if (note.first(where: { request in return request == identifier }) != nil) {
            let randomNotification = Int.random(in: 1...2)
            
            if randomNotification == 1 {
                let reminder1 = PushNotifications().MoodReminderDaily1
                PushNotificationManager().PushNotificationByDate(identifier: reminder1["identifier"]!, title: reminder1["titel"]!, body: reminder1["body"]!, triggerHour: 19, triggerMinute: 30, repeater: true, url: reminder1["url"]!)
            }
            if randomNotification == 2 {
                let reminder2 = PushNotifications().MoodReminderDaily2
                PushNotificationManager().PushNotificationByDate(identifier: reminder2["identifier"]!, title: reminder2["titel"]!, body: reminder2["body"]!, triggerHour: 19, triggerMinute: 30, repeater: true, url: reminder2["url"]!)
            }
        }
    }
}
