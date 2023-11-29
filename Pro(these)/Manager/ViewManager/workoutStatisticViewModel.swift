//
//  workoutStatisticViewModel.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 19.05.23.
//

import Foundation
import HealthKit

class WorkoutStatisticViewModel: ObservableObject {
    let healthStore = HealthStoreProvider()
    
    @Published var currentDay: Date = Date()
    @Published var currentWeek: [Date] = []
    @Published var weeks: [[Date]] = []
    
    
    @Published var selectedSteps:Double = 0
    @Published var selectedAvgSteps: Double = 0
    @Published var selectedDistance:Double = 0
    @Published var selectedAvgDistance: Double = 0
    @Published var selectedWorkout:Double = 0
    @Published var selectedAvgWorkout: Double = 0
    
    
    @Published var WeeklySteps:ChartDataPacked?
    @Published var WeeklyDistanz:ChartDataPacked?
    
    @Published var CollectionWeeklySteps: [ChartDataPacked] = []
    @Published var CollectionWeeklyDistanz: [ChartDataPacked] = []
    @Published var CollectionWeeklyWorkouts: [WorkoutDataPacked] = []
    
    ///  Extrakt weekdays and save it in weekly Arrays
    func extractWeeks(numberofWeeks: Int){
        let date = Date()
        self.weeks.removeAll(keepingCapacity: true)
        
        let calendar = Calendar.current
        let week = Calendar.current.dateInterval(of: .weekOfMonth, for: date)
        
        guard let firstDay = week?.start else {
            return
        }

        (0..<numberofWeeks).forEach{ currentWeek in
            if let dayOfWeek = calendar.date(byAdding: .weekdayOrdinal, value: -currentWeek, to: firstDay) {
                self.weeks.append( self.getDaysOfWeek(dayOfWeek) )
            }
        }
    }
    
    ///  Extrakt weekdays and save it in an Arrays
    func getDaysOfWeek(_ date: Date) -> [Date] {
        var data:[Date] = []
        let calendar = Calendar.current
        let week = Calendar.current.dateInterval(of: .weekOfMonth, for: date)

        guard let firstDay = week?.start else {
            return []
        }
        
        (0..<7).forEach{ day in
            if let weekDay = calendar.date(byAdding: .day, value: day, to: firstDay) {
                data.append(weekDay)
            }
        }
        
        return data
    }
    
    /// fetch Steps / Distances by week collection, calc the avg data and save it as an Array with weekly Step/Distances
    func getCollectionOfWeeklyHealthData(){
        self.CollectionWeeklySteps.removeAll(keepingCapacity: true)
        self.CollectionWeeklyDistanz.removeAll(keepingCapacity: true)
        self.CollectionWeeklyWorkouts.removeAll(keepingCapacity: true)
        let currentWeek = Calendar.current.component(.weekOfYear, from: Date())
        
        for week in self.weeks {
            let DateIndterval = DateInterval(start: Calendar.current.startOfDay(for: week.first!), end: Calendar.current.endOfDay(for: week.last!))

            healthStore.queryWeekCountbyType(week: DateIndterval, type: .stepCount, completion: { stepCount in
                DispatchQueue.main.async {
                    self.CollectionWeeklySteps.append(stepCount)
                    if stepCount.weekNr == currentWeek {
                        self.selectedAvgSteps = Double(stepCount.avg)
                    }
                }
            })
            
            healthStore.queryWeekCountbyType(week: DateIndterval, type: .distanceWalkingRunning, completion: { distance in
                DispatchQueue.main.async {
                    self.CollectionWeeklyDistanz.append(distance)
                    if distance.weekNr == currentWeek {
                        self.selectedAvgDistance = Double(distance.avg)
                    }
                }
            })
            
            healthStore.getWorkouts(week: DateIndterval, workout: .default(), completion: { workouts in
                DispatchQueue.main.async {
                    self.CollectionWeeklyWorkouts.append(workouts)
                    if workouts.weekNr == currentWeek {
                        self.selectedAvgWorkout = Double(workouts.avg)
                    }
                }
            })
        }

    }
    
    func getStepsForDate( _ date: Date ) {
        healthStore.queryDayCountbyType(date: date, type: .stepCount, completion: { steps in
            DispatchQueue.main.async {
                self.selectedSteps = steps
            }
        })
    }
    
    func getDistanceForDate( _ date: Date ) {
        healthStore.queryDayCountbyType(date: date, type: .distanceWalkingRunning, completion: { distance in
            DispatchQueue.main.async {
                self.selectedDistance = distance
            }
        })
    }
    
