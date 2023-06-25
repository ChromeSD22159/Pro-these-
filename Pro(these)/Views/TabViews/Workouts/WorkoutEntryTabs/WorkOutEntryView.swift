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
    
    @State var healthTab: WorkoutTab?
    @State var isScreenShotSheet = false
    
    var body: some View {
        GeometryReader { screen in
           
            ZStack{
                
                VStack(spacing: 20) {
                    
                    HStack(){
                        VStack(spacing: 2){
                            sayHallo(name: AppConfig.shared.username)
                                .font(.title2)
                                .foregroundColor(AppConfig.shared.fontColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Dein Tagesziel ist für heute \(AppConfig.shared.targetSteps) Schritte")
                                .font(.callout)
                                .foregroundColor(AppConfig.shared.fontLight)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        HStack(spacing: 20){
                            /* HASPRO
                            if !entitlementManager.hasPro {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(AppConfig.shared.fontColor)
                                    .onTapGesture {
                                        DispatchQueue.main.async {
                                            tabManager.ishasProFeatureSheet.toggle()
                                        }
                                    }
                            }
                             */
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
                        WorkoutStatisticView(isScreenShotSheet: $isScreenShotSheet).environmentObject(workoutStatisticViewModel)
                    }
                   
                    
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
           
        }
    }
    
    func sayHallo(name: String) -> some View {
        let hour = Calendar.current.component(.hour, from: Date())
        
        var string = ""
        
        var nameString = ""
        if name != "" {
            nameString = ", \(name)"
        }

        switch hour {
            case 6..<12 : string = "Guten Morgen\(nameString)!"
            case 12 : string = "Guten Tag\(nameString)!"
            case 13..<17 :  string = "Hallo\(nameString)!"
            case 17..<22 : string = "Guten Abend\(nameString)!"
            default: string = "Hallo\(nameString)!"
        }
        
        return Text(string)
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
