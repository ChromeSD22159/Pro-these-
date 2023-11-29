//
//  TabStack.swift
//  Pro Prothese
//
//  Created by Frederik Kohler on 23.04.23.
//

import SwiftUI

struct TabStack: View {
    @Namespace var TabbarAnimation
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject private var tabManager: TabManager
    @EnvironmentObject var cal: MoodCalendar
    @EnvironmentObject var event: EventManager
    @EnvironmentObject var pain: PainViewModel
    @EnvironmentObject var wsvm: WorkoutStatisticViewModel
    @EnvironmentObject var loginViewModel: LoginViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    @StateObject var stopWatchProvider = StopWatchProvider()
    
    @Binding var deepLink:URL?
    
    @Binding var activeTab:Tab
    @Binding var activeSubTab:SubTab
    @Binding var showSubTab:Bool

    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    var body: some View {
        ZStack {
            // SubTab
            HStack(spacing: 20) {
                Image(systemName: SubTab.feeling.TabIcon())
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(activeSubTab == .feeling ? .yellow : .yellow.opacity(0.8))
                    .frame(width: 28, height: 28)
                    .onTapGesture{
                        haptic()
                        newFeeling(moodCalendar: cal, tabManager: tabManager, showSubTab: $showSubTab, activeTab: $activeTab)
                    }
                
                Image(systemName: SubTab.stopWatch.TabIcon())
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(activeSubTab == .stopWatch ? .yellow : .yellow.opacity(0.8))
                    .frame(width: 28, height: 28)
                    .offset(y: -20)
                    .onTapGesture{
                        haptic()
                        startStopWatch(stopWatchProvider: stopWatchProvider, showSubTab: $showSubTab, activeTab: $activeTab)
                    }
                
                Image(systemName: SubTab.pain.TabIcon())
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(activeSubTab == .pain ? .yellow : .yellow.opacity(0.8))
                    .frame(width: 28, height: 28)
                    .offset(y: -20)
                    .onTapGesture{
                        haptic()
                        newPain(painViewModel: pain, showSubTab: $showSubTab, activeTab: $activeTab)
                    }
                
                Image(systemName: SubTab.event.TabIcon())
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(activeSubTab == .event ? .yellow : .yellow.opacity(0.8))
                    .frame(width: 28, height: 28)
                    .onTapGesture{
                        haptic()
                        newEvent(eventManager: event, showSubTab: $showSubTab, activeTab: $activeTab)
                    }
            }
            .padding(.bottom)
            .opacity(showSubTab ? 1 : 0)
            .offset(y: showSubTab ? -70 : 100)
            
            // MainTab
            HStack(spacing: 6){
                ForEach(Tab.allCases, id: \.self){ tab in
                    
                    VStack {
                        if tab == .add {
                            ZStack{
                                Circle()
                                    .fill(LinearGradient(colors: [currentTheme.text.opacity(1), currentTheme.text.opacity(0.15), currentTheme.text.opacity(0.05)], startPoint: .top, endPoint: .bottom))
                                    .background{
                                        
                                    }
                                    .frame(width: 45, height: 45)
                                
                                Circle()
                                    .fill(currentTheme.hightlightColor)
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: tab.TabIcon())
                                    .renderingMode(.template)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.black)
                                    .frame(width: 20, height: 20)
                            }
                            .offset(y: tab == .add ? -20 : 0 )
                        } else {
                            Image(systemName: tab.TabIcon())
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(activeTab == tab ? .white : .white.opacity(0.8))
                                .frame(width: 20, height: 20)
                        }
                        
                        if activeTab == tab {
                            Circle()
                                .fill(.white)
                                .frame(width:5, height: 5)
                                .offset(y: 10)
                                .matchedGeometryEffect(id: "TAB", in: TabbarAnimation)
                        }
                    }
                    .onTapGesture {
                        haptic()
                        
                        // Add Button
                        if tab == .add {
                            withAnimation(.easeInOut(duration: 0.3)){
                                showSubTab.toggle()
                            }
                        } else if tab == .healthCenter {
                            withAnimation(.easeInOut(duration: 0.3)){
                                activeTab = tab
                                showSubTab = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                tabManager.workoutTab = .statistic
                                cal.isCalendar = true
                                wsvm.currentDay = Date()
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 0.3)){
                                activeTab = tab
                                showSubTab = false
                            }
                        }
                        
                    }
                    
                   
                }
                .frame(maxWidth: .infinity)
                
            }
            .frame(maxWidth: .infinity)
            .padding(10)
           // .background(AppConfig().backgroundLabel.opacity(0.1))
        }
        .onAppear{
            print("tabstack \(String(describing: deepLink))")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: {
                if deepLink?.host == "showFeeling" {
                    tabManager.workoutTab = .feelings
                    withAnimation(.easeInOut(duration: 0.8)){
                        self.showSubTab = false
                        self.activeTab = .feeling
                        cal.isCalendar = true
                        cal.addFeelingDate = Date()
                    }
                } else if deepLink?.host == "addFeeling" {
                    newFeeling(moodCalendar: cal, tabManager: tabManager, showSubTab: $showSubTab, activeTab: $activeTab)
                } else if deepLink?.host == "pain" {
                    newPain(painViewModel: pain, showSubTab: $showSubTab, activeTab: $activeTab)
                } else if deepLink?.host == "stopWatch" {
                    startStopWatch(stopWatchProvider: stopWatchProvider, showSubTab: $showSubTab, activeTab: $activeTab)
                } else if deepLink?.host == "statistic" {
                    tabManager.workoutTab = .statistic
                }
            })
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .inactive {
                self.showSubTab = false
                cal.isFeelingSheet = false
                pain.isPainAddSheet = false
            } else if newPhase == .background {
                self.showSubTab = false
                cal.isFeelingSheet = false
                pain.isPainAddSheet = false
            }
        }
        .borderGradient(
            width: 1,
            edges: [.top],
            linearGradient:
                LinearGradient(
                    colors: [currentTheme.text.opacity(0.5), currentTheme.text.opacity(0.05), currentTheme.text.opacity(0.05), currentTheme.text.opacity(0.5)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
        )
    }
    
    func newFeeling(moodCalendar: MoodCalendar, tabManager: TabManager, showSubTab: Binding<Bool>, activeTab: Binding<Tab>){
        tabManager.workoutTab = .feelings
        withAnimation(.easeInOut(duration: 0.8)){
            self.showSubTab = false
            self.activeTab = .feeling
            moodCalendar.isCalendar = true
            moodCalendar.addFeelingDate = Date()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            moodCalendar.isFeelingSheet = true
        }
    }
    
    func startStopWatch(stopWatchProvider: StopWatchProvider, showSubTab: Binding<Bool>, activeTab: Binding<Tab>) {
        
        if stopWatchProvider.recorderFetchStartTime() != nil {
            stopWatchProvider.stopRecording(completion: { _ in
                withAnimation(.easeInOut(duration: 0.3))   {
                    self.showSubTab = false
                    self.activeTab = .healthCenter
                    AppConfig.shared.recorderState = false
                    print("STOP STOPWATCH FROM WIDGET")
                }
            })
        } else {
            if stopWatchProvider.recorderState != .started {
                stopWatchProvider.recorderState = .started
                stopWatchProvider.startRecording(completion: { _ in
                    
                })
            }
            
            withAnimation(.easeInOut(duration: 0.3))   {
                self.showSubTab = false
                self.activeTab = .stopWatch
            }
        }
    }
    
    func newPain(painViewModel: PainViewModel, showSubTab: Binding<Bool>, activeTab: Binding<Tab>) {
        withAnimation(.easeInOut(duration: 0.8)){
            self.showSubTab = false
            self.activeTab = .pain
            painViewModel.showList = true
            painViewModel.addPainDate = Date()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            painViewModel.isPainAddSheet = true
        }
    }
    
    func newEvent(eventManager: EventManager, showSubTab: Binding<Bool>, activeTab: Binding<Tab>){
        withAnimation(.easeInOut(duration: 0.8)){
            self.showSubTab = false
            self.activeTab = .event
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            eventManager.isAddEventSheet = true
            eventManager.addEventStarDate = Date()
        }
    }
    
    func haptic() {
        if AppConfig.shared.hapticFeedback {
            let impactMed = UIImpactFeedbackGenerator(style: .heavy)
                impactMed.impactOccurred()
        }
    }
}
