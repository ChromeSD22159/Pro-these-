//
//  FitnessView.swift
//  ProWatchOS Watch App
//
//  Created by Frederik Kohler on 10.05.23.
//

import SwiftUI
import HealthKit
import WidgetKit

struct FitnessView: View {
        
    @EnvironmentObject private var workoutManager: WorkoutManager
    @EnvironmentObject var stateManager: StateManager
    
    @AppStorage("TimerState", store: UserDefaults(suiteName: "group.FK.Pro-these-")) var isRunning: Bool = false
    @State var isTimerStateDate: Date = Date()

    var body: some View {
        VStack{
            
           
            if isRunning {
                // if timer runnig on the iPhone
                Spacer()
                
                Button(action: {
                    
                }, label: {
                    HStack {
                        Image("figure.prothese")
                            .imageScale(.large)
                            .font(.system(size: 30))
                            .foregroundColor(.yellow)
                            .padding(.trailing, 10)
                        
                        Text("Stop the timer on your iPhone.")
                            .font(.caption2)
                    }
                })
                .navigationBarTitle("Workouts")
                .navigationBarTitleDisplayMode(.inline)
                .disabled(true)
                
                Spacer()
            } else {
                // if timer not runnig on the iPhone
                if workoutManager.running {
                    // if timer runs on the watch
                    SessionTabView()
                } else {
                    // no timer runs
                    HStack {
                        Toggle("GPS recording:", isOn: $workoutManager.trackGPS)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        workoutManager.selectedWorkout = .walking
                    }, label: {
                        HStack {
                            Image("figure.prothese")
                                .imageScale(.large)
                                .font(.system(size: 30))
                                .foregroundColor(.yellow)
                                .padding(.trailing, 10)
                            
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
                }
            }
        }
        .sheet(isPresented: $workoutManager.showingSummaryView) {
            SummaryView()
        }
        .onChange(of: isRunning, perform: { newState in            
            if newState {
               // workoutManager.selectedWorkout = .walking
               // UserDefaults.standard.set(Date(), forKey: "TimerStateDate")
            }
        })
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


