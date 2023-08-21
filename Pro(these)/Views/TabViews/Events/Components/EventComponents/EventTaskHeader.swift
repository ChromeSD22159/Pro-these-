//
//  EventTaskHeader.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 04.05.23.
//

import SwiftUI

struct EventTaskHeader: View {
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    var color: Color
    var item: Event
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: item.icon ?? "Unknown Icon")
                .font(.title)
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 5){
                Text(item.titel ?? "Unknown Titel")
                    .font(.callout)
                    .fontWeight(.medium)
                    
                HStack{
                    Text(item.startDate ?? Date(), style: .date)
                        .foregroundColor(currentTheme.textGray)
                        .font(.caption2)
                    Text(item.startDate ?? Date(), style: .time)
                        .foregroundColor(currentTheme.textGray)
                        .font(.caption2)
                }
            }
            
            Spacer()
            
            Button(action: {
                eventManager.editEvent = item
                DispatchQueue.main.async {
                    eventManager.isAddEventSheet.toggle()
                }
            }, label: {
                Label("Edit", systemImage: "pencil")
            })
            .foregroundColor(currentTheme.hightlightColor)
        }
    }
}

struct EventTaskHeader_Previews: PreviewProvider {
    
    static var testEvent: Event? {
        let newEvent = Event(context: PersistenceController.shared.container.viewContext)
        newEvent.titel = "Standrort Gespräch"
        newEvent.endDate = Date()
        newEvent.startDate = Date()
        
        return newEvent
    }
    
    static var previews: some View {
        ZStack {
            Theme.blue.gradientBackground(nil).ignoresSafeArea()
            
            EventTaskHeader(color: .white, item: testEvent!)
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
