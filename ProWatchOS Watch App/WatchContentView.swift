//
//  ContentView.swift
//  ProWatchOS Watch App
//
//  Created by Frederik Kohler on 29.04.23.
//

import SwiftUI
import WatchKit
import HealthKit

struct WatchContentView: View {
    @EnvironmentObject private var workoutManager: WorkoutManager
    
    @Binding var deepLink:URL?
    
    //@State private var selectedTab:WatchTab = .steps
    
    var body: some View {
        NavigationStack {
            TabView {
                ChartView()
                    .tabItem {
                        Label("Chart", systemImage: "chart.bar.fill")
                    }
                    .navigationTitle("Pro Prothese")
                    .tag(WatchTab.steps.rawValue)
                
                FitnessView()
                    .tabItem {
                        Label("Tracking", systemImage: "figure.walk")
                    }
                    .navigationTitle("Pro Prothese Workout")
                    .tag(WatchTab.stopWatch.rawValue)
                
                if workoutManager.running {
                    NowPlayingView()
                        .tabItem {
                            Label("Now Playing", systemImage: "play")
                        }
                        .navigationTitle("Pro Prothese Workout")
                        .tag(WatchTab.nowPlaying.rawValue)
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear{
            
            workoutManager.requestAuthorization()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: {
                print("WatchContentView \(String(describing: deepLink))")
                
                if deepLink?.host != "stopWatch" {
                    withAnimation(.easeInOut) {
                        workoutManager.selectedTab = .stopWatch
                    }
                }
            })
        }
    }
}


struct WatchContentView_Previews: PreviewProvider {
    static var previews: some View {
        WatchContentView(deepLink: .constant(nil))
            .environment(\.locale, Locale(identifier: "de"))
    }
}

