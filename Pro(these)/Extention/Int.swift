//
//  Int.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 18.07.23.
//

import SwiftUI

extension Int {
    var secondsToHoursMinutesSeconds: (String, String, String) {
        let hour = String(format: "%02d", self / 3600)
        let minute = String(format: "%02d", (self % 3600) / 60)
        let second = String(format: "%02d", (self % 3600) % 60)
        return (hour, minute, second)
    }
    
    var reduceSteps: Int {
        if self >= 1500 {
            return (self - 500)
        } else {
            return self
        }
    }
    
    var maximizeSteps: Int {
        if self <= 49500 {
            return (self + 500)
        } else {
            return self
        }
    }
}