    func getWeekNumberFromDate(_ date: Date) -> Int {
        return Calendar.current.component(.weekOfYear, from: date)
    }
    
    func compareWeekAvg(date: Date, arr: [ChartDataPacked]) -> Bool {
        let (lastWeekAvg, thisWeekAvg) = getAvgDataForThisAndTheWeekBefore(date: date, arr: arr)
        
        return lastWeekAvg <= thisWeekAvg ? true : false 
    }
    
    /// (Bool, percent (Int))
    func checkTargetSteps(steps: Double) -> (Bool, Int) {
        let percent = steps / Double(AppConfig.shared.targetSteps) * 100
        let bool = percent >= 100 ? true : false
        return (bool, Int(percent))
    }
    
    /*
    /// "Das sind 123456789 weniger als in der Woche zuvor."
    func calculateAvgDifference(date: Date, toCalc: [ChartDataPacked], value: Int , type: String) -> String {
        let (lastWeekAvg, thisWeekAvg) = getAvgDataForThisAndTheWeekBefore(date: date, arr: toCalc)
        let calc:Double = Double(thisWeekAvg - lastWeekAvg)
        
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0;
        
        var string1:String?, string2:String?
        
        if type == "Schritte" {
            let result = calc.sign == .minus ? formatter.string(from: NSNumber(value: abs(calc) ))! + " " + type + " weniger " : formatter.string(from: NSNumber(value: abs(calc) ))! + " " + type + " mehr "
            string1 = "Du bist durchschnittlich " + formatter.string(from: NSNumber(value: value))! + " " + type + " pro Tag gegangen. "
            string2 = "Das sind " + result + "als in der Woche zuvor."
        }
        
        if type == "km" { // String(format: "%.2f", vm.selectedAvgDistance / 1000)
            let result = calc.sign == .minus ? String(format: "%.2f", Double( abs(calc) ) / 1000) + " " + type + " weniger " : String(format: "%.2f", Double( abs(calc) ) / 1000) + " " + type + " mehr "
            string1 = "Du bist durchschnittlich " + String(format: "%.2f", Double(value) / 1000) + " " + type + " pro Tag gegangen. "
            string2 = "Das sind " + result + "als in der Woche zuvor."
        }
        
        if type == "h" {
            let (AvgHour,AvgMin,_) = Int(value).secondsToHoursMinutesSeconds()
            string1 = "Du bist durchschnittlich \(AvgHour):\(AvgMin)" + type + " pro Tag gegangen. "
            
            let (ResultHour,ResultMin,_) = Int(calc).secondsToHoursMinutesSeconds()
            let result = calc.sign == .minus ? "\(ResultHour):\(ResultMin)" + type + " weniger " : "\(ResultHour):\(ResultMin) " + type + " mehr "
            string2 = "Das sind " + result  + "als in der Woche zuvor."
        }
        
        return (string1 ?? "")  + (string2 ?? "")
    }
    */
    
    
    func getAvgDataForThisAndTheWeekBefore(date: Date, arr: [ChartDataPacked]) -> (Int, Int) {
        let week = getWeekNumberFromDate(date)
        
        var result = (0,0)
        
        if let ThisWeekAvgSteps = arr.first(where: { return $0.weekNr == week }) {
            if let LastWeekAvgSteps = arr.first(where: { return $0.weekNr == week - 1 }) {
                result = (LastWeekAvgSteps.avg, ThisWeekAvgSteps.avg)
            }
        }
        
        return result
    }

}

extension Calendar {

    func endOfDay(for date: Date) -> Date {

        // Get the start of the date argument.
        let dayStart = self.startOfDay(for: date)

        // Add one day to the start of the day
        // in order to get the start of the following day.
        guard let nextDayStart = self.date(byAdding: .day, value: 1, to: dayStart) else {
            preconditionFailure("Expected start of next day")
        }

        // Create date components that will subtract a single
        // second from the start of the next day. This will
        // allow you to get the last hour, last minute, and last
        // second of the previous day, which is the day for the
        // date argument that was passed to this method.
        var components = DateComponents()
        components.second = -1

        // Add the date components to the date for the next
        // day, which will perform the subtraction of the single
        // second. This will return the end of the day for the date
        // that was passed into this method.
        guard let dayEnd = self.date(byAdding: components, to: nextDayStart) else {
            preconditionFailure("Expected end of day")
        }

        // Simply return the date value.
        return dayEnd
    }

}

extension String {
    func trimCharater () -> String {
        return self.trimmingCharacters(in: ["("," ",":","\"",")"])
    }
    
    func trimFeelings () -> String {
        return self.trimmingCharacters(in: ["_", "f", "e" ,"l","i","n","g"])
    }
    
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
