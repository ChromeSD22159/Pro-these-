//
//  healthStoreProvider.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 19.05.23.
//

import Foundation
import HealthKit

class HealthStoreProvider: NSObject, ObservableObject {
    
    let healthStore = HKHealthStore()
    
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
                }
            }
        }
    }
    
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
            completion(success)
        }
    }
    
    func authorizationStatus(completion: @escaping (_ success: Bool) -> Void) {
        
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
        
        HKHealthStore().requestAuthorization(toShare: typesToShare, read: typesToRead, completion: { state, erro in
            if (state) {
                completion(true)
            } else {
               completion(false)
            }
            
        })
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
                           name = "Schritte"
                       }
                       
                       if type == .distanceWalkingRunning {
                           let value = quantity.doubleValue(for: .meter())
                           data.append( ChartData(date: date, value: value) )
                           name = "Distanz"
                           
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
    
    func queryDayCountbyType(date: Date, type: HKQuantityTypeIdentifier ,completion: @escaping (Double) -> Void) {
        guard let stepQuantityType = HKQuantityType.quantityType(forIdentifier: type) else { return }

        let calendar = Calendar.current
        let startTime = calendar.startOfDay(for: date)
        let endTime = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)

        let predicate = HKQuery.predicateForSamples(withStart: startTime, end: endTime, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            
            if type == .stepCount {
                completion(sum.doubleValue(for: HKUnit.count()))
            }
            
            if type == .distanceWalkingRunning {
                completion(sum.doubleValue(for: HKUnit.meter()))
            }
        }
        
        healthStore.execute(query)
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


