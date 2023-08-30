//
//  WearingToday.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 05.08.23.
//

import SwiftUI

struct WearingToday: View {
        @EnvironmentObject var themeManager: ThemeManager
        
        @StateObject var healthStore = HealthStoreProvider()
        
        private var currentTheme: Theme {
            return self.themeManager.currentTheme()
        }
        
        var background: Color
        
    
        @State var workoutSecondsYesterday: Double  = 0
    
        @State var workoutSecondsToday: Double = 0
        
        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
              
                Text(LocalizedStringKey("Today's wearing time"))
                    .font(.body.bold())
                    .foregroundColor(currentTheme.text)
                
                Text(LocalizedStringKey("Comparison with yesterday."))
                    .font(.caption2)
                    .foregroundColor(currentTheme.text)
                    .padding(.bottom, 6)
                
                HStack(alignment: .bottom) {
                    
                    HStack(spacing: 6) {
                        Text("\(calcDiffWearingTime().sign)\(String(format: "%.0f", calcDiffWearingTime().percent))%")
                            .font(.body.bold())
                            .foregroundColor(currentTheme.textBlack)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(background)
                    .cornerRadius(20)
                    
                    
                    Spacer()
                    let (h,m,_) = secondsToHoursMinutesSeconds(Int(workoutSecondsToday))
                    Text("\(h == "00" ? "0" : h) hrs. \(m == "00" ? "0" : m ) mins.")
                        .font(.largeTitle.bold())
                }
            }
            .homeScrollCardStyle(currentTheme: currentTheme)
            .onAppear{
                getWorkouts()
            }
        }
    
        func secondsToHoursMinutesSeconds(_ seconds: Int) -> (String, String, String) {
            let hour = String(format: "%02d", seconds / 3600)
            let minute = String(format: "%02d", (seconds % 3600) / 60)
            let second = String(format: "%02d", (seconds % 3600) % 60)
            return (hour, minute, second)
        }
    
        func getWorkouts() {
            let date = Date()

            let yesterday: Date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
            
            healthStore.getWorkoutsByDate(date: date, workout: .default(), completion: { seconds in
                DispatchQueue.main.async {
                    self.workoutSecondsToday = seconds
                }
            })
            
            healthStore.getWorkoutsByDate(date: yesterday, workout: .default(), completion: { seconds in
                DispatchQueue.main.async {
                    self.workoutSecondsYesterday = seconds
                }
            })
        }
    
        func calcDiffWearingTime() -> (seconds: Int, sign: String, percent: Double) {
            
            let difference:Double = Double(self.workoutSecondsToday - self.workoutSecondsYesterday)

            guard self.workoutSecondsToday + self.workoutSecondsYesterday != 0 else {
                return (seconds: 0, sign: "", percent: 0)
            }

            guard self.workoutSecondsYesterday != 0 else {
                return (seconds: 100, sign: "+", percent: 100)
            }
            
            let percent = 100.0 / Double(abs(self.workoutSecondsYesterday)) * difference // Double(abs(Int(self.avgTimeThisWeek)))
            
            return (seconds: abs(Int(difference)), sign: difference.sign == .minus ? "-" : "+", percent: abs(percent))
        }
    
    }

