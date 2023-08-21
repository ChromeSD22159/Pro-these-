//
//  EventPreview.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 04.05.23.
//

import SwiftUI

struct EventPreview: View {
    @EnvironmentObject private var appConfig: AppConfig
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    var item: Event
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: eventManager.getIcon(item.contact?.titel ?? "") )
                .font(.title)
                .foregroundColor(currentTheme.hightlightColor)
            
            VStack(alignment: .leading, spacing: 5){
                HStack{
                    Text(item.titel ?? "Unbekannter Titel")
                        .foregroundColor(currentTheme.text)
                        .font(.callout)
                }
                
                HStack{
                    Text(item.startDate ?? Date(), style: .date)
                        .foregroundColor(currentTheme.textGray)
                        .font(.caption2)
                    Text(item.startDate ?? Date(), style: .time)
                        .foregroundColor(currentTheme.textGray)
                        .font(.caption2)
                    
                    Text("(\(item.contact?.name ?? "Unbekannter Kontakt"))")
                        .foregroundColor(currentTheme.textGray)
                        .font(.caption2)
                }
            }
            
            Spacer()
        }
        .padding(10)
    }
}


struct EventPreview_Previews: PreviewProvider {
    
    static var testEvent: Event? {
        let newEvent = Event(context: PersistenceController.shared.container.viewContext)
        newEvent.icon = ""
        newEvent.titel = "Standrort Gespräch"
        newEvent.endDate = Date()
        newEvent.startDate = Date()
        
        return newEvent
    }
    
    static var previews: some View {
        ZStack {
            Theme.blue.gradientBackground(nil).ignoresSafeArea()
            
            VStack{
                EventPreview(item: testEvent!)
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
