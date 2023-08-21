//
//  AppFirstLaunchManager.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 09.08.23.
//

import SwiftUI

enum AppFirstLaunchManager {
    
    static var handlerState = HandlerStates.shared
    
    static func requestFirstLaunch(debug: Bool) {
        guard handlerState.firstLaunch == .hasLaunched else {
            if debug {
                print("App has not Launched before")
            }
           
            handlerState.firstLaunchDate = Date()
            handlerState.firstLaunch = .hasLaunched
            
            return
        }
        
        if debug {
            print("App has Luanched before")
        }
       
    }
    
    static func updateLaunchDate() {
        handlerState.LastLaunchDate = Date()
    }
    
    static var requestMissingMessage: Bool {
        
        let deadline = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let diff = Calendar.current.dateComponents([.hour, .minute], from: handlerState.LastLaunchDate, to: Date())
        
        print(diff.hour!)
        
        guard deadline.hour! > 8 else {
            print("AppFirstLaunchManager: its before 9")
            
            lastLaunchCoreDataEntryData(bool: false)
            
            return false
        }
        
        guard diff.hour! > 32 else {
            print("AppFirstLaunchManager: Last Login is less them 32h")
            
            lastLaunchCoreDataEntryData(bool: false)
            
            return false
        }
        
        lastLaunchCoreDataEntryData(bool: true)
        
        return true
    }
    
    static var launchDate: Date? {
        guard handlerState.firstLaunch == .hasLaunched else {
            return nil
        }
        
        return handlerState.firstLaunchDate
    }
    
    static var isFirstLaunch: Bool {
        switch handlerState.firstLaunch {
            case .hasLaunched: return false
            case .notLaunchedbefore: return true
        }
    }
    
    private static func lastLaunchCoreDataEntryData(bool: Bool) {
        let deadline = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let diff = Calendar.current.dateComponents([.hour, .minute], from: handlerState.LastLaunchDate, to: Date())
        
        var data: [BackgroundTask] {
            return [
                BackgroundTask(name: "LastLaunchDate", value: handlerState.LastLaunchDate.dateFormatte(date: "dd.MM.yyyy", time: "HH:mm").date + " " + handlerState.LastLaunchDate.dateFormatte(date: "dd.MM.yyyy", time: "HH:mm").time),
                BackgroundTask(name: "Its after 8 O'clock:", value: String(deadline.hour! > 8)),
                BackgroundTask(name: "More as 32h not Logged", value: String(diff.hour! > 32)),
                BackgroundTask(name: "return", value: String(bool))
            ]
        }
        
        self.saveCoreDataEntry(task: "AppFirstLaunchManager", action: "requestMissingMessage", data: data)
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
