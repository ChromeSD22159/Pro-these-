//
//  SettingMapping.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 27.04.23.
//

import SwiftUI
// MARK: DEV TESTING Items
struct MoreViewList: Identifiable {
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    var id: String { titel }
    var titel: String
    var backgroundGradient: LinearGradient
    var foregroundColor: Color
    
    static let items = [
        MoreViewList(titel: "Pedometer", backgroundGradient: AppConfig().backgroundGradient, foregroundColor: AppConfig().foreground),
        MoreViewList(titel: "Personal organizer", backgroundGradient: AppConfig().backgroundGradient, foregroundColor: AppConfig().foreground),
        MoreViewList(titel: "Timer", backgroundGradient: AppConfig().backgroundGradient, foregroundColor: AppConfig().foreground),
        MoreViewList(titel: "Liner", backgroundGradient: AppConfig().backgroundGradient, foregroundColor: AppConfig().foreground),
        MoreViewList(titel: "Planer", backgroundGradient: AppConfig().backgroundGradient, foregroundColor: AppConfig().foreground),
    ]
}

// MARK: Settings Items
struct Settings: Identifiable {
    var id = UUID()
    var titel: LocalizedStringKey
    var icon: String
    var options: [Options]
    
    static var items = [
        Settings( // checked
            titel: LocalizedStringKey("Pedometer"),
            icon: "figure.walk",
            options: [
                Options(titel: "1", icon: "exclamationmark.circle",  desc:  LocalizedStringKey("Show step goal"), info:  LocalizedStringKey("Show goal steps in chart background."), binding: AppConfig().$showTargetStepsOnChartBackground),
                Options(titel: "2", icon: "repeat.circle", desc:  LocalizedStringKey("View average daily steps"), info:  LocalizedStringKey("Show the average daily steps in the chart background."), binding: AppConfig().$showAvgStepsOnChartBackground),
                Options(titel: "3", icon: "repeat.circle", desc:  LocalizedStringKey("App badge"), info:  LocalizedStringKey("View currrent steps in app badge."), binding: AppConfig().$showBadgeSteps)
            ]),
        
        Settings( // checked
            titel: LocalizedStringKey("Personal organizer"),
            icon: "calendar",
            options: [
                Options(titel: "1", icon: "exclamationmark.circle",  desc: LocalizedStringKey("View all expired appointments"), info: LocalizedStringKey("All expired dates in the event list view."), binding: AppConfig().$showAllPastEvents),
                
                Options(titel: "2", icon: "exclamationmark.circle",  desc: LocalizedStringKey("View all expired appointments from the last week"), info: LocalizedStringKey("Show all expired appointments of the last week in the event list view."), binding: AppConfig().$showPastWeekEvents),
                //Options(titel: "2", icon: "repeat.circle", desc: LocalizedStringKey("Show all appointments sorted."), info:  LocalizedStringKey("Show all appointments sorted."), binding: AppConfig().$showAllEvents)
            ]),
       
        
        Settings( // new
            titel: LocalizedStringKey("Security"),
            icon: "lock.square",
            options: [
                Options(
                    titel: "1",
                    icon: "stopwatch",
                    desc: LocalizedStringKey("Protect your data with FaceID"),
                    info: LocalizedStringKey("Enable FaceID verification when launching the app."),
                    binding: AppConfig.shared.hasPro ? AppConfig.shared.$faceID : .constant(false) ,
                    inVisible: AppConfig.shared.hasPro ? false : true,
                    proFeature: true
                )
            ]),
        
        Settings( // checked
            titel: LocalizedStringKey("Notifications"),
            icon: "bell.and.waves.left.and.right",
            options: [
                Options(
                    titel: "1",
                    icon: "bell.and.waves.left.and.right",
                    desc:  LocalizedStringKey("Allow comeback reminder"),
                    info:  LocalizedStringKey("Reminds you daily to keep your data up to date in the app."),
                    binding: AppConfig.shared.hasPro ? AppConfig().$PushNotificationComebackReminder : .constant(true),
                    inVisible: AppConfig.shared.hasPro ? false : true,
                    proFeature: true
                ),
                Options(
                    titel: "2",
                    icon: "bell.and.waves.left.and.right",
                    desc:  LocalizedStringKey("Daily mood reminder push notification"), info:  LocalizedStringKey("Reminds you daily the set time, the day of your daily mood."),
                    binding: AppConfig.shared.hasPro ? AppConfig().$PushNotificationDailyMoodRemembering : .constant(true),
                    inVisible: AppConfig.shared.hasPro ? false : true,
                    proFeature: true
                ),
                Options(
                    titel: "3",
                    icon: "bell.and.waves.left.and.right",
                    desc: LocalizedStringKey("good morning wishes"),
                    info: LocalizedStringKey("Allow the app to wish you a good start to the day"),
                    binding: AppConfig.shared.hasPro ? AppConfig().$PushNotificationGoodMorning : .constant(true),
                    inVisible: AppConfig.shared.hasPro ? false : true,
                    proFeature: true
                ),
                Options(
                    titel: "4",
                    icon: "bell.and.waves.left.and.right",
                    desc: LocalizedStringKey("Weekly reports"),
                    info: LocalizedStringKey("Get notified when a new weekly report is available."),
                    binding: AppConfig.shared.hasPro ? AppConfig().$PushNotificationReports : .constant(true),
                    inVisible: AppConfig.shared.hasPro ? false : true,
                    proFeature: true
                )
            ]),
    ]
    
}

struct Options : Identifiable {
    var id: String { titel }
    var titel: String
    let icon: String
    var desc: LocalizedStringKey
    var info: LocalizedStringKey
    var binding: Binding<Bool>
    var inVisible: Bool?
    var proFeature: Bool?
}
