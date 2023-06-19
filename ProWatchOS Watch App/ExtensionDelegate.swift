//
//  ExtensionDelegate.swift
//  ProWatchOS Watch App
//
//  Created by Frederik Kohler on 19.06.23.
//

import Foundation
import WatchKit

class ExtensionDelegate: NSObject, ObservableObject, WKExtensionDelegate {
    var stateManager = StateManager.sharedManager
    
    //@AppStorage("TimerState") var isRunning: Bool = false
    
    func applicationDidFinishLaunching() {
       // Perform any final initialization of your application.
        
        print("Launch: \(StateManager.sharedManager.state)")
        print("reachable: \(StateManager.sharedManager.paired)")
    }

    func applicationDidBecomeActive() {
       // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
       // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
       // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
    /*
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        
        print("asdsad")
        
        if WKExtension.shared().applicationState == .background {
            
            for task in backgroundTasks {
                switch task {
                    case let backgroundTask as WKApplicationRefreshBackgroundTask:


                        print("Background Task triggered")

                        print(stateManager.state)
                    
                        backgroundTask.setTaskCompletedWithSnapshot(false)



                    default:
                        
                        task.setTaskCompletedWithSnapshot(false)
                    }
            }
        }
    }
     */
}
