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
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var contactManager: ContactManager
    @FocusState private var focusedTask: EventTasks?
    var color: Color
    var contact: Contact
    var body: some View {
        VStack{
            ForEach(contact.events?.allObjects as? [Event] ?? [] , id: \.self) { event in //
                VStack(alignment: .leading, spacing: 10){
                    HStack(spacing: 20) {
                        
                        Image(systemName: eventManager.getIcon(event.contact?.titel ?? "other"))
                            .font(.title)
                            .foregroundColor(color)

                        VStack(alignment: .leading, spacing: 5){
                            Text(event.titel ?? "Unbekanntes Titel")
                                .font(.callout)
                                .fontWeight(.medium)
                                
                            HStack{
                                Text(event.startDate ?? Date(), style: .date)
                                    .foregroundColor(appConfig.fontLight)
                                    .font(.caption2)
                                Text(event.startDate ?? Date(), style: .time)
                                    .foregroundColor(appConfig.fontLight)
                                    .font(.caption2)
                            }
                        }
                        
                        Spacer()
                    }

                    
                    ForEach(event.tasks?.allObjects as? [EventTasks] ?? [], id: \.self) { trask in
                        EventTaskRow(task: trask, focusedTask: $focusedTask)
                    }
                    
                    HStack{
                        // FIXME: - Confirm BTN
                        Button {
                            let newTask = EventTasks(context: managedObjectContext)
                            newTask.isDone = false
                            event.addToTasks(newTask)
                            withAnimation{
                                eventManager.sortAllEvents()
                                focusedTask = newTask
                            }
                            do {
                                try PersistenceController.shared.container.viewContext.save()
                            } catch {
                                let nsError = error as NSError
                                fatalError("Add Task error: \(nsError), \(nsError.userInfo)")
                            }
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("Notiz hinzufügen")
                            }
                        }
                        .foregroundColor(appConfig.fontColor)
                        .padding(.top, 10)
                        
                        Spacer ()
                        
                        Button {
                            eventManager.deleteEvent(event)
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                            }
                        }
                        .foregroundColor(appConfig.fontColor)
                        .padding(.top, 10)
                    }
                    
                }
                .padding(20)
                .background(Color.white.opacity(0.05))
                .cornerRadius(20)
            }
            
            HStack{
 
                Confirm(message: "\( contact.name ?? "" ) löschen? \n \n Es werden alle dazugehörigen Termine \n und Notizen gelöscht!", buttonText: "Löschen", buttonIcon: "trash", content: {
                    Button("Löschen") { eventManager.deleteContact(contact) }.foregroundColor(.red)
                })
                .foregroundColor(.white)
                
                Spacer()

                Button(action: {
                    eventManager.editContact = contact
                    eventManager.isAddContactSheet.toggle()
                }, label: {
                    Label("Bearbeiten", systemImage: "pencil")
                        .foregroundColor(.white)
                })
            }
            .padding(20)
            .background(Color.white.opacity(0.05))
            .cornerRadius(20)
        }
    }
}
