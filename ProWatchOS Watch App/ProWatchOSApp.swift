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
    
    @State var deepLink: URL?
    var body: some Scene {        
        
        WindowGroup {
            WatchContentView(deepLink: $deepLink)
                .environmentObject(AppConfig())
                .environmentObject(healthStorage)
                .environmentObject(workoutManager)
                .environment(\.locale, Locale(identifier: "de"))
                .onOpenURL { url in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        if url.scheme == "ProProthese" {
                            deepLink = url
                        } else {
                            deepLink = nil
                        }
                    })
                }
        }
    }
} 
