//
//  ContactCardComponent.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 04.05.23.
//

import SwiftUI

struct ContactCardComponent: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var ads: AdsViewModel
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var contactManager: ContactManager
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    @FocusState private var focusedTask: EventTasks?
    var color: Color
    var contact: Contact
    
    var allEvents: [Event] {
        return contact.events?.allObjects as? [Event] ?? []
    }
    
    var allpastEvents: [Event] {
        let all: [Event] = contact.events?.allObjects as? [Event] ?? []
        return all.filter { $0.startDate ?? Date() < Date() }
    }
    
    var allFutureEvents: [Event] {
        let all: [Event] = contact.events?.allObjects as? [Event] ?? []
        return all.filter { $0.startDate ?? Date() > Date() }.sorted(by: {$0.startDate ?? Date() < $1.startDate ?? Date()})
    }
    
    var maxTasks: Int {
        return self.allFutureEvents.map({ event in
            return event.tasks?.count ?? 0
        }).max()!
    }
    
    var body: some View {
        VStack{
            if allFutureEvents.count == 0 {
                HStack(spacing: 10){
                    Text("No dates available.")
                    Spacer()
                }
                .padding(20)
                .background(currentTheme.text.opacity(0.05))
                .cornerRadius(20)
                .padding(.horizontal)
            } else {
                TabView {
                    ForEach(allFutureEvents, id: \.startDate) { event in //
                        HStack {
                            VStack(alignment: .leading, spacing: 20){
                                HStack(spacing: 20) {
                                    
                                    Image(systemName: eventManager.getIcon(event.contact?.titel ?? "other"))
                                        .font(.title)
                                        .foregroundColor(color)

                                    VStack(alignment: .leading, spacing: 5){
                                        Text(event.titel ?? "Unknown Titel")
                                            .font(.callout)
                                            .fontWeight(.medium)
                                            
                                        HStack{
                                            Text(event.startDate ?? Date(), style: .date)
                                                .foregroundColor(currentTheme.textGray)
                                                .font(.caption2)
                                            Text(event.startDate ?? Date(), style: .time)
                                                .foregroundColor(currentTheme.textGray)
                                                .font(.caption2)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Menu(content: {
                                        Button {
                                            let newTask = EventTasks(context: managedObjectContext)
                                            newTask.isDone = false
                                            newTask.date = Date()
                                            event.addToTasks(newTask)
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
                                                Text("Add note")
                                                Image(systemName: "plus")
                                            }
                                        }
                                        Button {
                                            eventManager.deleteEvent(event)
                                        } label: {
                                            HStack {
                                                Text("Delete Event") 
                                                Image(systemName: "trash")
                                            }
                                        }
                                    }, label: {
                                        Image(systemName: "ellipsis.circle")
                                            .rotationEffect(.degrees(90))
                                            .foregroundColor(currentTheme.text)
                                            .padding([.vertical, .leading])
                                    })
                                    
                                }
                                
                                let eventTasks = event.tasks?.allObjects as? [EventTasks] ?? []
                                
                                if eventTasks.count > 0 {
                                    ForEach(eventTasks.sorted(by: { $0.date ?? Date() < $1.date ?? Date() } ), id: \.self) { task in
                                        EventTaskRow(task: task, focusedTask: $focusedTask)
                                    }
                                } else {
                                    HStack {
                                        Text("No notes available!")
                                        
                                        Spacer()
                                    }
                                    .foregroundColor(currentTheme.text)
                                    .padding(5)
                                }
                                
                                /*
                                HStack{
                                    // FIXME: - Confirm BTN
                                    Button {
                                        let newTask = EventTasks(context: managedObjectContext)
                                        newTask.isDone = false
                                        newTask.date = Date()
                                        event.addToTasks(newTask)
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
                                            Text("Add note")
                                        }
                                    }
                                    .foregroundColor(currentTheme.text)
                                    .padding(.top, 10)
                                    
                                    Spacer ()
                                    
                                    Button {
                                        eventManager.deleteEvent(event)
                                    } label: {
                                        HStack {
                                            Image(systemName: "trash")
                                        }
                                    }
                                    .foregroundColor(currentTheme.text)
                                    .padding(.top, 10)
                                }
                                */
                                Spacer()
                            }
                            .padding(20)
                            .background(currentTheme.text.opacity(0.05))
                            .cornerRadius(20)
                            .tag(event.startDate)
                        }
                        .padding(.horizontal)
                    }
                }
                .frame(height: 150 + (CGFloat(maxTasks) * 50))
                .tabViewStyle(.page)
                
            }

            HStack{
                Confirm(message: "Delete \( contact.name ?? "" )? \n \n All associated appointments \n and notes will be deleted!", buttonText: "Delete Contact", buttonIcon: "trash", content: {
                    Button(LocalizedStringKey("Delete Contact")) {
                        eventManager.deleteContact(contact)
                        // Show InterstitialSheet if not Pro
                        if !appConfig.hasPro {
                           ads.showInterstitial.toggle()
                        }
                    }.foregroundColor(.red)
                })
                .foregroundColor(currentTheme.text)
                
                Spacer()

                Button(action: {
                    eventManager.editContact = contact
                    eventManager.isAddContactSheet.toggle()
                    
                    // Show InterstitialSheet if not Pro
                    if !appConfig.hasPro {
                       ads.showInterstitial.toggle()
                    }
                }, label: {
                    Label("Edit contact", systemImage: "pencil")
                        .foregroundColor(currentTheme.text)
                })
            }
            .padding(20)
            .background(currentTheme.text.opacity(0.05))
            .cornerRadius(20)
            .padding(.horizontal)
        }
    }
}

struct ViewHeightKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
