//
//  ProWatchOSApp.swift
//  ProWatchOS Watch App
//
//  Created by Frederik Kohler on 29.04.23.
//

import SwiftUI

@main
struct ProWatchOS_Watch_AppApp: App {
    @StateObject var healthStorage = HealthStorage()
    @StateObject var workoutManager = WorkoutManager()
    
   
    var body: some Scene {        
        
        WindowGroup {
            WatchContentView()
                .environmentObject(AppConfig())
                .environmentObject(healthStorage)
                .environmentObject(workoutManager)
                .environment(\.locale, Locale(identifier: "de"))
        }
    }
} 
