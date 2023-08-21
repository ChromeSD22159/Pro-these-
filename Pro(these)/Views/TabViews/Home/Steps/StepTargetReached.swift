//
//  StepTargetReached.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 05.08.23.
//

import SwiftUI

struct StepTargetReached: View {
    
    @StateObject var healthStore = HealthStoreProvider()
    
    @EnvironmentObject var themeManager: ThemeManager
    
    @EnvironmentObject var appConfig: AppConfig
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    var target: Int {
        return self.appConfig.targetSteps
    }
    
    @State var thisWeek: Int = 0
    
    @State var reachedCount: Int = 0
    
    @State var notReachedCount: Int = 0

    var percentWidth: CGFloat {
        guard thisWeek != 0 else {
            return 0
        }
        
        let screen = Double(self.screenWidth)

        let percent = self.percent
        
        // Calculate new difference width from the one in the screen
        let newScreen = screen / 100 * percent
        
        return newScreen
    }
    
    var percent: Double {
        let max: Double = Double(thisWeek)
        let percent: Double = 100

        guard thisWeek != 0 else {
           return 0
        }
        
        let res = percent / max * Double(reachedCount)
        
        return res
    }
    
    @State var animationWidth: CGFloat = 0

    @State var screenWidth:CGFloat = 0
    
    var startDate: Date
    
    var durationDays: Int
    
    var background: Color
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(LocalizedStringKey("Achieved step goals"))
                    .font(.body.bold())
                    .foregroundColor(currentTheme.text)

                Spacer()
            }
            
            HStack {
                Text(LocalizedStringKey("Did you reach your step goal in the last \(durationDays) days?"))
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
                
                SmilyStack()
                
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
            getSteps()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                
                withAnimation(.easeInOut) {
                    self.animationWidth = self.percentWidth
                }
           }
        }
        .onDisappear {
            self.thisWeek = 0
            self.reachedCount = 0
            self.notReachedCount = 0
            self.animationWidth = 0
        }
    }
    
    @ViewBuilder
    func PercentStack() -> some View {
        HStack {
            Spacer()
            
            Text("\( Int(percent) )%")
                .font(.headline.bold())
                .foregroundColor(background)
                .blendMode(.difference)
            
            Spacer()
        }
        .padding(.horizontal, 10)
    }
    
    @ViewBuilder
    func SmilyStack() -> some View {
        HStack {
            
            VStack(alignment: .center, spacing: 3) {
                Image(systemName: "star.slash.fill")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(background)
                    .blendMode(.difference)
                
                Text("\(notReachedCount)x")
                    .font(.caption2)
                    .foregroundColor(background)
                    .blendMode(.difference)
            }
            .padding(.leading, 10)
            
            Spacer()
            
            VStack(alignment: .center, spacing: 3) {
                Image(systemName: "star.fill")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(background)
                    .blendMode(.difference)
                
                Text("\(reachedCount)x")
                    .font(.caption2)
                    .foregroundColor(background)
                    .blendMode(.difference)
            }
            .padding(.trailing, 10)
        }
        .padding(.horizontal, 10)
    }
    
    func getSteps() {
        for i in 0..<durationDays {
            
            healthStore.queryDayCountbyType(date: Calendar.current.date(byAdding: .day, value: -i, to: self.startDate)!, type: .stepCount, completion: { steps in
                self.thisWeek += 1
                
                if Int(steps) > target {
                    self.reachedCount += 1
                } else {
                    self.notReachedCount += 1
                }
                
            })
            
        }

    }
}


