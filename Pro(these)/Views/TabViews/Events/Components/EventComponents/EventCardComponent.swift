//
//  EventCardComponent.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 04.05.23.
//

import SwiftUI

struct EventCardComponent: View {
    @EnvironmentObject var eventManager: EventManager
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var ads: AdsViewModel
    @FocusState private var focusedTask: EventTasks?
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    var color: Color
    var item: Event
    
    var events: [EventTasks] {
        let allTasks = (item.tasks?.allObjects as? [EventTasks]) ?? []
        return allTasks.sorted(by: { $0.date ?? Date() < $1.date ?? Date() })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10){
            EventTaskHeader(color: color, item: item)
            
            Text("Task`s")
                .fontWeight(.medium)
                .padding(.top, 25)
                .padding(.bottom, 20)
            
            ForEach(events, id: \.self) { item in
                EventTaskRow(task: item, focusedTask: $focusedTask)
            }
            
            Button {
                let newTask = EventTasks(context: managedObjectContext)
                newTask.isDone = false
                newTask.text = ""
                newTask.date = Date()
                item.addToTasks(newTask)
                withAnimation{
                    eventManager.sortAllEvents()
                    focusedTask = newTask
                }
                do {
                    try PersistenceController.shared.container.viewContext.save()
                    // Show InterstitialSheet if not Pro
                    if !appConfig.hasPro {
                       ads.showInterstitial.toggle()
                    }
                } catch {
                    let nsError = error as NSError
                    fatalError("Add Task error: \(nsError), \(nsError.userInfo)")
                }
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Note")
                }
            }
            .foregroundColor(currentTheme.text)
            .padding(.top, 10)
        }
        .padding(20)
        .background(currentTheme.text.opacity(0.05))
        .cornerRadius(20)
        
        HStack{

            Confirm(message: "Delete the event '\( item.titel ?? "" )'?", buttonText: "Delete", buttonIcon: "trash", content: {
                Button("Delete") { eventManager.deleteEvent(item) }
            })
            .foregroundColor(currentTheme.hightlightColor)
            
            Spacer()
        }
        .padding(20)
        .background(currentTheme.text.opacity(0.05))
        .cornerRadius(20)
    }
}

struct EventCardComponent_Previews: PreviewProvider {
    
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
            
            VStack{
                EventCardComponent(color: .white, item: testEvent!)
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
