//
//  AvarageSteps.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 26.07.23.
//

import SwiftUI

struct StepsAvarage: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    @StateObject var healthStore = HealthStoreProvider()
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    var background: Color
    
    @State var avgStepsThisWeek: Int = 0
    @State var avgStepsLastWeek: Int = 0
    @State var percentValue : Int = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(LocalizedStringKey("Average Daily Steps")) 
                .font(.body.bold())
                .foregroundColor(currentTheme.text)
            
            Text(LocalizedStringKey("Comparison with the week before."))
                .font(.caption2)
                .foregroundColor(currentTheme.text)
                .padding(.bottom, 6)
            
            HStack(alignment: .bottom) {
               
                HStack {
                    Text("\(calcDiffSteps().sign)\(String(format: "%.0f", calcDiffSteps().percent))%")
                        .font(.body.bold())
                        .foregroundColor(currentTheme.textBlack)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(background)
                .cornerRadius(20)
                
                Spacer()
                
                Text("Ø \(Double(avgStepsThisWeek).seperator) Steps")
                    .font(.largeTitle.bold())
            }
            .onAppear{
                getSteps()
            }
        }
        .homeScrollCardStyle(currentTheme: currentTheme)
    }
    
    func getSteps() {
        let date = Date()
        
        let thisWeek = DateInterval(start: date.startOfWeek(), end: date.endOfWeek!)
        
        let lastweekDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: thisWeek.start)!

        healthStore.queryWeekCountbyType(week: thisWeek, type: .stepCount, completion: { stepCount in
            DispatchQueue.main.async {
                self.avgStepsThisWeek = stepCount.avg
            }
        })
        
        healthStore.queryWeekCountbyType(week: DateInterval(start: lastweekDate.startOfWeek(), end: lastweekDate.endOfWeek!), type: .stepCount, completion: { stepCount in
            DispatchQueue.main.async {
                self.avgStepsLastWeek = stepCount.avg
            }
        })
    }
    
    func calcDiffSteps() -> (steps: Int, sign: String, percent: Double) {
        guard self.avgStepsLastWeek != 0 else {
            return (steps: 0, sign: "", percent: 0)
        }
        
        guard self.avgStepsThisWeek != 0 else {
            return (steps: 0, sign: "", percent: 0)
        }
        
        let differrence:Double = Double(self.avgStepsThisWeek -  self.avgStepsLastWeek)

        guard self.avgStepsThisWeek + self.avgStepsLastWeek != 0 else {
            return (steps: 0, sign: "", percent: 0)
        }
        
        let percent = 100 / Double(abs(self.avgStepsLastWeek)) * differrence //  Double(abs(Int(self.avgStepsThisWeek)))
        
        return (steps: abs(Int(differrence)), sign: differrence.sign == .minus ? "-" : "+", percent: Double(abs(percent)))
    }
}

