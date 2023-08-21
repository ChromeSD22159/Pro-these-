//
//  StepsToday.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 05.08.23.
//

import SwiftUI

struct StepsToday: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    @StateObject var healthStore = HealthStoreProvider()
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    var background: Color
    
    @State var todaySteps: Double = 0
    
    var targetSteps: Double {
        return Double(AppConfig.shared.targetSteps)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(LocalizedStringKey("Your steps today"))
                .font(.body.bold())
                .foregroundColor(currentTheme.text)
            
            Text(LocalizedStringKey("Compare the steps you have taken with your daily goal."))
                .font(.caption2)
                .foregroundColor(currentTheme.text)
                .padding(.bottom, 6)
            
            HStack(alignment: .bottom) {
               
                HStack(spacing: 6) {
                    Text("\(calcDiffSteps().sign)\(String(format: "%.0f", calcDiffSteps().percent))%")
                        .font(.body.bold())
                        .foregroundColor(currentTheme.textBlack)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(background)
                .cornerRadius(20)
                
                Spacer()
                
                Text("\(Double(todaySteps).seperator) Steps")
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

        healthStore.queryDayCountbyType(date: date, type: .stepCount, completion: { stepCount in
            DispatchQueue.main.async {
                self.todaySteps = stepCount
            }
        })
    }
    
    func calcDiffSteps() -> (steps: Int, sign: String, percent: Double) {
        guard self.todaySteps != 0 else {
            return (steps: 0, sign: "", percent: 0)
        }
        
        guard self.targetSteps != 0 else {
            return (steps: 0, sign: "", percent: 0)
        }
        
        let differrence:Double = Double(self.todaySteps -  self.targetSteps)

        guard self.todaySteps + self.targetSteps != 0 else {
            return (steps: 0, sign: "", percent: 0)
        }
        
        let percent = 100 / Double(abs(self.targetSteps)) * differrence //  Double(abs(Int(self.avgStepsThisWeek)))
        
        return (steps: abs(Int(differrence)), sign: differrence.sign == .minus ? "-" : "+", percent: Double(abs(percent)))
    }
}


