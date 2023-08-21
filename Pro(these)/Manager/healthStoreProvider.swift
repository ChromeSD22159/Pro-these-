//
//  healthStoreProvider.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 19.05.23.
//

import Foundation
import HealthKit
import UserNotifications
import SwiftUI

class HealthStoreProvider: NSObject, ObservableObject {
    
    @StateObject var handlerStates = HandlerStates()
    
    let healthStore = HKHealthStore()
    
    /*
    let typesToRead: Set = [
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
        HKQuantityType.quantityType(forIdentifier: .distanceWheelchair)!,
        HKQuantityType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.activitySummaryType(),
        HKSeriesType.workoutType(),
        HKSeriesType.workoutRoute()
    ]
     */

    func setUpHealthRequest(healthStore: HKHealthStore, readSteps: @escaping () -> Void) {
        
        // The quantity type to write to the health store.
        let typesToShare: Set = [
            HKQuantityType.workoutType(),
            HKSeriesType.workoutRoute()
        ]
        
        // The quantity types to read from the health store.
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWheelchair)!,
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.activitySummaryType(),
            HKSeriesType.workoutType(),
            HKSeriesType.workoutRoute()
        ]
        
        if HKHealthStore.isHealthDataAvailable() {
            healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
                
                if success {
                    readSteps()
                    self.startObservingHeightChanges()
                }
            }
        }
    }
    
    /*
    func requestAuthorization(healthStore: HKHealthStore, completion: @escaping (_ success: Bool) -> Void) {
        
        // The quantity type to write to the health store.
        let typesToShare: Set = [
            HKQuantityType.workoutType(),
            HKSeriesType.workoutRoute()
        ]
        
        // The quantity types to read from the health store.
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWheelchair)!,
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.activitySummaryType(),
            HKSeriesType.workoutType(),
            HKSeriesType.workoutRoute()
        ]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            DispatchQueue.main.async {

                completion(success)
            }
            
        }
    }*/
}

enum HealtError: String {
    case noTypeIdentifier = "noTypeIdentifier"
    case noResult = "noResult"
    case none = "none"
}


extension HealthStoreProvider {
    func startObservingHeightChanges() {

        let sampleType =  HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!

        let date = Date()
        let calendar = Calendar.current
        let startTime = calendar.startOfDay(for: date)
        let endTime = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)
        
        let predicate = HKQuery.predicateForSamples(withStart: startTime, end: endTime, options: .strictStartDate)

        let query: HKObserverQuery = HKObserverQuery(sampleType: sampleType, predicate: predicate) { (query, completionHandler, error) in
            print(query)
            self.stepChangedHandler(query: query, completionHandler: completionHandler, error: error)
        }
        
        healthStore.execute(query)
        healthStore.enableBackgroundDelivery(for: sampleType, frequency: .hourly, withCompletion: {(succeeded: Bool, error: Error!) in

              if succeeded{
                  print("Enabled background delivery of StepChanges changes")
              } else {
                  if let theError = error{
                      print("Failed to enable background delivery of weight changes. ")
                      print("Error = \(theError)")
                  }
              }
          })
      }
    
    func stepChangedHandler(query: HKObserverQuery, completionHandler: HKObserverQueryCompletionHandler, error: Error?) {
        if AppConfig.shared.adsDebug {
            if HandlerStates.shared.DEBUGAppDelegateTrigger {
                PushNotificationByTimer(
                        identifier: "BG_TASK_Error_Step_query",
                        title: "stepChangedHandler in Health App",
                        body: "\(error?.localizedDescription ?? "stepChangedHandler in Health App")",
                        triggerTimer: 1,
                        url: ""
                )
            }
        }

          completionHandler()
    }

    func updateStepData(completionHandler: @escaping (Double?, Error?) -> Void) {
        let sampleType =  HKQuantityType.quantityType(forIdentifier: .stepCount)!
        self.getStepsSampleInBackground(for: sampleType) { (steps, error) in
            completionHandler(steps, error)
        }
    }
    
    func getStepsSampleInBackground(for sampleType: HKSampleType, completion: @escaping (Double?, Error?) -> Swift.Void) {
        let stepQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)
         
        let date = Date()
        let calendar = Calendar.current
        let startTime = calendar.startOfDay(for: date)
        let endTime = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)
        
        let predicate = HKQuery.predicateForSamples(withStart: startTime, end: endTime, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepQuantityType!, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0, error ?? nil)
                return
            }
            
            completion(sum.doubleValue(for: HKUnit.count()), error ?? nil)
        }
        
        healthStore.execute(query)
   }
}

