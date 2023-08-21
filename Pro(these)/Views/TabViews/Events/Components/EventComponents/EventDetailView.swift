//
//  EventDetailView.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 04.05.23.
//

import SwiftUI

struct EventDetailView: View {
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    var iconColor: Color
    
    var item: Event
    
    var body: some View {
        ZStack {
            currentTheme.gradientBackground(nil)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack{
                    HStack{
                        Text(item.titel ?? "Unbekannter Titel")
                            .foregroundColor(currentTheme.text)
                    }
                    .padding(.top, 25)
                    
                    EventCardComponent(color: iconColor, item: item)
                        .padding(.top, 50)
                    
                }
            }
            .padding(.horizontal)
            .fullSizeTop()
        }
        .fullSizeTop()
    }
}

struct EventDetailView_Previews: PreviewProvider {
    
    static var testFeeling: Event? {
        let newEvent = Event(context: PersistenceController.shared.container.viewContext)
        newEvent.titel = "Standrort Gespräch"
        newEvent.endDate = Date()
        newEvent.startDate = Date()
        
        return newEvent
    }
    
    static var previews: some View {
        ZStack {
            Theme.blue.gradientBackground(nil).ignoresSafeArea()
            
            EventDetailView(iconColor: .white, item: testFeeling!)
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
