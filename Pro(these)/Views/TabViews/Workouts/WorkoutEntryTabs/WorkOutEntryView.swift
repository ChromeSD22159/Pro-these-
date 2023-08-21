//
//  WorkOutEntryView.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 19.05.23.
//

import SwiftUI

struct WorkOutEntryView: View {
    @EnvironmentObject var tabManager: TabManager
    @EnvironmentObject var workoutStatisticViewModel: WorkoutStatisticViewModel
    @EnvironmentObject var cal: MoodCalendar
    @EnvironmentObject var entitlementManager: EntitlementManager
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var ads: AdsViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @StateObject var healthStore = HealthStoreProvider()
    
    @State var healthTab: WorkoutTab?
    @State var isScreenShotSheet = false
    
    @State var stepCount: Double = 0
    @State var distanceCount: Double = 0
    @State var workoutSeconds: Double = 0
    
    var body: some View {
        GeometryReader { screen in
           
            ZStack{
                
                VStack(spacing: 20) {
                    
                    HStack(){
                        VStack(spacing: 2){
                            sayHallo(name: AppConfig.shared.username)
                                .font(.title2)
                                .foregroundColor(currentTheme.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Your daily goal for today is \(AppConfig.shared.targetSteps) steps.")
                                .font(.caption2)
                                .foregroundColor(currentTheme.textGray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        HStack(spacing: 20){
                            
                            if !entitlementManager.hasPro {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(currentTheme.text)
                                    .font(.title3)
                                    .onTapGesture {
                                        DispatchQueue.main.async {
                                            tabManager.ishasProFeatureSheet.toggle()
                                        }
                                    }
                            }
                             
                            if tabManager.workoutTab == .feelings {
                                Image(systemName: cal.isCalendar ? "calendar" : "list.bullet.below.rectangle")
                                    .foregroundColor(currentTheme.text)
                                    .font(.title3)
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.5)){
                                            cal.isCalendar.toggle()
                                        }
                                    }
                            }
                            if tabManager.workoutTab == .statistic {
                                Image(systemName: "camera")
                                    .foregroundColor(currentTheme.text)
                                    .font(.title3)
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.5)){
                                            isScreenShotSheet.toggle()
                                        }
                                    }
                            }
                            
                            Image(systemName: "gearshape")
                                .foregroundColor(currentTheme.text)
                                .font(.title3)
                                .onTapGesture {
                                    tabManager.isSettingSheet.toggle()
                                }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)

                    
                    newStepPreview()
                    
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            // MARK: - Delete Reason & Drugs
            .blurredOverlaySheet(.init(.ultraThinMaterial), show: $isScreenShotSheet, onDismiss: {
                // Show InterstitialSheet if not Pro
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    if !appConfig.hasPro {
                           ads.showInterstitial.toggle()
                    }
                })
            }, content: {
                SnapShotView(sheet: $isScreenShotSheet, steps: stepCount, distance: "\( String(format: "%.1f", distanceCount / 1000 ) )km", date: Date())
            })
            .onAppear{
                healthStore.queryDayCountbyType(date: Date(), type: .stepCount) { steps in
                    DispatchQueue.main.async {
                        self.stepCount = steps
                    }
                }
                healthStore.queryDayCountbyType(date: Date(), type: .distanceWalkingRunning) { steps in
                    DispatchQueue.main.async {
                        self.distanceCount = steps
                    }
                }
                healthStore.getWorkoutsByDate(date: Date(), workout: .default(), completion: { seconds in
                    DispatchQueue.main.async {
                        self.workoutSeconds = seconds
                    }
                })
            }
           
        }
    }
}
