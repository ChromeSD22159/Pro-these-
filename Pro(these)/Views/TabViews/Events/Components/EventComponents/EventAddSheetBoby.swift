//
//  EventAddSheetBoby.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 04.05.23.
//

import SwiftUI

struct EventAddSheetBoby: View {
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var eventManager: EventManager
    
    var titel: String
    var body: some View {
        ZStack{
            
            if let event = eventManager.editEvent {
                VStack(){
                    
                    SheetHeader("\(event.titel!) bearbeiten", action: {
                        eventManager.isAddEventSheet.toggle()
                    })
                    
                    HStack {
                       Spacer()
                       Form {
                           VStack(spacing: 20) {
                               VStack(alignment: .leading){
                                   TextField(
                                       "z.B. Kontrolle",
                                       text: $eventManager.addEventTitel
                                   )
                                   .padding(.vertical)
                                   .padding(.top)
                                   .disableAutocorrection(true)
                                   
                                   Text(eventManager.error)
                                       .font(.caption2)
                                       .foregroundColor(.red)
                                       .padding(.bottom)
                                       .multilineTextAlignment(.leading)
                               }
                               
                               Picker("Kontakt", selection: $eventManager.addEventContact) {
                                   Text("Bitte wählen").tag(Optional<Contact>(nil))
                                   ForEach(eventManager.contacts , id: \.id){ contact in
                                       Text(contact.name!).tag(Optional<Contact>(contact))
                                   }
                               }
                               .pickerStyle(.menu)
                               .listRowBackground(Color.white.opacity(0.05))
                               .accentColor(.white)
                               
                               DatePicker(
                                  "Beginn",
                                  selection: $eventManager.addEventStarDate,
                                  displayedComponents: [.date, .hourAndMinute]
                               )
                               .datePickerStyle(.compact)
                               .listRowBackground(Color.white.opacity(0.05))
                               .accentColor(.white)
                               .tint(.white)
                               
                               DatePicker(
                                   "Ende",
                                   selection: $eventManager.addEventEndDate,
                                   displayedComponents: [.date, .hourAndMinute]
                               )
                               .datePickerStyle(.compact)
                               .listRowBackground(Color.white.opacity(0.05))
                               .accentColor(.white)
                               .tint(.white)
                           
                               
                               Toggle("Benachtigung zum Termin senden", isOn: $eventManager.sendEventNotofication)
                                   .listRowBackground(Color.white.opacity(0.05))
                               
                               if eventManager.sendEventNotofication {
                                   Picker("Benachrichtigen", selection: $eventManager.addEventAlarm) {
                                       
                                       ForEach(eventManager.alarms, id: \.text) { alarm in
                                           Text(alarm.text).tag(alarm.ekAlarm)
                                       }
                                   }
                                   .pickerStyle(.menu)
                                   .listRowBackground(Color.white.opacity(0.05))
                                   .accentColor(.white)
                               }
                                 
                               InfomationField(
                                    backgroundStyle: .ultraThin,
                                    text: "Es wird eine Erinnerung zu dem Termin 24 Stunden vor dem Termin gesendet.",
                                    visibility: true
                               )
                           }
                           .listRowBackground(Color.white.opacity(0.05))
                           
                           Section {
                               HStack {
                                   Button("Abbrechen") {
                                       eventManager.isAddEventSheet = false
                                       eventManager.editEvent = nil
                                   }
                                   .padding()
                                   
                                   Spacer()
                                   
                                   Button("Speichern") {
                                       eventManager.saveEditEvent(event) { success in
                                           eventManager.isAddEventSheet = false
                                           eventManager.editEvent = nil
                                       }
                                   }
                                   .padding()
                               }
                           }
                           .listRowBackground(Color.white.opacity(0.05))
                           .foregroundColor(appConfig.fontColor)
                       }
                       Spacer()
                   }
                    
                    Spacer()
                }
                .padding(.vertical, 20)
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
                .onChange(of: eventManager.addEventStarDate){ newDate in
                    eventManager.addEventEndDate = Calendar.current.date(byAdding: .minute, value: 30, to: newDate)!
                }
                .onAppear{
                    eventManager.addEventTitel = event.titel!
                    eventManager.addEventIcon = event.icon!
                    eventManager.addEventStarDate = event.startDate!
                    eventManager.addEventEndDate = event.endDate!
                    eventManager.addEventContact = event.contact
                }
                
            } else {
                VStack(){
                    
                    SheetHeader("Neuen Termin erstellen", action: {
                        eventManager.isAddEventSheet.toggle()
                    })
                    
                    HStack {
                       Spacer()
                       Form {
                           VStack(spacing: 20) {
                               VStack(alignment: .leading){
                                   TextField(
                                       "z.B. Kontrolle",
                                       text: $eventManager.addEventTitel
                                   )
                                   .padding(.vertical)
                                   .padding(.top)
                                   .disableAutocorrection(true)
                                   
                                   Text(eventManager.error)
                                       .font(.caption2)
                                       .foregroundColor(.red)
                                       .padding(.bottom)
                                       .multilineTextAlignment(.leading)
                               }
                               
                               Picker("Kontakt", selection: $eventManager.addEventContact) {
                                   Text("Bitte wählen").tag(Optional<Contact>(nil))
                                   ForEach(eventManager.contacts , id: \.id){ contact in
                                       Text(contact.name!).tag(Optional<Contact>(contact))
                                          
                                   }
                               }
                               .pickerStyle(.menu)
                               .listRowBackground(Color.white.opacity(0.05))
                               .accentColor(.white)
                               
                               DatePicker(
                                  "Beginn",
                                  selection: $eventManager.addEventStarDate,
                                  displayedComponents: [.date, .hourAndMinute]
                               )
                               .datePickerStyle(.compact)
                               .listRowBackground(Color.white.opacity(0.05))
                               .accentColor(.white)
                               .tint(.white)
                               
                               DatePicker(
                                   "Ende",
                                   selection: $eventManager.addEventEndDate,
                                   displayedComponents: [.date, .hourAndMinute]
                               )
                               .datePickerStyle(.compact)
                               .listRowBackground(Color.white.opacity(0.05))
                               .accentColor(.white)
                               .tint(.white)
                           
                               
                               Toggle("Benachtigung zum Termin senden", isOn: $eventManager.sendEventNotofication)
                                   .listRowBackground(Color.white.opacity(0.05))
                               
                               if eventManager.sendEventNotofication {
                                   Picker("Benachrichtigen", selection: $eventManager.addEventAlarm) {
                                       
                                       ForEach(eventManager.alarms, id: \.text) { alarm in
                                           Text(alarm.text).tag(alarm.ekAlarm)
                                       }
                                   }
                                   .pickerStyle(.menu)
                                   .listRowBackground(Color.white.opacity(0.05))
                                   .accentColor(.white)
                               }
                               
                               InfomationField(
                                    backgroundStyle: .ultraThin,
                                    text: "Es wird eine Erinnerung zu dem Termin 24 Stunden vor dem Termin gesendet.",
                                    visibility: true
                               )
                           }
                           .listRowBackground(Color.white.opacity(0.05))
                           
                           Section {
                               HStack {
                                   Button("Abbrechen") {
                                       eventManager.isAddEventSheet = false
                                   }
                                   .padding()
                                   
                                   Spacer()
                                   
                                   Button("Speichern") {
                                       eventManager.addEvent()
                                   }
                                   .padding()
                               }
                           }
                           .listRowBackground(Color.white.opacity(0.05))
                           .foregroundColor(appConfig.fontColor)
                       }
                       Spacer()
                   }
                    
                    Spacer()
                }
                .padding(.vertical, 20)
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
                .onChange(of: eventManager.addEventStarDate){ newDate in
                    eventManager.addEventEndDate = Calendar.current.date(byAdding: .minute, value: 30, to: newDate)!
                }
            }
            
        }
        .fullSizeTop()
    }
    
    func dismissKeyboard() {
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.endEditing(true) // 4
    }
}



struct EventAddSheetBoby_Previews: PreviewProvider {
    
    static var testEvent: Event? {
        let newEvent = Event(context: PersistenceController.shared.container.viewContext)
        newEvent.titel = "Standrort Gespräch"
        newEvent.endDate = Date()
        newEvent.startDate = Date()
        
        return newEvent
    }
    
    static var identifier = "de-DE"
    
    static var previews: some View {
        ZStack {
            AppConfig.shared.background.ignoresSafeArea()
            
            VStack{ // de-DE
                EventAddSheetBoby(titel: "Event erstellen")
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
                    .environment(\.locale, .init(identifier: "de_DE"))
                    .defaultAppStorage(UserDefaults(suiteName: "group.FK.Pro-these-")!)
                    .colorScheme(.dark)
            }
        }
    }
}
