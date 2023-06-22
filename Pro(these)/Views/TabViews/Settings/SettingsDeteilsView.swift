//
//  SettingsOverView.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 27.04.23.
//

import SwiftUI
import WidgetKit

struct SettingsDeteilsView: View {
    var titel: String
    var Options:[Options]
    var body: some View {
        ZStack {
            AppConfig().backgroundGradient
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20){
                    HStack{
                        Text(titel)
                            .foregroundColor(.white)
                    }
                    
                    ForEach(Options, id: \.id){ s in
                        SettingToggleButton(image: s.icon, toggleDescrition: s.desc, info: s.info, storeBinding: s.binding)
                    }
                    
                    Spacer()
                    
                    copyright()
                    
                }
                .padding(.top, 80)
            }
            .ignoresSafeArea()
            .padding(.horizontal)
        }
    }
}


struct SettingsDeteilsView_Previews: PreviewProvider {
    
    static var settings = [
        Options(titel: "", icon: "target", desc: "Zeige erfüllte Tagesziele Schrittüberischt Schrittüberischt", info: "Zeigt den Record Button auch auf der Schrittüberischt an.", binding: .constant(false)),
    ]
    
    static var previews: some View {
        ZStack {
            AppConfig.shared.background.ignoresSafeArea()
            
            VStack{
                SettingsDeteilsView(titel: "Page Header", Options: settings)
                    .environmentObject(AppConfig())
                    .environmentObject(TabManager())
                    .environmentObject(HealthStorage())
                    .environmentObject(PushNotificationManager())
                    .environmentObject(EventManager())
                    .environmentObject(MoodCalendar())
                    .environmentObject(WorkoutStatisticViewModel())
                    .environmentObject(PainViewModel())
                    .environmentObject(StateManager())
                    .environmentObject(EntitlementManager())
                    .defaultAppStorage(UserDefaults(suiteName: "group.FK.Pro-these-")!)
                    .colorScheme(.dark)
            }
        }
    }
}
