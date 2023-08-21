//
//  AmputeeCountDown.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 27.07.23.
//

import SwiftUI
struct AmputeeCountDowndateComponents: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    @EnvironmentObject var appConfig: AppConfig
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    var background: Color
    
    var DateComponents: DateComponents {
        return Calendar.current.dateComponents([.year, .month, .day], from: appConfig.amputationDate, to: Date())
    }
    
    var days: String {
        let diff = Calendar.current.dateComponents([.day], from: appConfig.amputationDate, to: Date())
        
        if let dayCount = diff.day {
            if dayCount == 1 {
                return "\(dayCount)d"
            } else {
                return "\(dayCount)d"
            }
        } else {
            return "0d"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(LocalizedStringKey("The time goes by so fast"))
                        .font(.body.bold())
                        .foregroundColor(currentTheme.text)
                    
                    Text(LocalizedStringKey("Find out how many days you've been amputee."))
                        .font(.caption2)
                        .foregroundColor(currentTheme.text)
                        .padding(.bottom, 6)
                }
                
                Spacer()

            }
          
            HStack(alignment: .bottom) {
                Text("\(DateComponents.year ?? 0) Yrs, \(DateComponents.month ?? 0) Mths, \(DateComponents.day ?? 0) Days")
                    .font(.headline.bold())
                
                Spacer()
                
                HStack {
                    Image(systemName: "hand.thumbsup.fill")
                        .font(.body.bold())
                        .foregroundColor(currentTheme.textBlack)
                        .padding(6)
                }
                .background(background)
                .cornerRadius(20)
            }
            
        }
    }
}

struct ProthesisCountDowndateComponents: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    @EnvironmentObject var appConfig: AppConfig
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    var background: Color
    
    var DateComponents: DateComponents {
        return Calendar.current.dateComponents([.year, .month, .day], from: appConfig.amputationDate, to: Date())
    }
    
    var days: String {
        let diff = Calendar.current.dateComponents([.day], from: appConfig.amputationDate, to: Date())
        
        if let dayCount = diff.day {
            if dayCount == 1 {
                return "\(dayCount) Day"
            } else {
                return "\(dayCount) Days"
            }
        } else {
            return "0 Days"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(LocalizedStringKey("Day counter since amputation"))
                    .font(.body.bold())
                    .foregroundColor(currentTheme.text)
                
                Spacer()
                
                HStack {
                    Text("\(days)")
                        .font(.body.bold())
                        .foregroundColor(currentTheme.textBlack)
                        .padding(6)
                }
                .background(background)
                .cornerRadius(20)
            }
          
            
            Text(LocalizedStringKey("Find out how many days you've been amputee."))
                .font(.caption2)
                .foregroundColor(currentTheme.text)
                .padding(.bottom, 6)
            
            HStack(alignment: .bottom) {

                Spacer()
                
                Text("\(DateComponents.year ?? 0) Yrs, \(DateComponents.month ?? 0) Mths, \(DateComponents.day ?? 0) Days")
                    .font(.largeTitle.bold())
                
                Spacer()
            }
            
        }
    }
}

struct AmputeeCountDownDays: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    @EnvironmentObject var appConfig: AppConfig
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    var background: Color
    
    var days: LocalizedStringKey {
        let diff = Calendar.current.dateComponents([.day], from: appConfig.amputationDate, to: Date())
        
        if let dayCount = diff.day {
            if dayCount == 1 {
                return LocalizedStringKey("\(dayCount) Day")
            } else {
                return LocalizedStringKey("\(dayCount) Days")
            }
        } else {
            return LocalizedStringKey("0 Days")
        }
    }
    
    @State var selectedView = 1
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(LocalizedStringKey("Amputated since \(appConfig.amputationDate.dateFormatte(date: "dd.MM.yyyy", time: "").date)"))
                .font(.body.bold())
                .foregroundColor(currentTheme.text)
            
            Text(LocalizedStringKey("Find out how many days you've been amputee."))
                .font(.caption2)
                .foregroundColor(currentTheme.text)
                .padding(.bottom, 6)
            
            HStack(alignment: .bottom) {
                HStack {
                    Text("since \(appConfig.amputationDate.dateFormatte(date: "dd.MM.yy", time: "").date)")
                        .font(.body.bold())
                        .foregroundColor(currentTheme.textBlack)
                        .padding(6)
                }
                .background(background)
                .cornerRadius(20)
                
                Spacer()
                
                Text(days)
                    .font(.headline.bold())
            }
            
            
        }
    }
}

struct AmputeeCountDownDays_Previews: PreviewProvider {
    static var previews: some View {
        AmputeeCountDownDays(background: .red)
    }
}