extension HealthStoreProvider {
    
    func queryWeekCountbyType(week: DateInterval, type: HKQuantityTypeIdentifier ,completion: @escaping (ChartDataPacked) -> Void) {
        guard let stepQuantityType = HKQuantityType.quantityType(forIdentifier: type) else { return }
        
        let predicate = HKQuery.predicateForSamples(withStart: week.start.startEndOfDay().start, end: week.end.startEndOfDay().end, options: .strictStartDate)
        
        let query = HKStatisticsCollectionQuery(quantityType: stepQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: Date.mondayAt12AM(), intervalComponents: DateComponents(day: 1))
        
        query.initialResultsHandler = { query, results, error in
            
            var data:[ChartData] = []
            var name = ""
            
            results?.enumerateStatistics(from: week.start, to: week.end)
               { (statistics, stop) in
                   if let quantity = statistics.sumQuantity() {
                       
                       var date = Date()
                       
                       if statistics.startDate < Date() {
                           date = Calendar.current.date(byAdding: .hour, value: 12, to: statistics.startDate)!
                       } else {
                           date = Calendar.current.date(byAdding: .hour, value: 0, to: statistics.startDate)!
                       }

                       if type == .stepCount {
                           let value = quantity.doubleValue(for: .count())
                           data.append( ChartData(date: date, value: value) )
                           name = "Steps"
                       }
                       
                       if type == .distanceWalkingRunning {
                           let value = quantity.doubleValue(for: .meter())
                           data.append( ChartData(date: date, value: value) )
                           name = "Distance"
                           
                       }
                       
                       if type == .walkingSpeed {
                           let value = quantity.doubleValue(for: .meter().unitDivided(by: HKUnit.hour()))
                           data.append( ChartData(date: date, value: value) )
                           name = "speed"
                       }
                   }
               }

            let avg = data.count != 0 ? data.map{ Int($0.value) }.reduce(0, +) / data.count : 0
            
            let weekNr = Calendar.current.component(.weekOfYear, from: week.start)
            
            completion(ChartDataPacked(avg: avg, avgName: name , weekNr: weekNr, data: data))
        }
        
        healthStore.execute(query)
    }
    
