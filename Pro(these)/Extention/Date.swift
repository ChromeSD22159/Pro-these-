//
//  DateExtension.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 19.05.23.
//

import Foundation
import SwiftUI

public extension Date {
    static func mondayAt12AM() -> Date {
        return Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
    }
    
    func isSameDay(d1: Date, d2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(d1, inSameDayAs: d2)
    }
    
    func startEndOfDay() -> (start: Date, end: Date) {
        let date = self
        let calendar = Calendar.current
        let startTime = calendar.startOfDay(for: date)
        let endTime = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
        
        return (start: startTime, end: endTime)
    }
    
    func isSameDay(date1: Date, date2: Date) -> Bool {
        let diff = Calendar.current.dateComponents([.year], from: date1, to: date2)
        if diff.day == 0 {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Get all Dates of the Month
    func getAllDatesdeomMonth() -> [Date] {
        let calendar = Calendar.current
        
        // getting the first date from Month
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self ))!
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        
        // getting date
        return range.compactMap{ day -> Date in
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
    }
    
    /// yyyy-MM-dd'T'HH:mm:ssZZZZZ
    /// date.date -> "dd.MM" - date.time -> String "HH:mm"
    /// return 24.05. 10:45
    func dateFormatte(date: String, time: String) -> (date:String, time:String) {
        let formattedDate = DateFormatter()
        formattedDate.dateFormat = date
        
        let formattedTime = DateFormatter()
        formattedTime.dateFormat = time
        return (date: formattedDate.string(from: self), time: formattedTime.string(from: self))
    }
    
    func convertDateToDayNames() -> String {
        return self.dateFormatte(date: "EE", time: "HH:mm").date
    }
    
    var startEndOfWeek: (start: Date, end: Date) {
        let start = Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
        let end = self.endOfWeek!
        return (start: start, end: end)
    }
    
    func startOfWeek() -> Date {
        return Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
    
    var startWeek: Date? {
           let gregorian = Calendar(identifier: .gregorian)
           guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
           return gregorian.date(byAdding: .day, value: 1, to: sunday)
       }
    
    var endOfWeek: Date? {
        let startOfNextWeek = Calendar.current.date(byAdding: .day, value: 7, to: self.startOfWeek())!
        let end = Calendar.current.date(byAdding: .second, value: -1, to: startOfNextWeek)
        return end
    }
    
    var setHourTo8am: Date {
        Calendar.current.date(bySetting: .hour, value: 08, of: self)!
    }
    
    func extractLastDays(_ int: Int) -> [(id: UUID, date: Date)] {
        let date = self
        
        var dates: [(id: UUID, date: Date)] = []
        
        for i in 0..<int {
            dates.append((id: UUID(), date: Calendar.current.date(byAdding: .day, value: -i, to: date)!))
        }
        
        return dates
    }
    
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    }
    
    var getDateNames: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"

        return dateFormatter.string(from: self)
    }
    
    var extractWeekByDate: [(weekday: String, date: Date)] {
        var ArrWeek: [(weekday: String, date: Date)] = []
        
        let firstDayOfWeek = Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
        
        for day in 0..<7 {
            if let weekDay = Calendar.current.date(byAdding: .day, value: day, to: firstDayOfWeek) {
                let date =  Calendar.current.date(byAdding: .hour, value: 2, to: weekDay)
                ArrWeek.append( (weekday: date!.dateFormatte(date: "EE", time: "HH:mm").date , date: date!) )
            }
        }
        
        return ArrWeek
    }
    
    var startOfMonth: Date {
            return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
        
    var endOfMonth: Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: 0, second: -1), to: self.startOfMonth)!
    }
    
    var startEndOfMonth: (start: Date, end: Date) {
        return (start: self.startOfMonth, end: self.endOfMonth)
    }
    
    var isMonday: Bool {
        return Calendar.current.component(Calendar.Component.weekday, from: self) == 2
    }
    
    /// returns an integer from 1 - 7, with 1 being Sunday and 7 being Saturday
    var dayNumberOfWeek: Int {
        return Calendar.current.dateComponents([.weekday], from: self).weekday!
    }
}



extension Date:RawRepresentable{
    public typealias RawValue = String
    public init?(rawValue: RawValue) {
        guard let data = rawValue.data(using: .utf8),
              let date = try? JSONDecoder().decode(Date.self, from: data) else {
            return nil
        }
        self = date
    }

    public var rawValue: RawValue{
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data:data,encoding: .utf8) else {
            return ""
        }
       return result
    }
}

/*
 
 @propertyWrapper public struct StorageConverter<Storage: StorageDynamicProperty, Converted> {
   public typealias ToStorage = (Converted) -> Storage.Value
   public typealias FromStorage = (Storage.Value) -> Converted

   public var wrappedValue: Converted {
     get { fromStorage(storage.wrappedValue) }
     nonmutating set { storage.wrappedValue = toStorage(newValue) }
   }

   public var projectedValue: Binding<Converted> {
     .init(
       get: { wrappedValue },
       set: { wrappedValue = $0 }
     )
   }

   // MARK: internal
   init(
     storage: Storage,
     fromStorage: @escaping FromStorage,
     toStorage: @escaping ToStorage
   ) {
     self.storage = storage
     self.toStorage = toStorage
     self.fromStorage = fromStorage
   }

   // MARK: private
   private let storage: Storage
   private let fromStorage: FromStorage
   private let toStorage: ToStorage
 }

 public protocol StorageDynamicProperty<Value>: DynamicProperty {
   associatedtype Value
   var wrappedValue: Value { get nonmutating set }
 }

 // MARK: - DynamicProperty
 extension StorageConverter: DynamicProperty { }

 public extension AppStorage {
   /// A way to use `AppStorage` with more types,
   /// via conversion to and from the limited supported types.
   typealias Converter<Converted> = StorageConverter<Self, Converted>
 }

 // MARK: - StorageDynamicProperty
 extension AppStorage: StorageDynamicProperty { }

 // MARK: - Double
 public extension AppStorage<Double>.Converter where Storage == AppStorage<Double> {
   init(
     wrappedValue: Converted,
     _ key: String,
     store: UserDefaults? = nil,
     fromStorage: @escaping FromStorage,
     toStorage: @escaping ToStorage
   ) {
     self.init(
       storage: .init(wrappedValue: toStorage(wrappedValue), key, store: store),
       fromStorage: fromStorage, toStorage: toStorage
     )
   }
 }

 public extension AppStorage<Double>.Converter<Date> {
   init(
     wrappedValue: Converted,
     _ key: String,
     store: UserDefaults? = nil
   ) {
     self.init(
       wrappedValue: wrappedValue,
       key,
       store: store,
       fromStorage: Date.init(timeIntervalSinceReferenceDate:),
       toStorage: \.timeIntervalSinceReferenceDate
     )
   }
 }
 */
