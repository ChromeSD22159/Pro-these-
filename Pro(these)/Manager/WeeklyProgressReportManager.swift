//
//  WeeklyProgressReport.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 14.08.23.
//

import SwiftUI
import CoreData

enum WeeklyProgressReportManager {
    static var managedObjectContext = PersistenceController.shared.container.viewContext
    
    @AppStorage("weeklyProgressReportOverlay", store: AppConfig.store) static var weeklyProgressReportOverlay = false
    @AppStorage("showReportSheet", store: AppConfig.store) static var showReportSheet = false
    
    static let now = Calendar.current.dateComponents([.hour, .minute], from: Date())
    
    static let handlerStates = HandlerStates.shared
    
    static var triggerTime: (h: Int, m: Int) = (h: 9, m: 00)
    
    @FetchRequest(
        sortDescriptors: [] //, predicate: NSPredicate(value: Calendar.current.isDateInToday(Date()))
    ) static var reports: FetchedResults<Report>

    static var requestCoreDataHandler: Bool {
        guard !Calendar.current.isDate(Date(), inSameDayAs: AppFirstLaunchManager.handlerState.firstLaunchDate) else {
            print("FirstLaung was TODAY")
            
            var requestCoreDataHandlerData: [BackgroundTask] {
                return [
                    BackgroundTask(name: "return", value: "FirstLaung was TODAY")
                ]
            }
            
            self.saveCoreDataEntry(task: "WeeklyProgressReportManager", action: "requestCoreDataHandler", data: requestCoreDataHandlerData)
            
            return false
        }
        
        guard !Calendar.current.isDate(Date(), inSameDayAs: handlerStates.weeklyProgressReportNotification) else {
            print("WEEKLY REPORT STORED TODAY")
            
            var requestCoreDataHandlerData: [BackgroundTask] {
                return [
                    BackgroundTask(name: "return", value: "WEEKLY REPORT STORED TODAY")
                ]
            }
            
            self.saveCoreDataEntry(task: "WeeklyProgressReportManager", action: "requestCoreDataHandler", data: requestCoreDataHandlerData)
            
            return false
        }
        
        guard Date().isMonday else {
            weeklyProgressReportOverlay = false
            showReportSheet = false
            print("WEEKLY REPORT NOT STORED TODAY BUT ITS NOT MONDAY")
            
            var requestCoreDataHandlerData: [BackgroundTask] {
                return [
                    BackgroundTask(name: "return", value: "WEEKLY REPORT NOT STORED TODAY BUT ITS NOT MONDAY")
                ]
            }
            
            self.saveCoreDataEntry(task: "WeeklyProgressReportManager", action: "requestCoreDataHandler", data: requestCoreDataHandlerData)
            
            return false
        }        

        guard now.hour! >= triggerTime.h && now.minute! >= triggerTime.m else {
            print("its not after \(triggerTime.h):\(triggerTime.m)")
            
            weeklyProgressReportOverlay = false
            showReportSheet = false
            return false
        }

        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let newReport = Report(context: managedObjectContext)
            newReport.created = Date()
            newReport.startOfWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!.startEndOfWeek.start
            newReport.endOfWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!.startEndOfWeek.end
            
            do {
               try? managedObjectContext.save()

                
                
                weeklyProgressReportOverlay = true
                handlerStates.weeklyProgressReportNotification = Date()
                showReportSheet = true
            }
        }
        
        print("saved WeeklyProgress")

        return true
    }
    
    private static func saveCoreDataEntry(task: String, action: String, data: [BackgroundTask]) {
        let JoinedString = data
            .map{ "\($0.name),\($0.value)" } // notice the comma in the middle
            .joined(separator:"\n")

        let newTask = BackgroundTaskItem(context: PersistenceController.shared.container.viewContext)
        newTask.task = task
        newTask.action = action
        newTask.date = Date()
        newTask.data = JoinedString
        
        do {
            try? PersistenceController.shared.container.viewContext.save()
        }
    }
    
    /*
    private static func loadData() {
      
        let lastWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!
        let week =  DateInterval(start: lastWeek.startEndOfWeek.start, end: lastWeek.startEndOfWeek.end)
        
        HealthStoreProvider().queryWeekCountbyType(week: week, type: .stepCount, completion: { stepCount in
            DispatchQueue.main.async {
                self.stepsTotal = stepCount.data.map { Int($0.value) }.reduce(0, +)
            }
        })
        
        // Total DistanzesSteps
        HealthStoreProvider().queryWeekCountbyType(week: week, type: .distanceWalkingRunning, completion: { distanceCount in
            DispatchQueue.main.async {
                distanceTotal = distanceCount.data.map { Int($0.value) }.reduce(0, +)
            }
        })
        
        // Total WearingTimes
        HealthStoreProvider().getWorkouts(week: week, workout: .default()) { workouts in
            DispatchQueue.main.async {
                let totalWorkouts = workouts.data.map({ workout in
                    return Int(workout.value)
                }).reduce(0, +)
                
                wearingTimeTotal = totalWorkouts
            }
        }
    }
     */
}

