//
//  WearingWeek.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 05.08.23.
//

import SwiftUI

struct WearingWeek: View {
        @EnvironmentObject var themeManager: ThemeManager
        
        @StateObject var healthStore = HealthStoreProvider()
        
        private var currentTheme: Theme {
            return self.themeManager.currentTheme()
        }
        
        var background: Color

        @State var totelWearingThisWeek: Int = 0
        
        @State var totelWearingLastWeek: Int = 0
        
        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                Text(LocalizedStringKey("The weekly wear time"))
                    .font(.body.bold())
                    .foregroundColor(currentTheme.text)
                
                Text(LocalizedStringKey("Compared to the previous week."))
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
                    let (h,m,_) = totelWearingThisWeek.secondsToHoursMinutesSeconds
                    Text("\(h == "00" ? "0" : h) hrs. \(m == "00" ? "0" : m ) mins.")
                        .font(.largeTitle.bold())
                }
            }
            .homeScrollCardStyle(currentTheme: currentTheme)
            .onAppear{
                getWorkouts(week: DateInterval(start: Date().startOfWeek(), end: Date().endOfWeek!))
            }
        }
    
        func getWorkouts(week: DateInterval) {
            let date = Date()

            let lastWeekDay: Date = Calendar.current.date(byAdding: .day, value: -7, to: date)!
            
            let lastWeek = DateInterval(start: lastWeekDay.startOfWeek(), end: lastWeekDay.endOfWeek!)
            
            healthStore.getWorkouts(week: week, workout: .default()) { workouts in
                DispatchQueue.main.async {
                    let totalWorkouts = workouts.data.map({ workout in
                        return Int(workout.value)
                    }).reduce(0, +)
                    
                    self.totelWearingThisWeek = totalWorkouts
                }
            }
            
            healthStore.getWorkouts(week: lastWeek, workout: .default()) { workouts in
                DispatchQueue.main.async {
                    let totalWorkouts = workouts.data.map({ workout in
                        return Int(workout.value)
                    }).reduce(0, +)
                    
                    self.totelWearingLastWeek = totalWorkouts
                }
            }
        }
    
        func calcDiffWearingTime() -> (seconds: Int, sign: String, percent: Double) {
            guard self.totelWearingThisWeek != 0 else {
                return (seconds: 0, sign: "", percent: 0)
            }
            
            guard self.totelWearingLastWeek != 0 else {
                return (seconds: 0, sign: "", percent: 0)
            }
            
            let difference:Double = Double(self.totelWearingThisWeek - self.totelWearingLastWeek)

            guard self.totelWearingThisWeek + self.totelWearingLastWeek != 0 else {
                return (seconds: 0, sign: "", percent: 0)
            }
            
            guard self.totelWearingLastWeek != 0 else {
                return (seconds: 100, sign: "+", percent: 100)
            }
            
            let percent = 100.0 / Double(abs(self.totelWearingLastWeek)) * difference // Double(abs(Int(self.avgTimeThisWeek)))

            return (seconds: abs(Int(difference)), sign: difference.sign == .minus ? "-" : "+", percent: abs(percent))
        }
    
    }


