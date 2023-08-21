//
//  SettingSetStepTarget.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 27.04.23.
//

import SwiftUI

struct SettingSetStepTarget: View {

    @StateObject var appConfig = AppConfig()
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @Binding var targetSteps: Int
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 6) {
            Button("-", action: { targetSteps = targetSteps.reduceSteps })
                .frame(width: 20, height: 20)
                .padding(6)
                .foregroundColor(currentTheme.text)
                .background(currentTheme.text.opacity(0.1))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(currentTheme.text, lineWidth: 1)
                )
            
            Spacer()
            
            VStack{
                Text("\(targetSteps)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(currentTheme.text)
                
                Label("Daily Steps Goal", image: "figure.prothese")
                    .font(.body)
                    .fontWeight(.regular)
                    .foregroundColor(currentTheme.textGray)
            }
            
            Spacer()
            
            Button("+", action: { targetSteps = targetSteps.maximizeSteps })
                .frame(width: 20, height: 20)
                .padding(6)
                .foregroundColor(currentTheme.text)
                .background(currentTheme.text.opacity(0.1))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(currentTheme.text, lineWidth: 1)
                )
            
        }
        .padding(.all, 12)
        .frame(maxWidth: .infinity)
        .background(currentTheme.primary.opacity(0.5))
        .cornerRadius(10)
    }
    
    func reduceSteps(input: Int) {
        if appConfig.targetSteps >= 1500 {
            let newT = input - 500
            appConfig.targetSteps = newT
        }
    }
    
    func maximizeSteps(input: Int) {
        if appConfig.targetSteps <= 49500 {
            let newT = input + 500
            appConfig.targetSteps = newT
        }
    }
}
