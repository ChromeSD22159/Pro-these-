//
//  workOutManager.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 11.05.23.
//

import Foundation
import HealthKit
import CoreLocation
import Combine
import MapKit

class WorkoutManager: NSObject, ObservableObject {
    // Init
    static let shared = WorkoutManager()
    
    let healthStore = HKHealthStore()
    
    func setUpHealthRequest(healthStore: HKHealthStore, readSteps: @escaping () -> Void) {
        if HKHealthStore.isHealthDataAvailable(), let stepCount = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) {
            healthStore.requestAuthorization(toShare: [stepCount], read: [stepCount]) { success, error in
                if success {
                    readSteps()
                }
            }
        }
    }
    
    
    
    
    
    // fetched Workouts from healt
    var workouts: [Workout] = []
    var sortedWorkouts: [Workout]  {
        let filter = workouts.filter { self.isSameDay(date1: $0.startDate, date2: self.currentDay) }
        return filter.sorted {  $0.startDate > $1.startDate  }
    }
    var sortedTotalTime: Int {
        let sumTime = self.sortedWorkouts.map { $0.duration }.reduce(0, +)
        return Int(sumTime)
    }
    
    
    
    
    // Map States
    @Published var routeLocations: [CLLocation]?
    @Published var region: MKCoordinateRegion?
    
    
    
    
  
    // wearingTimes from Workouts
    var waeringTimes: [Times] = []
    var waeringTimesAvgTimes: Int {
        let days = waeringTimes.count
        let secs = waeringTimes.map { $0.duration }.reduce(0,+)
        
        guard days != 0 else {
            return 0
        }
        let avg = (Int(secs) / days)
        return avg
    }
    
    // Global
    @Published var currentDay: Date = Date()
    @Published var devideSizeWidth: CGFloat = 0


    
    /// Load all workouts from this app and save all workouts in wearingTimes array
    func getWorkouts(week: DateInterval, workout: HKSource, completion: @escaping (WorkoutDataPacked) -> Void) {
        self.workouts.removeAll(keepingCapacity: true)
        
        var predicate = HKQuery.predicateForObjects(from: .default())
        
        predicate = HKQuery.predicateForSamples(withStart: week.start, end: week.end)
        var data:[ChartData] = []
        let workoutQuery = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: 0, sortDescriptors: []) { (queryWorkout, workoutSamples, workoutError) in
            guard let workoutSamples = workoutSamples as? [HKWorkout], workoutError == nil else {
                return
            }
            
           // workoutSamples.map{
                //data.append(Workout(startDate: $0.startDate, endDate: $0.endDate, duration: $0.duration, workout: $0, workoutRouteSample: nil, route: nil))
           // }
            
            let workouts:[Times] = workoutSamples.map { Times(startDate: $0.startDate, duration: $0.duration) }
            let dictionary = Dictionary(grouping: workouts, by: {  Calendar.current.date(byAdding: .hour, value: 2, to: Calendar.current.startOfDay(for: $0.startDate ))! })
            let test = dictionary.map { Times(startDate: $0.key, duration: $0.value.map({ $0.duration }).reduce(0, +) ) }.sorted { $0.startDate < $1.startDate }
            
            for workout in test.sorted(by: { $0.startDate < $1.startDate }) {
                data.append( ChartData(date: Calendar.current.date(byAdding: .hour, value: 12, to: workout.startDate)! , value: workout.duration) )
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
  
    func getRouteFrom(workout: HKWorkout, completion: @escaping (_ region: MKCoordinateRegion, _ location: [CLLocation]) -> Void) {
            let mapDisplayAreaPadding = 1.3

            let runningObjectQuery = HKQuery.predicateForObjects(from: workout)

            let routeQuery = HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: runningObjectQuery, anchor: nil, limit: HKObjectQueryNoLimit) { [self] (query, samples, deletedObjects, anchor, error) in

                guard error == nil else {
                    fatalError("The initial query failed.")
                }
                // Make sure you have some route samples
                guard samples!.count > 0 else {
                    return
                }

                let route = samples?.first as! HKWorkoutRoute
  
                // Create the route query from HealthKit.
                let query = HKWorkoutRouteQuery(route: route) { (query, locationsOrNil, done, errorOrNil) in
                    // This block may be called multiple times.
                    if let error = errorOrNil {
                        print("Error \(error.localizedDescription)")
                        return
                    }

                    guard let locations = locationsOrNil else {
                        fatalError("*** NIL found in locations ***")
                    }
                    
                    let latitudes = locations.map {
                        $0.coordinate.latitude
                    }
                    let longitudes = locations.map {
                        $0.coordinate.longitude
                    }
                    
                    // Outline map region to display
                    guard let maxLat = latitudes.max() else { fatalError("Unable to get maxLat") }
                    guard let minLat = latitudes.min() else { return }
                    guard let maxLong = longitudes.max() else { return }
                    guard let minLong = longitudes.min() else { return }

                    if done {
                        let mapCenter = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLong + maxLong) / 2)
                        let mapSpan = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * mapDisplayAreaPadding,
                                                      longitudeDelta: (maxLong - minLong) * mapDisplayAreaPadding)

                        DispatchQueue.main.async {
                            // Push to main thread to drop dots on the map.
                            // Without this a warning will occur.
                        }
                        
                        self.region = MKCoordinateRegion(center: mapCenter, span: mapSpan)
                        self.routeLocations = locations
                        
                        completion( MKCoordinateRegion(center: mapCenter, span: mapSpan), locations )
                    }
                    // stop the query by calling:
                    // store.stop(query)
                }
                healthStore.execute(query)
            }

            healthStore.execute(routeQuery)
        }
}


// global extension
extension WorkoutManager {    
    func isSameDay(date1: Date, date2: Date) -> Bool {
        let diff = Calendar.current.dateComponents([.year], from: date1, to: date2)
        if diff.day == 0 {
            return true
        } else {
            return false
        }
    }
    
}
