//
//  FitnessView.swift
//  ProWatchOS Watch App
//
//  Created by Frederik Kohler on 10.05.23.
//

import SwiftUI
import HealthKit

struct FitnessView: View {
        
    @EnvironmentObject private var workoutManager: WorkoutManager

    var body: some View {
        VStack{
            if workoutManager.running {
                SessionTabView()
            } else {
                HStack {
                    Toggle("GPS Aufzeichnung:", isOn: $workoutManager.trackGPS)
                }
                
                Spacer()
                
                Button(action: {
                    workoutManager.selectedWorkout = .walking
                }, label: {
                    HStack {
                        Image("prothesis")
                            .imageScale(.large)
                            .font(.system(size: 30))
                            .foregroundColor(.yellow)
                        
                        Text("Start")
                            .font(.caption2)
                    }
                })
                .navigationBarTitle("Workouts")
                .navigationBarTitleDisplayMode(.inline)
                
                Button(action: {
                    withAnimation(.easeInOut) {
                        workoutManager.selectedTab = .steps
                    }
                }, label: {
                    Text("Statistic")
                })
                
                /*
                List {
                    
                    ForEach(workoutManager.workoutTypes) { workout in
                        Button(action: { workoutManager.selectedWorkout = workout }, label: { row(icon: workout.icon, text: workout.name) })
                    }
                    
                 } //: LIST
                 .listStyle(.carousel)
                 .navigationBarTitle("Workouts")
                 .navigationBarTitleDisplayMode(.inline)
                 .onAppear {
                     workoutManager.requestAuthorization()
                 }
                 */
            }
        }
        .sheet(isPresented: $workoutManager.showingSummaryView) {
            SummaryView()
        }
    }
    
    @ViewBuilder
    func row(icon: String, text: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.yellow)
            
            Text(text)
        }
    }
}

struct FitnessView_Previews: PreviewProvider {
    static var previews: some View {
        FitnessView()
            .environment(\.locale, Locale(identifier: "de"))
    }
}

extension HKWorkoutActivityType: Identifiable {
    public var id: UInt {
        rawValue
    }
    
    var name: String {
        switch self {
        case .cycling: return "Radfahren"
        case .walking: return "Gehen"
        case .running: return "Laufen"
        default: return "nil"
        }
    }
    
    var icon: String {
        switch self {
        case .cycling: return "bicycle"
        case .walking: return "figure.walk"
        case .running: return "figure.walk"
        default: return "figure.walk"
        }
    }
}
