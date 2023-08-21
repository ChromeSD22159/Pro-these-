//
//  Calendar.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 19.05.23.
//

import Foundation

extension Calendar {
  private var currentDate: Date { return Date() }

  func isDateInThisWeek(_ date: Date) -> Bool {
    return isDate(date, equalTo: currentDate, toGranularity: .weekOfYear)
  }

  func isDateInThisMonth(_ date: Date) -> Bool {
    return isDate(date, equalTo: currentDate, toGranularity: .month)
  }
    
    func isDateInNextWeek(_ date: Date) -> Bool {
        guard let nextWeek = self.date(byAdding: DateComponents(weekOfYear: 1), to: currentDate) else {
            return false
        }
        return isDate(date, equalTo: nextWeek, toGranularity: .weekOfYear)
    }
    
    func isDateInNextMonth(_ date: Date) -> Bool {
       guard let nextMonth = self.date(byAdding: DateComponents(month: 1), to: currentDate) else {
         return false
       }
       return isDate(date, equalTo: nextMonth, toGranularity: .month)
    }
    
    func isDateInNextYear(_ date: Date) -> Bool {
       guard let nextMonth = self.date(byAdding: DateComponents(year: 1), to: currentDate) else {
         return false
       }
       return isDate(date, equalTo: nextMonth, toGranularity: .month)
    }
    
    var dayOfWeek: Int { 
        return self.component(.weekday, from: Date()) - 1
    }
    
    func dateRangeMinusMonth(_ int: Int) -> ClosedRange<Date> {
        return Calendar.current.date(byAdding: .month, value: -int, to: Date())!...Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
    }
}
