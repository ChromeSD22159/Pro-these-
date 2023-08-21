//
//  FeelingTrend.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 31.07.23.
//

import SwiftUI

struct StepTrend: View {
    
    @StateObject var healthStore = HealthStoreProvider()
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @State var firstDuration: [WeeklySteps] = []
    
    @State var secondDuration: [WeeklySteps] = []
    
    var avgfirstDuration: Double {
        
        let weeks = firstDuration.map { $0.steps }.count // 5
        
        let sum = firstDuration.map { $0.steps / 7 }.reduce(0, +)
        
        let avg = sum / Double(weeks)
        
        return avg
    }
    
    // FIXME: - BRAUCHT ES DAS?
    var avgSecondDuration: Double {

        let weeks = secondDuration.map { $0.steps }.count // 12
        
        let sum = secondDuration.map { $0.steps / 7 }.reduce(0, +)
        
        let avg = sum / Double(weeks)
        
        return avg
    }

    var percentWidth: CGFloat {
        let screen = Double(self.screenWidth)
        
        // if the last weeks and the weeks before are not available
        guard avgfirstDuration + avgSecondDuration != 0 else {
            return 0
        }
        
        // percent diffenrece, if more them 100 / 100
        let percent = abs(self.percent.difference) > 100 ? abs(self.percent.difference) / 10 : abs(self.percent.difference)
        
        // Calculate new difference width from the one in the screen
        let newScreen = screen / 100 * (percent / 2)
        
        let halfScreen = screen / 2
        
        return self.percent.sign == "-" ? (halfScreen - newScreen) : (halfScreen + newScreen)
    }
    
    @State var animationWidth: CGFloat = 0
    
    var percent: (sign: String, last: Double, current: Double, difference: Double) {
        let max: Double = avgSecondDuration
        let percent: Double = 100

        guard avgSecondDuration + avgfirstDuration != 0 else {
           return (sign: "" , last: 0, current: 0, difference: 0)
        }
        
        let calcFirstPeriode = percent / max * avgfirstDuration
        let calcSecondPeriode = percent / max * avgSecondDuration
        
        let difference = calcFirstPeriode - calcSecondPeriode
        
        return (sign: difference.sign == .minus ? "-" : "+" , last: calcSecondPeriode, current: calcFirstPeriode, difference: abs(difference))
    }

    @State var screenWidth:CGFloat = 0
    
    var weeks: (Int, Int)
    
    var background: Color
    
    var calulatedWeeks: Int {
        return weeks.0 + weeks.1
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(LocalizedStringKey("Step Trend"))
                    .font(.body.bold())
                    .foregroundColor(currentTheme.text)

                Spacer()
            }
            
            HStack {
                Text(LocalizedStringKey("Your step trend compared over the last \(calulatedWeeks) weeks."))
                    .font(.caption2)
                    .foregroundColor(currentTheme.text)
                    .padding(.bottom, 6)
                
                Spacer()
            }
            
            
                
            ZStack {
                
                Rectangle()
                    .fill(.gray.opacity(0.2))
                    .frame(width: screenWidth)
                    .cornerRadius(10)
                
                HStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    background.opacity(1),
                                    background.opacity(0.6)
                                ],
                                startPoint: .trailing,
                                endPoint: .leading
                            )
                        )
                        .frame(width: animationWidth)
                        .cornerRadius(10)
                    
                    Spacer()
                }
                
                MoodSmilyStack()
                
                PercentStack()
                
            }
            .frame(width: screenWidth, height: 50)
        }
        .background(GeometryReader { gp -> Color in
           DispatchQueue.main.async {
               self.screenWidth = gp.size.width
           }
            return Color.clear
       })
        .onAppear {
            getSteps(weeks: weeks)
            
            self.animationWidth = 0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                
                withAnimation(.easeInOut) {
                    self.animationWidth = self.percentWidth
                }
           }
        }
        .onDisappear {
            self.animationWidth = 0
        }
    }
    
    @ViewBuilder
    func PercentStack() -> some View {
        HStack {
            Spacer()
            
            Text("\(percent.sign) \( Int(percent.difference.isNaN ? 0 : percent.difference) )%")
                .font(.headline.bold())
                .foregroundColor(background)
                .blendMode(.difference)
            
            Spacer()
        }
        .padding(.horizontal, 10)
    }
    
    @ViewBuilder
    func MoodSmilyStack() -> some View {
        HStack {
            Image("figure.prothese")
                .font(.system(size: 25, weight: .black))
                .foregroundColor(background)
                .blendMode(.difference)
            
            Spacer()
            
            Image("figure.prothese.motion")
                .font(.system(size: 25, weight: .black))
                .foregroundColor(background)
                .blendMode(.difference)
        }
        .padding(.horizontal, 10)
    }
    
    func generateDateInterval(duration: Int, date: Date) -> DateInterval {
        let startDate = Calendar.current.date(byAdding: .weekOfYear, value: -duration, to: date)?.startWeek
        let endDate = date.endOfWeek!
        
        return DateInterval(start: startDate!, end: endDate)
    }
    
    func getSteps(weeks: (Int, Int)) {
        let firstDuration = generateDateInterval(duration: weeks.1, date: Date())
        let secondDuration = generateDateInterval(duration: weeks.0, date: Calendar.current.date(byAdding: .weekOfYear, value: -weeks.1, to: Date())!)
        
        // heut - 4w
        healthStore.queryAvgStepsforWeeks(dateInterval: firstDuration, type: .stepCount) { data in
            
            let converted = WeeklySteps(week: data.week, steps: data.totalSteps)
            
            DispatchQueue.main.async {
                if converted.week.start < Date() {
                    self.firstDuration.append(converted)
                }
            }
        }

        // -4w - 10w
        healthStore.queryAvgStepsforWeeks(dateInterval: secondDuration, type: .stepCount) { data in
            
            let converted = WeeklySteps(week: data.week, steps: data.totalSteps)
            
            DispatchQueue.main.async {
                if converted.week.start < Date() {
                    self.secondDuration.append(converted)
                }
            }
        }
    }
}

struct StepTrend_Previews: PreviewProvider {
    static var previews: some View {
        FeelingTrend(trendTyp: trendTyp.week)
    }
}

