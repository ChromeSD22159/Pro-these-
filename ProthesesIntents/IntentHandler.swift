//
//  IntentHandler.swift
//  ProthesesIntents
//
//  Created by Frederik Kohler on 11.10.23.
//

import Intents

class IntentHandler: INExtension, StartProthesenTimerIntentHandling, StopProthesenTimerIntentHandling {
    var appConfig = AppConfig.shared
    
    func handle(intent: StartProthesenTimerIntent) async -> StartProthesenTimerIntentResponse {
        if appConfig.recorderState == .started {
            appConfig.recorderState = .notStarted
        }
        
        if appConfig.recorderState == .notStarted {
            appConfig.recorderState = .started
            appConfig.recorderTimer = Date()
        }
        
        return StartProthesenTimerIntentResponse(code: .success, userActivity: nil)
    }
    
    func handle(intent: StopProthesenTimerIntent) async -> StopProthesenTimerIntentResponse {
        if appConfig.recorderState == .started { // end Timer
            appConfig.recorderState = .notStarted
        }
        
        if appConfig.recorderState == .notStarted { // start Timer
            appConfig.recorderState = .started
            appConfig.recorderTimer = Date()
        }
        
        return  StopProthesenTimerIntentResponse(code: .success, userActivity: nil)
    }
}
