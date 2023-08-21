//
//  AppTrailManager.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 09.08.23.
//

import SwiftUI

enum AppTrailManager {
    static var isInTrail: Bool {
        guard !AppFirstLaunchManager.isFirstLaunch else {
            return false
        }
        
        guard Date() < self.endFreeTrail else {
            return false
        }
        
        return true
    }
    
    static var hasProOrFreeTrail: Bool {
        guard AppConfig.shared.hasPro || isInTrail else {
            return false
        }
        
        return true
    }

    static var twoDayBeforeEndFreeTrail: Date {
        return Calendar.current.date(byAdding: .day, value: -2, to: self.endFreeTrail)!
    }
    
    static var endFreeTrail: Date {
        return Calendar.current.date(byAdding: .day, value: 14, to: AppFirstLaunchManager.launchDate ?? Date())!
    }
    
    static var freeTrailCountdown: Int {
        return Calendar.current.dateComponents([.day], from: Date(), to: self.endFreeTrail).day!
    }
    
}
