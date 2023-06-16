//
//  AppConfig.swift
//  Pro Prothese
//
//  Created by Frederik Kohler on 23.04.23.
//

import SwiftUI
import Combine
import Foundation
import CoreLocation

class AppConfig: ObservableObject {
    
    static let shared = AppConfig()
    
    let minVersion: String = "0.0.1"

    var background          = Color(red: 32/255, green: 40/255, blue: 63/255)
    var foreground          = Color(red: 167/255, green: 178/255, blue: 210/255)
    var fontColor:Color     = .white
    var fontLight:Color     = .gray
    var backgroundLabel     = LinearGradient(colors: [Color(red: 32/255, green: 40/255, blue: 63/255)], startPoint: .top, endPoint: .bottom)
    var backgroundGradient  = LinearGradient(colors: [Color(red: 32/255, green: 40/255, blue: 63/255), Color(red: 4/255, green: 5/255, blue: 8/255)], startPoint: .top, endPoint: .bottom)
    var backgroundRadial    = RadialGradient(gradient: Gradient(colors: [ Color(red: 5/255, green: 5/255, blue: 15/255).opacity(0.7), Color(red: 5/255, green: 5/255, blue: 15/255).opacity(1) ]), center: .center, startRadius: 50, endRadius: 300)
    var backgroundGradientDark  = LinearGradient(colors: [Color(red: 5/255, green: 10/255, blue: 28/255), Color(red: 4/255, green: 5/255, blue: 19/255)], startPoint: .top, endPoint: .bottom)
    
    var gaugeGradientBad = LinearGradient(colors: [Color(red: 32/255, green: 40/255, blue: 63/255)], startPoint: .top, endPoint: .bottom)
    var gaugeGradientGood = LinearGradient(colors: [Color(red: 32/255, green: 40/255, blue: 63/255)], startPoint: .top, endPoint: .bottom)
    
    
    @AppStorage("Days") var fetchDays:Int = 7

    // MARK: PERSONAL
    /// Saves the Username
    @AppStorage("Username") var username = "Frederik"
    
    /// Saves the Username
    @AppStorage("UserPin") var userPin:String = ""
    
    /// Saves the daily Steptarget
    @AppStorage("targetSteps") var targetSteps = 10000
    /// Set the Entry Site
    @AppStorage("EntrySite") var entrySite:Tab = .event
    
    
    // MARK: SETTINGS StepsCount
    /// BarMarks - Shows a green bar when your daily target has been reached
    @AppStorage("ChartBarIsShowing") var ChartBarIsShowing = false
    /// LineMark - Show a red line Marker Stroke, with the daily distance
    @AppStorage("ChartLineDistanceIsShowing") var ChartLineDistanceIsShowing = false
    ///  LineMark - Show a white/blue line Marker Stroke, with the daily steps
    @AppStorage("ChartLineStepsIsShowing") var ChartLineStepsIsShowing = true
    
    ///  LineMark - Show mini Recorder on the StepCounterView
    @AppStorage("ShowRecordOnHomeView") var ShowRecordOnHomeView = true
    
    ///  LineMark - Show mini Recorder on the StepCounterView
    @AppStorage("ShowToDayRecordingPercentageToAvg") var ShowToDayRecordingPercentageToAvg = true
    
    
    
    /// BarMarks - Shows a yellow rulemark for Avarage Daildy Steps
    @AppStorage("stepRuleMark") var stepRuleMark = true
    
    /// Send Mood Reminder Notification
    @AppStorage("PushNotificationDailyMoodRemembering") var PushNotificationDailyMoodRemembering = true
    // Send no Notification
    @AppStorage("PushNotificationDisable") var PushNotificationDisable = false
    /// Send GoodMorning Notification
    @AppStorage("PushNotificationGoodMorning") var PushNotificationGoodMorning = true
    
    /// Live Notification
    @AppStorage("showLiveActivity") var showLiveActivity = true
    
    // MARK: SETTINGS Terminplaner
    @AppStorage("showPastEvents") var showPastEvents = true
    @AppStorage("showAllEvents") var showAllEvents = true
    
    
    @AppStorage("debug") var debug = false
    
    
    // MARK: - Global Strings
    /// Shows the App Name
    var AppName = "Pro Prothese"
    var EventTitelUnknown = "Prothese App - Unbekanter Termin"
    var ContactTitelUnknown = "Prothese App - Unbekanter Kontakt"
    
    
    
}

enum Theme: String, CaseIterable, Identifiable {
    case bubblegum
    case buttercup
    case indigo
    case lavender
    case magenta
    case navy
    case orange
    case oxblood
    case periwinkle
    case poppy
    case purple
    case seafoam
    case sky
    case tan
    case teal
    case yellow
    
    var accentColor: Color {
        switch self {
        case .bubblegum, .buttercup, .lavender, .orange, .periwinkle, .poppy, .seafoam, .sky, .tan, .teal, .yellow: return .black
        case .indigo, .magenta, .navy, .oxblood, .purple: return .white
        }
    }
    var mainColor: Color {
        Color(rawValue)
    }
    var name: String {
        rawValue.capitalized
    }
    var id: String {
        name
    }
}
