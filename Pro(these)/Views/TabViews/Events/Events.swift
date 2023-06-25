//
//  Events.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 01.05.23.
//

import SwiftUI
import CoreData
import Charts

struct Events: View {
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var tabManager: TabManager
    @EnvironmentObject var cal: MoodCalendar
    @EnvironmentObject var entitlementManager: EntitlementManager
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FocusState var focusedTask: EventTasks?
    @FetchRequest(sortDescriptors: [ SortDescriptor(\.startDate) ]) var events: FetchedResults<Event>
    
    var body: some View {
        GeometryReader { g in
            VStack{
                header()
                    .padding(.top, 20)
                
                ScrollView(showsIndicators: false, content: {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center, spacing: 5) {
                            let SortedContacts = eventManager.contacts.sorted(by: { $0.titel ?? "" < $1.titel ?? "" })
                            ForEach(Array(SortedContacts.enumerated()), id: \.1) { (index, contact) in
                                GeometryReader { geo in
                                    NavigateTo({
                                        ImageView(image: eventManager.getImage(contact.titel ?? "noImage") , name: contact.name ?? "Unbekannter Name", titel: contact.titel ?? "Unbekannter Titel" != "other" ? contact.titel ?? "Unbekannter Titel" : "Sonstiges"  )
                                            .rotation3DEffect(.degrees(-geo.frame(in: .global).minX) / 20, axis: (x: 0, y: 1, z: 0))
                                            .frame(width: 160, height: 200)
                                            .shadow(color: .black.opacity(0.5), radius: 10, x: 5, y: 5)
                                            .offset(y: -18)
                                    }, {
                                        ContactDetailView(contact: contact, iconColor: .yellow)
                                    })
                                }
                                .padding(.vertical, 40)
                                .frame(width: 160, height: 230)
                            }
                            
                            AddContact()
                                .frame(width: 160, height: 230)
                                .shadow(color: .black.opacity(0.5), radius: 10, x: 5, y: 5)
                               
                                
                        }
                        .padding(10)
                    }
                    .listRowBackground(Color.white.opacity(0.001))
                    
                    if appConfig.EventShowCalendar {
                        EventCalendar(events: events)
                    } else {
                        List {
                            EventSection(titel: "Nächste 7 Tage", data: eventManager.eventsNextWeek)
                                .listRowInsets(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
                            
                            EventSection(titel: "Diesen Monat", data: eventManager.eventsnextmonth)
                                .listRowInsets(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
                            
                            if appConfig.showAllEvents {
                                EventSection(titel: "Alle Termine", data: eventManager.eventsAll)
                                    .listRowInsets(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
                            }

                            if appConfig.showPastEvents {
                                EventSection(titel: "Vergangene Woche", data: eventManager.eventsPast)
                                    .listRowInsets(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
                            }
                        }
                        .frame(width: g.size.width - 5, height: g.size.height - 50, alignment: .center)
                        .scrollContentBackground(.hidden)
                        .foregroundColor(.white)
                        .refreshable {
                            eventManager.fetchContacts()
                        }
                    }
                    
                       
                })
            }
            .foregroundColor(appConfig.fontColor)
            .fullSizeTop()
            .blurredOverlaySheet(.init(Material.ultraThinMaterial), show: $eventManager.isAddContactSheet, onDismiss: {}, content: {
                ContentAddSheetBoby(titel: "Neuer Kontakt")
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            })
            .blurredOverlaySheet(.init(Material.ultraThinMaterial), show: $eventManager.isAddEventSheet, onDismiss: {}, content: {
                EventAddSheetBoby(titel: "Erstelle einen Termin")
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            })
            .onAppear{
                eventManager.fetchContacts()
                cal.currentDate = Date()
                cal.currentDates = cal.extractMonth()
            }
            // MARK: - Set Current Month to the selected Date and Extract the current Month
            .onChange(of: cal.currentMonth, perform: { value in
                cal.currentDate = cal.getCurrentMonth()
                cal.currentDates = cal.extractMonth()
            })
        }
        
    }
}

// MARK: Event ViewItems
extension Events {
    @ViewBuilder
    func header() -> some View {
        HStack(){
            VStack(spacing: 2){
                sayHallo(name: appConfig.username)
                    .font(.title2)
                    .foregroundColor(AppConfig.shared.fontColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Deine Termine und Notizen im Überblick.")
                    .font(.callout)
                    .foregroundColor(AppConfig.shared.fontLight)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack(spacing: 20){
                /* HASPRO
                if !entitlementManager.hasPro {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(AppConfig.shared.fontColor)
                        .onTapGesture {
                            DispatchQueue.main.async {
                                tabManager.ishasProFeatureSheet.toggle()
                            }
                        }
                }
                */
                Image(systemName: eventManager.showCal ? "calendar" : "list.bullet.below.rectangle")
                    .foregroundColor(AppConfig.shared.fontColor)
                    .font(.title3)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.5)){
                            appConfig.EventShowCalendar.toggle()
                        }
                    }
                
                Image(systemName: "gearshape")
                    .foregroundColor(AppConfig.shared.fontColor)
                    .font(.title3)
                    .onTapGesture {
                        tabManager.isSettingSheet.toggle()
                    }
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func Header(name: String, subline: String) -> some View {
        HStack(){
            VStack(spacing: 2) {
                Text(name)
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(subline)
                    .font(.callout)
                    .foregroundColor(appConfig.fontLight)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer()
            VStack(){
                Image(systemName: "gearshape")
                    .font(.title3)
                    .foregroundColor(appConfig.fontColor)
                    .onTapGesture {
                        tabManager.isSettingSheet.toggle()
                    }
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
    }

    func sayHallo(name: String) -> some View {
        let hour = Calendar.current.component(.hour, from: Date())
        
        var string = ""
        
        var nameString = ""
        if name != "" {
            nameString = ", \(name)"
        }

        switch hour {
            case 6..<12 : string = "Guten Morgen\(nameString)!"
            case 12 : string = "Guten Tag\(nameString)!"
            case 13..<17 :  string = "Hallo\(nameString)!"
            case 17..<22 : string = "Guten Abend\(nameString)!"
            default: string = "Hallo\(nameString)!"
        }
        
        return Text(string)
    }

}


struct AddContact: View {
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var eventManager: EventManager
    var body: some View {
        VStack(spacing: 10){
            Image(systemName: "plus")
                .multilineTextAlignment(.center)
            Text("Kontakt \n hinzufügen")
                .multilineTextAlignment(.center)
        }
        .foregroundColor(appConfig.foreground)
        .frame(width: 160, height: 210)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(appConfig.foreground, lineWidth: 2)
        )
        .onTapGesture {
            eventManager.isAddContactSheet.toggle()
        }
    }
}
struct ImageView: View {
    var image: String
    var name: String
    var titel: String
    var body: some View {
        
        VStack(alignment: .center) {
            Image(image)
                .resizable()
                .scaledToFit()
            
            VStack{
                Text(name)
                Text(titel)
                    .font(.callout)
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}
