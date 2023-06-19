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
    
    @State var healthTab: WorkoutTab?
    @State var isScreenShotSheet = false
    
    var body: some View {
        GeometryReader { screen in
           
            ZStack{
                
                VStack(spacing: 20) {
                    
                    HStack(){
                        VStack(spacing: 2){
                            Text("Hallo, \(AppConfig.shared.username)")
                                .font(.title2)
                                .foregroundColor(AppConfig.shared.fontColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Dein Tagesziel ist für heute \(AppConfig.shared.targetSteps) Schritte")
                                .font(.callout)
                                .foregroundColor(AppConfig.shared.fontLight)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        HStack(spacing: 20){
                            if tabManager.workoutTab == .feelings {
                                Image(systemName: cal.isCalendar ? "calendar" : "list.bullet.below.rectangle")
                                    .foregroundColor(AppConfig.shared.fontColor)
                                    .font(.title3)
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.5)){
                                            cal.isCalendar.toggle()
                                        }
                                    }
                            }
                            if tabManager.workoutTab == .statistic {
                                Image(systemName: "camera")
                                    .foregroundColor(AppConfig.shared.fontColor)
                                    .font(.title3)
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.5)){
                                            isScreenShotSheet.toggle()
                                        }
                                    }
                            }
                            
                            Image(systemName: "gearshape")
                                .foregroundColor(AppConfig.shared.fontColor)
                                .font(.title3)
                                .onTapGesture {
                                    tabManager.isSettingSheet.toggle()
                                }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    
                    
                    // Content
                    ScrollView(showsIndicators: false) {
                        
                        /*// Tab
                        HStack(spacing: 10) {
                            ForEach(WorkoutTab.allCases, id: \.self) { tab in
           
                                VStack{
                                    Text(tab.title())
                                        .foregroundColor(tabManager.workoutTab == tab ? .yellow : .white)
                                        .font(.callout)
                                }
                                .padding(.vertical, 5)
                                .frame(maxWidth: .infinity)
                                .background(tabManager.workoutTab == tab ? Material.ultraThinMaterial.opacity(1) : Material.ultraThinMaterial.opacity(0.25))
                                .cornerRadius(15)
                                .onTapGesture {
                                    withAnimation(.easeInOut){
                                        tabManager.workoutTab = tab
                                    }
                                }
         
                            }
                        } // tab
                        .padding(.horizontal)
                        .onAppear{
                            healthTab = tabManager.workoutTab
                        }
                        .onChange(of: tabManager.workoutTab, perform: { new in
                            healthTab = new
                            
                            // set Statistic Date on Today
                            workoutStatisticViewModel.currentDay = Date()
                            
                            // set Calendar Current Date = Today and month at current Month
                            cal.currentDate = Date()
                            cal.currentMonth = 0
                        })
                        
                        switch tabManager.workoutTab {
                            case .statistic: WorkoutStatisticView(isScreenShotSheet: $isScreenShotSheet).environmentObject(workoutStatisticViewModel)
                            case .feelings: FeelingView()
                        } */
                        
                        WorkoutStatisticView(isScreenShotSheet: $isScreenShotSheet).environmentObject(workoutStatisticViewModel)
                    }
                   
                    
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
           
        }
    }
}


enum WorkoutTab: Codable, CaseIterable, Identifiable {
    var id: Self { self }
    case statistic
    case feelings
    
    func title() -> String {
        switch self {
        case .statistic: return "Statistik"
        case .feelings: return "Feelings"
        }
    }
}
