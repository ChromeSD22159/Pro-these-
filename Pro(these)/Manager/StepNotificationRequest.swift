//
//  StepNotificationRequest.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 13.08.23.
//

import SwiftUI

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}

enum StepNotificationRequest {
    
    static var handlerState = HandlerStates.shared
    
    static var appConfig = AppConfig.shared
    
    static func requestHandlerForHalfStepsGoal(debug: Bool, steps: Int, stepsDate: Date, error: Error?) -> Bool {
        guard error == nil else {
            halfStepsGoalCoreDataEntryData(bool: false, error: error?.localizedDescription ?? "", steps: steps, stepsDate: stepsDate)
            return false
        }
        
        guard Calendar.current.isDateInToday(stepsDate) && steps >= appConfig.targetSteps / 2 && steps <= (appConfig.targetSteps / 3 * 2)  else {
            print("HALFSTEP: NOT TODAY AND NOT MORE STEPS AS THE HALF OF TARGET AND bigger as \((appConfig.targetSteps / 3 * 2))")
            
            halfStepsGoalCoreDataEntryData(bool: false, error: "NOT TODAY AND NOT MORE STEPS", steps: steps, stepsDate: stepsDate)
            
            return false
        }
        
        guard !Calendar.current.isDateInToday(handlerState.sendReachedHalfTargetStepsNotificationDate) else {
            print("HALFSTEP: ALREADY SEND HAFT NOTIFICATION")
            
            halfStepsGoalCoreDataEntryData(bool: false, error: "ALREADY SEND HAFT NOTIFICATION", steps: steps, stepsDate: stepsDate)
            
            return false
        }
        
        halfStepsGoalCoreDataEntryData(bool: true, error: "", steps: steps, stepsDate: stepsDate)
        
        handlerState.sendReachedHalfTargetStepsNotificationDate = Date()
        
        return true
    }
    
    static func requestHandlerForFullStepsGoal(debug: Bool, steps: Int, stepsDate: Date, error: Error?) -> Bool {
        
        guard error == nil else {
            halfStepsGoalCoreDataEntryData(bool: false, error: error!.localizedDescription, steps: steps, stepsDate: stepsDate)
            return false
        }
        
        guard Calendar.current.isDateInToday(stepsDate) && steps >= appConfig.targetSteps else {
            print("FULLSTEP: NOT TODAY AND NOT MORE STEPS AS TARGET")
            
            fullStepsGoalCoreDataEntryData(bool: false, error: "NOT TODAY AND NOT MORE STEPS AS TARGET", steps: steps, stepsDate: stepsDate)
            
            return false
        }
        
        guard !Calendar.current.isDateInToday(handlerState.sendReachedFullTargetStepsNotificationDate) else {
            print("FULLSTEP: ALREADY SEND FULL NOTIFICATION")

            fullStepsGoalCoreDataEntryData(bool: false, error: "ALREADY SEND FULL NOTIFICATION", steps: steps, stepsDate: stepsDate)
            
            return false
        }

        handlerState.sendReachedFullTargetStepsNotificationDate = Date()
        
        
        fullStepsGoalCoreDataEntryData(bool: true, error: "", steps: steps, stepsDate: stepsDate)
        
        return true
        
    }
    
    private static func halfStepsGoalCoreDataEntryData(bool: Bool, error: String, steps: Int, stepsDate: Date) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() +  0.1, execute: {
            var data: [BackgroundTask] {
                return [
                    BackgroundTask(name: "storedStepsDate", value: stepsDate.dateFormatte(date: "dd.MM.yyyy", time: "HH:mm").date + " " + stepsDate.dateFormatte(date: "dd.MM.yyyy", time: "HH:mm").time),
                    BackgroundTask(name: "storedSteps", value: String(steps)),
                    BackgroundTask(name: "tripper", value: String(appConfig.targetSteps / 2) + "-" + String(appConfig.targetSteps / 3 * 2)),
                    //BackgroundTask(name: "sendReachedHalfTargetStepsNotification", value: String(handlerState.sendReachedHalfTargetStepsNotification)),
                    BackgroundTask(name: "error", value: error),
                    BackgroundTask(name: "return", value: String(bool))
                ]
            }
            
            self.saveCoreDataEntry(task: "StepNotificationRequest", action: "requestHandlerForHalfStepsGoal", data: data)
            
            print("halfStepsGoalCoreDataEntryData Saved")
        })
        
    }
    
    private static func fullStepsGoalCoreDataEntryData(bool: Bool, error: String, steps: Int, stepsDate: Date) {
        DispatchQueue.main.asyncAfter(deadline: .now() +  0.1, execute: {
            
            var data: [BackgroundTask] {
                return [
                    BackgroundTask(name: "storedStepsDate", value: stepsDate.dateFormatte(date: "dd.MM.yyyy", time: "HH:mm").date + " " + stepsDate.dateFormatte(date: "dd.MM.yyyy", time: "HH:mm").time),
                    BackgroundTask(name: "storedSteps", value: String(steps)),
                    BackgroundTask(name: "tripper", value: String(appConfig.targetSteps)),
                    //BackgroundTask(name: "sendReachedHalfTargetStepsNotification", value: String(handlerState.sendReachedHalfTargetStepsNotification)),
                    BackgroundTask(name: "error", value: error),
                    BackgroundTask(name: "return", value: String(bool))
                ]
            }
            
            self.saveCoreDataEntry(task: "StepNotificationRequest", action: "requestHandlerForFullStepsGoal", data: data)
            
            print("fullStepsGoalCoreDataEntryData Saved")
        })
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
}
