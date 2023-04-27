//
//  ContentView.swift
//  Pro Prothese
//
//  Created by Frederik Kohler on 23.04.23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @EnvironmentObject private var tabManager: TabManager
    @EnvironmentObject private var healthStore: HealthStorage
    
    var body: some View {
        
        NavigationView {
            ZStack {
                AppConfig().backgroundGradient
                    .ignoresSafeArea()
                
                CircleAnimationInBackground(delay: 1, duration: 2)
                    .opacity(0.2)
                    .ignoresSafeArea()
                
                VStack(){
                    
                    switch tabManager.currentTab {
                    case .step: StepCounterView()
                    case .timer: StopWatchView()
                    case .map: LocationTracker()
                    case .more: MoreView()
                    }
                    
                    TabStack()
                }
                .foregroundColor(AppConfig().foreground)
                
            }
        }
    }
}