    func queryAvgStepsforWeeks(dateInterval: DateInterval, type: HKQuantityTypeIdentifier, completion: @escaping ((week: (start: Date, end: Date), totalSteps: Double)) -> Void) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: type) else { return }
        
        let predicate = HKQuery.predicateForSamples(withStart: dateInterval.start, end: dateInterval.end, options: .strictStartDate)
        
        var interval = DateComponents()
           interval.weekOfYear = 1
        
        let queryweeks = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: dateInterval.end,
            intervalComponents: interval
        )
        
        queryweeks.initialResultsHandler = { query, results, error in
            
            
            
            results?.enumerateStatistics(from: dateInterval.start,to: dateInterval.end, with: { (result, _) in
                let steps = result.sumQuantity()?.doubleValue(for: HKUnit.count())
                let data = (week: (start: result.startDate, end: result.endDate), totalSteps: steps ?? 0)
                completion(data)
            })

        }
        
        healthStore.execute(queryweeks)
        
        
    }

    func readWorkouts(date: Date, type: HKQuantityTypeIdentifier) async -> (Double? , HealtError?) {
        guard let stepQuantityType = HKQuantityType.quantityType(forIdentifier: type) else { return (0 , HealtError.noTypeIdentifier) }

        let calendar = Calendar.current
        let startTime = calendar.startOfDay(for: date)
        let endTime = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)

        let predicate = HKQuery.predicateForSamples(withStart: startTime, end: endTime, options: .strictStartDate)

        let samples = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Double, Error>) in
            
            healthStore.execute(
                HKStatisticsQuery(quantityType: stepQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) {  _, result, error in
                    
                    guard let result = result, let sum = result.averageQuantity() else {
                        continuation.resume(throwing: error!)
                        return
                    }
                    
                    continuation.resume(returning: sum.doubleValue(for: HKUnit.count()) )
                }
            )
        }

        return (samples , nil)
    }
    
    func PushNotificationByTimer(identifier: String, title: String, body: String, triggerTimer: Int, url: String, userInfo: [String:String]? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        if userInfo != nil {
            content.userInfo = userInfo!
        } else {
            content.userInfo = ["Tab" : Tab.home.rawValue]
        }
      
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(triggerTimer), repeats: false)
        // choose a random identifier
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
        
        print("Register Notification:  \(identifier) - \(title) - \((triggerTimer))")
    }

    func queryDayCountbyType(date: Date, type: HKQuantityTypeIdentifier ,completion: @escaping (Double) -> Void) {
        guard let stepQuantityType = HKQuantityType.quantityType(forIdentifier: type) else { return }

        let calendar = Calendar.current
        let startTime = calendar.startOfDay(for: date)
        let endTime = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)

        let predicate = HKQuery.predicateForSamples(withStart: startTime, end: endTime, options: .strictStartDate)

        if type == .walkingSpeed {
            let queryAvg = HKStatisticsQuery(quantityType: stepQuantityType, quantitySamplePredicate: predicate, options: .discreteMax) {  _, result, error in
                
                guard let result = result, let sum = result.averageQuantity() else {
                    completion(-11.0)
                    return
                }
                
                if type == .walkingAsymmetryPercentage {
                    completion(sum.doubleValue(for: HKUnit.percent()))
                }
                
                if type == .walkingSpeed {
                    completion(sum.doubleValue(for: HKUnit.meter()))
                }
            }
            healthStore.execute(queryAvg)
        } else {
            let query = HKStatisticsQuery(quantityType: stepQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                
                guard let result = result, let sum = result.sumQuantity() else {
                    completion(0) // when no data avaible for the day
                    return
                }
                
                if type == .stepCount {
                    completion(sum.doubleValue(for: HKUnit.count()))
                }
                
                if type == .distanceWalkingRunning {
                    completion(sum.doubleValue(for: HKUnit.meter()))
                }
                
                if type == .walkingAsymmetryPercentage {
                    completion(sum.doubleValue(for: HKUnit.percent()))
                }
            }
            healthStore.execute(query)
        }
        
        
    }

    func queryWidgetSteps(completion: @escaping (Double, Error?) -> Void){
        
        let stepQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)
         
        let date = Date()
        let calendar = Calendar.current
        let startTime = calendar.startOfDay(for: date)
        let endTime = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)
        
        let predicate = HKQuery.predicateForSamples(withStart: startTime, end: endTime, options: .strictStartDate)
        
        
        
        let query = HKStatisticsQuery(quantityType: stepQuantityType!, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0, error ?? nil)
                return
            }
            
            completion(sum.doubleValue(for: HKUnit.count()), error ?? nil)
        }
        
        healthStore.execute(query)
    }
    
    func getWorkouts(week: DateInterval, workout: HKSource, completion: @escaping (WorkoutDataPacked) -> Void) {        
        var predicate = HKQuery.predicateForObjects(from: .default())
        
        predicate = HKQuery.predicateForSamples(withStart: week.start, end: week.end)
        var data:[ChartData] = []
        let workoutQuery = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: 0, sortDescriptors: []) { (queryWorkout, workoutSamples, workoutError) in
            guard let workoutSamples = workoutSamples as? [HKWorkout], workoutError == nil else {
                return
            }
            
            let workouts:[Times] = workoutSamples.map { Times(startDate: $0.startDate, duration: $0.duration) }
            let dictionary = Dictionary(grouping: workouts, by: {  Calendar.current.date(byAdding: .hour, value: 2, to: Calendar.current.startOfDay(for: $0.startDate ))! })
            
            let test = dictionary.map { Times(startDate:  Calendar.current.date(byAdding: .hour, value: 12, to: $0.key)!, duration: $0.value.map({ $0.duration }).reduce(0, +) ) }.sorted { $0.startDate < $1.startDate }
            
            for workout in test.sorted(by: { $0.startDate < $1.startDate }) {
                data.append( ChartData(date: workout.startDate , value: workout.duration) )
            }
            
            let avg = data.count != 0 ? data.map{ Int($0.value) }.reduce(0, +) / data.count : 0
            
            let weekNr = Calendar.current.component(.weekOfYear, from: week.start)
            
            completion(WorkoutDataPacked(avg: avg, avgName: "Workout" , weekNr: weekNr, data: data))
            /*/// save workoutdata in Times array
            let workouts:[Times] = workoutSamples.map { Times(startDate: $0.startDate, duration: $0.duration) }
            let dictionary = Dictionary(grouping: workouts, by: {  Calendar.current.date(byAdding: .hour, value: 2, to: Calendar.current.startOfDay(for: $0.startDate ))! })
            self.waeringTimes = dictionary.map { Times(startDate: $0.key, duration: $0.value.map({ $0.duration }).reduce(0, +) ) }.sorted { $0.startDate < $1.startDate }*/
        }
        
      
        
        let healthStore = HKHealthStore()
        healthStore.execute(workoutQuery)
    }
    
    func getWorkoutsByDate(date: Date, workout: HKSource, completion: @escaping (Double) -> Void) {
        var predicate = HKQuery.predicateForObjects(from: .default())
        
        predicate = HKQuery.predicateForSamples(withStart: date.startEndOfDay().start, end: date.startEndOfDay().end)

        let workoutQuery = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: 0, sortDescriptors: []) { (queryWorkout, workoutSamples, workoutError) in
            guard let workoutSamples = workoutSamples as? [HKWorkout], workoutError == nil else {
                return
            }

            let workouts = workoutSamples.filter({ return Calendar.current.isDate($0.startDate , inSameDayAs: date) })

            let allDuration = workouts.map {  Double($0.duration)  }.reduce(0, +)
            
            completion(allDuration)
            /*/// save workoutdata in Times array
            let workouts:[Times] = workoutSamples.map { Times(startDate: $0.startDate, duration: $0.duration) }
            let dictionary = Dictionary(grouping: workouts, by: {  Calendar.current.date(byAdding: .hour, value: 2, to: Calendar.current.startOfDay(for: $0.startDate ))! })
            self.waeringTimes = dictionary.map { Times(startDate: $0.key, duration: $0.value.map({ $0.duration }).reduce(0, +) ) }.sorted { $0.startDate < $1.startDate }*/
        }
        
      
        
        let healthStore = HKHealthStore()
        healthStore.execute(workoutQuery)
    }
    
    func readHourlyTotalStepCount(date: Date, completion: @escaping ([StepsByHour]) ->  Void ) {
            guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
                fatalError("*** Unable to get the step count type ***")
            }
            
            var interval = DateComponents()
            interval.hour = 1
            
            let calendar = Calendar.current
            let anchorDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date)
            
            let query = HKStatisticsCollectionQuery.init(quantityType: stepCountType,
                                                         quantitySamplePredicate: nil,
                                                         options: .cumulativeSum,
                                                         anchorDate: anchorDate!,
                                                         intervalComponents: interval)
                
            var data: [StepsByHour] = []
        
            query.initialResultsHandler = { query, results, error in
                
                results?.enumerateStatistics(from: date.startEndOfDay().start,to:  date.startEndOfDay().end, with: { (result, stop) in
                    data.append(StepsByHour(start: result.startDate, end: result.endDate, count: result.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0))
                })
                
                completion(data)
            }
            
        
            healthStore.execute(query)
        }
}

struct StepsByHour {
    var start: Date
    var end: Date
    var count: Double
}

struct ChartDataPacked: Identifiable {
    var id = UUID()
    var avg: Int
    var avgName: String
    var weekNr: Int
    var data: [ChartData]
}

struct ChartData: Identifiable, Hashable {
    var id = UUID()
    var date: Date
    var value: Double
}


