//
//  HandlerStates.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 16.08.23.
//

import SwiftUI

class HandlerStates: ObservableObject {
    static var shared = HandlerStates()
    
    @AppStorage("msgDeepLink", store: AppConfig.store) var msgDeepLink = ""
    
    @AppStorage("storedSteps", store: AppConfig.store) var storedSteps = 0
    
    @AppStorage("storedStepsDate", store: AppConfig.store) var storedStepsDate:Date = Date()

    @AppStorage("sendReachedHalfTargetStepsNotificationDate", store: AppConfig.store) var sendReachedHalfTargetStepsNotificationDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!

    @AppStorage("sendReachedFullTargetStepsNotificationDate", store: AppConfig.store) var sendReachedFullTargetStepsNotificationDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    
    @AppStorage("LastLaunchDate", store: AppConfig.store) var LastLaunchDate: Date = Date()

    @AppStorage("firstLaunch", store: AppConfig.store) var firstLaunch: Launch = .notLaunchedbefore
  
    @AppStorage("firstLaunchDate", store: AppConfig.store) var firstLaunchDate: Date = Date()
    
    @AppStorage("showBadgeSteps", store: AppConfig.store) static var showBadgeSteps = false
    @AppStorage("badgeStepsDate", store: AppConfig.store) static var badgeStepsDate = Date()
    
    @AppStorage("weeklyProgressReportNotification", store: AppConfig.store) var weeklyProgressReportNotification: Date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    
    // DEBUG STATES
    @AppStorage("DEBUGStepProvider", store: AppConfig.store) var DEBUGStepProvider = false
    @AppStorage("DEBUGStepProviderErrors", store: AppConfig.store) var DEBUGStepProviderErrors = false
    @AppStorage("DEBUGBG_Tasks", store: AppConfig.store) var DEBUGBG_Tasks = false
    @AppStorage("DEBUGAppDelegateTrigger", store: AppConfig.store) var DEBUGAppDelegateTrigger = false
}
