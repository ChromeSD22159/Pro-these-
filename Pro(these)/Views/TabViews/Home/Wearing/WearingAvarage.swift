//
//  AvarageSteps.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 26.07.23.
//

import SwiftUI

struct WearingAvarage: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    @StateObject var healthStore = HealthStoreProvider()
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    var background: Color
    
    @State var StoredThisWeekWorkouts: [ChartData] = []
    
    @State var StoredLastWeekWorkouts: [ChartData] = []

    var avgTimeThisWeek: Int {
        let all = StoredThisWeekWorkouts.map({ Int($0.value) })
            
        guard all.sum != 0 else {
            return 0
        }
        
        return all.sum / self.dayOfWeekCount
    }
    
    var avgTimeLastWeek: Int {
        let all = StoredLastWeekWorkouts.map({ Int($0.value) })
        
        guard all.sum != 0 else {
            return 0
        }
        
        return all.sum / self.dayOfWeekCount
    }
    
    var dayOfWeekCount: Int {
        let day = Calendar.current.dayOfWeek
        return day == 0 ? 7 : day
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(LocalizedStringKey("Average wearing time this week")) 
                .font(.body.bold())
                .foregroundColor(currentTheme.text)
            
            Text(LocalizedStringKey("Comparison with the previous week."))
                .font(.caption2)
                .foregroundColor(currentTheme.text)
                .padding(.bottom, 6)
            
            HStack(alignment: .bottom) {
                
                HStack {
                    Text("\(calcDiffWearingTime().sign)\(String(format: "%.0f", calcDiffWearingTime().percent))%")
                        .font(.body.bold())
                        .foregroundColor(currentTheme.textBlack)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(background)
                .cornerRadius(20)
                
                
                Spacer()
                let (h,m,_) = secondsToHoursMinutesSeconds(avgTimeThisWeek)
                Text("Ø \(h == "00" ? "0" : h) hrs. \(m == "00" ? "0" : m ) mins.")
                    .font(.largeTitle.bold())
            }
            .onAppear{
                getSteps()
            }
        }
            .homeScrollCardStyle(currentTheme: currentTheme)
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (String, String, String) {
        let hour = String(format: "%02d", seconds / 3600)
        let minute = String(format: "%02d", (seconds % 3600) / 60)
        let second = String(format: "%02d", (seconds % 3600) % 60)
        return (hour, minute, second)
    }
    
    func getSteps() {
        let date = Date()
        
        let thisWeek = DateInterval(start: date.startOfWeek(), end: date.endOfWeek!)

        let lastweekDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: thisWeek.start)!
        
        healthStore.getWorkouts(week: thisWeek, workout: .default(), completion: { workouts in
            DispatchQueue.main.async {
                self.StoredThisWeekWorkouts = workouts.data
            }
        })
        
        healthStore.getWorkouts(week: DateInterval(start: lastweekDate.startOfWeek(), end: lastweekDate.endOfWeek!), workout: .default(), completion: { workouts in
            DispatchQueue.main.async {
                self.StoredLastWeekWorkouts = workouts.data
            }
        })
    }
    
    func calcDiffWearingTime() -> (seconds: Int, sign: String, percent: Double) {
        guard self.avgTimeLastWeek != 0 else {
            return (seconds: 0, sign: "", percent: 0)
        }
        
        guard self.avgTimeThisWeek != 0 else {
            return (seconds: 0, sign: "", percent: 0)
        }
        
        let difference:Double = Double(self.avgTimeThisWeek - self.avgTimeLastWeek)

        guard self.avgTimeThisWeek + self.avgTimeLastWeek != 0 else {
            return (seconds: 0, sign: "", percent: 0)
        }
        
        guard self.avgTimeLastWeek != 0 else {
            return (seconds: 100, sign: "+", percent: 100)
        }
        
        let percent = 100.0 / Double(abs(self.avgTimeLastWeek)) * difference // Double(abs(Int(self.avgTimeThisWeek)))

        return (seconds: abs(Int(difference)), sign: difference.sign == .minus ? "-" : "+", percent: abs(percent))
    }
}


extension Array<Int> {
    
    var sum: Int {
        return self.reduce(0) { accumulator, element in
            accumulator + element
        }
    }
    
}
