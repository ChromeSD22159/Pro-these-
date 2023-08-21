//
//  NotificationByDate.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 14.08.23.
//

import SwiftUI

struct NotificationByDate {
    var identifier: String
    var title: String
    var body: String
    var triggerHour: Int
    var triggerMinute: Int
    var repeater: Bool
    var url: String
    var userInfo: [String : String]?
}
