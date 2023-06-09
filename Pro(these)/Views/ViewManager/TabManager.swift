//
//  TabManager.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 25.04.23.
//

import SwiftUI

class TabManager: ObservableObject {
    @Published var currentTab: Tab = .healthCenter // StartTab
    @Published var isSettingSheet: Bool = false
    
    @Published var workoutTab: WorkoutTab = .statistic
    @AppStorage("startTab") var startTab:Tab = .healthCenter
    
    @Published var animation:Bool = false
    @Published var blur:CGFloat = 0
    @Published var scale:CGFloat = 0
    @Published var x1:CGFloat = 0
    @Published var y1:CGFloat = 0
    @Published var x2:CGFloat = 0
    @Published var y2:CGFloat = 0
    
}
