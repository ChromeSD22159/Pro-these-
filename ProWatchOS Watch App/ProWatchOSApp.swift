//
//  ProWatchOSApp.swift
//  ProWatchOS Watch App
//
//  Created by Frederik Kohler on 29.04.23.
//

import SwiftUI
import WidgetKit

@main
struct ProWatchOS_Watch_AppApp: App {
    @StateObject var healthStorage = HealthStorage()
    @StateObject var workoutManager = WorkoutManager()
    @StateObject var stateManager = StateManager()
    
    @State var deepLink: URL?
    // @EnvironmentObject private var extensionDelegate: MyExtensionDelegate
    @WKExtensionDelegateAdaptor private var extensionDelegate: ExtensionDelegate
    
    var body: some Scene {        
        
        WindowGroup {
            WatchContentView(deepLink: $deepLink)
                .environmentObject(AppConfig())
                .environmentObject(healthStorage)
                .environmentObject(workoutManager)
                .environmentObject(stateManager)
                .environmentObject(extensionDelegate)
                .environment(\.locale, Locale(identifier: "de"))
                .onOpenURL { url in
                    print(url)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        if url.scheme == "ProProthese" {
                            deepLink = url
                        } else {
                            deepLink = nil
                        }
                    })
                }
                .onAppear {
                    WidgetCenter.shared.reloadAllTimelines()
                }
        }
          
    }
} 
