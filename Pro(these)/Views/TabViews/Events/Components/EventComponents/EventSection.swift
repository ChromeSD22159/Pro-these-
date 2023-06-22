//
//  EventSection.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 04.05.23.
//

import SwiftUI

struct EventSection: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var appConfig: AppConfig
    @State private var count = 0
    var titel: String
    
    var data: [Event]
    
    var body: some View {
        Section(content: {
            ForEach(data.sorted(by: { $0.startDate ?? Date() < $1.startDate ?? Date() })){ item in
                NavigateTo({
                    EventPreview(item: item)
                }, {
                    EventDetailView( iconColor: .yellow, item: item)
                })
            }
        }, header: {
            HStack{
                Text("\(titel) (\(count))")
                    .font(.caption2)
                    .fontWeight(.medium)
                
                Spacer()
                   
                Button(
                    action: {
                        eventManager.openAddEventSheet(date: Date())
                    }, label: {
                        Label("Termin", systemImage: "plus")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.trailing, 20)
                    })
            }
        })
        .tint(appConfig.fontColor)
        .listRowBackground(Color.white.opacity(0.05))
        .onAppear{
            count = data.count
        }
        .onChange(of: data, perform: { newData in
            count = newData.count
        })
    }
}


struct EventSection_Previews: PreviewProvider {
    
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
            AppConfig.shared.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                EventSection(titel: "Nächste 7 Tage", data: [testEvent!])

                EventSection(titel: "Diesen Monat", data: [testEvent!,testEvent!,testEvent!])

            }
            .padding()
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
