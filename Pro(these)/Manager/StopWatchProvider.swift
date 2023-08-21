//
//  StopWatchProvider.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 19.05.23.
//

import Foundation
import HealthKit
import WidgetKit
import SwiftUI
import ActivityKit

class StopWatchProvider: NSObject, ObservableObject {
    
    static var shared = StopWatchProvider()
    
    var store = HKHealthStore()
    
    @Published var recorderState: WorkoutSessionState = .notStarted
    @Published var recorderStartTime: Date?

    func startRecording(completion: @escaping(Bool) -> ()){
        let date = Date()
        self.recorderStartTime = date
        UserDefaults.standard.set(self.recorderStartTime, forKey: "startTime")
        
        let userDefaults = UserDefaults(suiteName: "group.FK.Pro-these-")
        userDefaults?.set(true, forKey: "TIME")
        userDefaults?.synchronize()
        
        self.recorderState = .started
        
        startLiveActivity(date: date, prothese: prothesis.kind.sport.fullValue.localizedstring())
        
        completion(true)
    }
    
    func stopRecording(completion: @escaping(Bool) -> ()){
        let startTime = recorderFetchStartTime()
        guard startTime != nil else {
            return print("stopRecording: Start Time is unset")
        }
        
        let workoutSecound = Calendar.current.dateComponents([.second], from: startTime!, to: Date()).second!
        
        if workoutSecound < 345500 {
           completeWorkout(workout: .walking, start: startTime!, end: Date())
        }

        self.recorderStartTime = nil
        
        let userDefaults = UserDefaults(suiteName: "group.FK.Pro-these-")
        userDefaults?.set(false, forKey: "TIME")
        userDefaults?.synchronize()
        
        UserDefaults.standard.set(nil, forKey: "startTime")
        
        @AppStorage("timerState", store: UserDefaults(suiteName: "group.FK.Pro-these-")) var timerState: Bool = false
        
        WidgetCenter.shared.reloadAllTimelines()
        
        self.recorderState = .notStarted
        
        endLiveActivity(startDate: startTime!, prothese: AppConfig.shared.selectedProthese)
        
        completion(false)
    }
    
    func startLiveActivity(date: Date, prothese: String) {
        if AppConfig.shared.showLiveActivity {
            if ActivityAuthorizationInfo().areActivitiesEnabled {

                let LiveAttributes = ProProtheseWidgetAttributes()
                
                let initialContentState = ProProtheseWidgetAttributes.ContentState(isRunning: true, date: date, prothese: AppConfig.shared.selectedProthese)
                
                // Start the Live Activity.
                do {

                    let newActivity = try Activity<ProProtheseWidgetAttributes>.request( attributes: LiveAttributes, contentState: initialContentState, pushType: nil)
                    
                    print("Requested a Live Activity \(String(describing: newActivity.id)).")
                } catch (let error) {
                    print("Error requesting pizza delivery Live Activity \(error.localizedDescription).")
                }
            }
        }
    }
    
    func endLiveActivity(startDate: Date, prothese: String) {
        if AppConfig.shared.showLiveActivity {
            let diffTime = Calendar.current.dateComponents([.second], from: startDate, to: Date()).second
            
            let finalDeliveryStatus = ProProtheseWidgetAttributes.ContentState(isRunning: false, date: Date(), endTime: diffTime, prothese: prothese)
            let finalContent = ActivityContent(state: finalDeliveryStatus, staleDate: nil)

            Task {
                for activity in Activity<ProProtheseWidgetAttributes>.activities {
                    await activity.end(finalContent, dismissalPolicy: .immediate)
                    print("Ending the Live Activity: \(activity.id)")
                }
            }
        }
    }
    
    func recorderFetchStartTime() -> Date? {
        if (UserDefaults.standard.object(forKey: "startTime") != nil) {
            @AppStorage("timerState", store: UserDefaults(suiteName: "group.FK.Pro-these-")) var timerState: Bool = true
            WidgetCenter.shared.reloadAllTimelines()
            return UserDefaults.standard.object(forKey: "startTime") as? Date
        } else {
            @AppStorage("timerState", store: UserDefaults(suiteName: "group.FK.Pro-these-")) var timerState: Bool = false
            WidgetCenter.shared.reloadAllTimelines()
            return nil
        }
    }
    
    func sharedState(_ bool : Bool) {
        AppConfig().recorderState = bool
        AppConfig().recorderTimer = Date()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    var builder: HKWorkoutBuilder?

    func completeWorkout(workout: HKWorkoutActivityType, start: Date, end: Date) {
        // generate an WorkOut Session
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .other
        let builder = HKWorkoutBuilder(healthStore: store, configuration: workoutConfiguration, device: .local())
        
        // Finish the Workoutsession
        builder.finishWorkout { (_, error) in
            _ = error == nil
        }
        
        // Generatre Workout
        let inputState = HKWorkout(
            activityType: .other,
            start: start,
            end: end,
            duration: end.timeIntervalSince(start),
            totalEnergyBurned: nil,
            totalDistance: nil,
            device: .local(),
            metadata: nil
        )

        // save Workout to Fitness Store
        self.store.save(inputState) { success, error in
             if (error != nil) {
                 print("Error: \(String(describing: error))")
             }
             if success {
                 print("Saved: \(success)")
             }
        }
        
        // Reset WorkoutBuilder
        self.builder = nil
    }
}
