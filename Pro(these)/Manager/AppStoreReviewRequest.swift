//
//  AppStoreReviewRequest.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 09.08.23.
//

import SwiftUI
import StoreKit

enum AppStoreReviewRequest {
    
    static let threehold = 3
    
    @AppStorage("runsSinceLastRequest", store: AppConfig.store) static var runsSinceLastRequest = 0
    
    @AppStorage("storedVersion", store: AppConfig.store) static var storedVersion = ""
    
    @AppStorage("showedAppStoreReview", store: AppConfig.store) static var showedAppStoreReview: Bool = false
    
    static var requestReviewHandler: Bool {
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        runsSinceLastRequest += 1
        /*
        print("Run Count: \(runsSinceLastRequest)")
        print("AppVersion: \(appVersion)")
        print("StoredVersion: \(appVersion)")
         */
        guard Date() > AppTrailManager.twoDayBeforeEndFreeTrail else {
            //print("Dont Show Reqview in Trail")
            runsSinceLastRequest = 0
            return false
        }
        
        guard storedVersion != appVersion else {
            //print("theres no updates since Last Request")
            runsSinceLastRequest = 0
            return false
        }

        if runsSinceLastRequest >= threehold {
            //print("theres a new Version avaible to make a request for this version")
            storedVersion = appVersion
            runsSinceLastRequest = 0
            return true
        }
        
        //print("waiting for threshold for making Request")
        return false
    }
    
    static func checkRequestReview(complication: @escaping (Bool) -> Void) {
        if self.requestReviewHandler {
            Task {
                try await Task.sleep(
                    until: .now + .seconds(1),
                    tolerance: .seconds(0.5),
                    clock: .suspending
                )
                
                complication(true)
            }
        } else {
            complication(false)
        }
    }
}
