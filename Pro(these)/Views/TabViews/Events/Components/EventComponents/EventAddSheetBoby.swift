//
//  EventAddSheetBoby.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 04.05.23.
//

import SwiftUI

struct EventAddSheetBoby: View {
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var ads: AdsViewModel

    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    var titel: String
    var body: some View {
        ZStack{
            
            if let event = eventManager.editEvent {
                VStack(){
                    
                    SheetHeader(title: "\(event.titel!) edit", action: {
                        eventManager.isAddEventSheet.toggle()
                    })
                    
                    HStack {
                       Spacer()
                       Form {
                           VStack(spacing: 20) {
                               VStack(alignment: .leading){
                                   TextField(
                                       "e.g. control",
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
                               
                               Picker("Contact", selection: $eventManager.addEventContact) {
                                   Text("Please choose").tag(Optional<Contact>(nil))
                                   ForEach(eventManager.contacts , id: \.id){ contact in
                                       Text(contact.name!).tag(Optional<Contact>(contact))
                                   }
                               }
                               .pickerStyle(.menu)
                               .listRowBackground(currentTheme.text.opacity(0.05))
                               .accentColor(currentTheme.text)
                               
                               DatePicker(
                                  "Beginning",
                                  selection: $eventManager.addEventStarDate,
                                  displayedComponents: [.date, .hourAndMinute]
                               )
                               .datePickerStyle(.compact)
                               .listRowBackground(currentTheme.text.opacity(0.05))
                               .accentColor(currentTheme.text)
                               .tint(currentTheme.text)
                               
                               DatePicker(
                                   "End",
                                   selection: $eventManager.addEventEndDate,
                                   displayedComponents: [.date, .hourAndMinute]
                               )
                               .datePickerStyle(.compact)
                               .listRowBackground(currentTheme.text.opacity(0.05))
                               .accentColor(currentTheme.text)
                               .tint(currentTheme.text)
                           
                               
                               Toggle("Send appointment notification", isOn: $eventManager.sendEventNotofication)
                                   .listRowBackground(currentTheme.text.opacity(0.05))
                               
                               if eventManager.sendEventNotofication {
                                   Picker("Notification", selection: $eventManager.addEventAlarm) {
                                       
                                       ForEach(eventManager.alarms, id: \.type) { alarm in
                                           Text(alarm.text).tag(alarm.ekAlarm)
                                       }
                                   }
                                   .pickerStyle(.menu)
                                   .listRowBackground(currentTheme.text.opacity(0.05))
                                   .accentColor(currentTheme.text)
                               }
                                 
                               InfomationField(
                                    backgroundStyle: .ultraThin,
                                    text: "A reminder about the appointment will be sent 24 hours before the appointment.",
                                    visibility: true
                               )
                           }
                           .listRowBackground(currentTheme.text.opacity(0.05))
                           
                           Section {
                               HStack {
                                   Button("Cancel") {
                                       eventManager.isAddEventSheet = false
                                       eventManager.editEvent = nil
                                       
                                       // Show InterstitialSheet if not Pro
                                       if !appConfig.hasPro {
                                          ads.showInterstitial.toggle()
                                       }
                                   }
                                   .padding()
                                   
                                   Spacer()
                                   
                                   Button("Save") {
                                       eventManager.saveEditEvent(event) { success in
                                           eventManager.isAddEventSheet = false
                                           eventManager.editEvent = nil
                                           
                                           // Show InterstitialSheet if not Pro
                                           if !appConfig.hasPro {
                                              ads.showInterstitial.toggle()
                                           }
                                       }
                                   }
                                   .padding()
                               }
                           }
                           .listRowBackground(currentTheme.text.opacity(0.05))
                           .foregroundColor(currentTheme.text)
                       }
                       Spacer()
                   }
                    
                    Spacer()
                }
                .padding(.vertical, 20)
                .scrollContentBackground(.hidden)
                .foregroundColor(currentTheme.text)
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
                    
                    SheetHeader(title: "Create new appointment", action: {
                        eventManager.isAddEventSheet.toggle()
                    })
                    
                    HStack {
                       Spacer()
                       Form {
                           VStack(spacing: 20) {
                               VStack(alignment: .leading){
                                   TextField(
                                       "e.g. control",
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
                               
                               Picker("Contact", selection: $eventManager.addEventContact) {
                                   Text("Please choose").tag(Optional<Contact>(nil))
                                   ForEach(eventManager.contacts , id: \.id){ contact in
                                       Text(contact.name!).tag(Optional<Contact>(contact))
                                          
                                   }
                               }
                               .pickerStyle(.menu)
                               .listRowBackground(currentTheme.text.opacity(0.05))
                               .accentColor(currentTheme.text)
                               
                               DatePicker(
                                  "Beginning",
                                  selection: $eventManager.addEventStarDate,
                                  displayedComponents: [.date, .hourAndMinute]
                               )
                               .datePickerStyle(.compact)
                               .listRowBackground(currentTheme.text.opacity(0.05))
                               .accentColor(currentTheme.text)
                               .tint(currentTheme.text)
                               
                               DatePicker(
                                   "End",
                                   selection: $eventManager.addEventEndDate,
                                   displayedComponents: [.date, .hourAndMinute]
                               )
                               .datePickerStyle(.compact)
                               .listRowBackground(currentTheme.text.opacity(0.05))
                               .accentColor(currentTheme.text)
                               .tint(currentTheme.text)
                           
                               
                               Toggle("Send appointment notification", isOn: $eventManager.sendEventNotofication)
                                   .listRowBackground(currentTheme.text.opacity(0.05))
                               
                               if eventManager.sendEventNotofication {
                                   Picker("notify", selection: $eventManager.addEventAlarm) {
                                       
                                       ForEach(eventManager.alarms, id: \.type) { alarm in
                                           Text(alarm.text).tag(alarm.ekAlarm)
                                       }
                                   }
                                   .pickerStyle(.menu)
                                   .listRowBackground(currentTheme.text.opacity(0.05))
                                   .accentColor(currentTheme.text)
                               }
                               
                               InfomationField(
                                    backgroundStyle: .ultraThin,
                                    text: "A reminder about the appointment will be sent 24 hours before the appointment.",
                                    visibility: true
                               )
                           }
                           .listRowBackground(currentTheme.text.opacity(0.05))
                           
                           Section {
                               HStack {
                                   Button("Cancel") {
                                       eventManager.isAddEventSheet = false
                                       
                                       // Show InterstitialSheet if not Pro
                                       if !appConfig.hasPro {
                                          ads.showInterstitial.toggle()
                                       }
                                   }
                                   .padding()
                                   
                                   Spacer()
                                   
                                   Button("Save") {
                                       eventManager.addEvent()
                                       
                                       // Show InterstitialSheet if not Pro
                                       if !appConfig.hasPro {
                                          ads.showInterstitial.toggle()
                                       }
                                   }
                                   .padding()
                               }
                           }
                           .listRowBackground(currentTheme.text.opacity(0.05))
                           .foregroundColor(currentTheme.text)
                       }
                       Spacer()
                   }
                    
                    Spacer()
                }
                .padding(.vertical, 20)
                .scrollContentBackground(.hidden)
                .foregroundColor(currentTheme.text)
                .onChange(of: eventManager.addEventStarDate){ newDate in
                    eventManager.addEventEndDate = Calendar.current.date(byAdding: .minute, value: 30, to: newDate)!
                }
            }
            
        }
        .fullSizeTop()
    }
    
    func dismissKeyboard() {
        
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let _ = windowScene?.windows.filter({ $0.isKeyWindow }).first?.endEditing(true)
        
       // UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.endEditing(true) // 4
    }
}



struct EventAddSheetBoby_Previews: PreviewProvider {
    
    static var testEvent: Event? {
        let newEvent = Event(context: PersistenceController.shared.container.viewContext)
        newEvent.titel = "location conversation"
        newEvent.endDate = Date()
        newEvent.startDate = Date()
        
        return newEvent
    }
    
    static var previews: some View {
        ZStack {
            
            Theme.blue.gradientBackground(nil).ignoresSafeArea()
            
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
                    .defaultAppStorage(UserDefaults(suiteName: "group.FK.Pro-these-")!)
                    .colorScheme(.dark)
            }
        }
    }
}
