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
    @EnvironmentObject var ads: AdsViewModel
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var tabManager: TabManager
    @EnvironmentObject var cal: MoodCalendar
    @EnvironmentObject var entitlementManager: EntitlementManager
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FocusState var focusedTask: EventTasks?
    @FetchRequest(sortDescriptors: [ SortDescriptor(\.startDate) ]) var events: FetchedResults<Event>
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    private var dateClosedRange: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .year, value: -5, to: Date())!
        let max = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        return min...max
    }
    
    var SortedContacts: [Contact] {
        return eventManager.contacts.sorted(by: { $0.name ?? "" < $1.name ?? "" })
    }
    
    var body: some View {
        GeometryReader { g in
            ZStack {
                VStack{
                    header()
                        .padding(.top, 20)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center, spacing: 5) {
                            
                            ForEach(Array(SortedContacts.enumerated()), id: \.1) { (index, contact) in
                                GeometryReader { geo in
                                    NavigateTo({
                                        ImageView(image: eventManager.getImage(contact.titel ?? "noImage") , name: contact.name ?? "Unbekannter Name", titel: contact.titel ?? "Unbekannter Titel" != "other" ? contact.titel ?? "Unbekannter Titel" : "Sonstiges"  )
                                            .rotation3DEffect(.degrees(-geo.frame(in: .global).minX) / 20, axis: (x: 0, y: 1, z: 0))
                                            .frame(width: 160, height: 200)
                                            .shadow(color: currentTheme.textBlack.opacity(0.5), radius: 10, x: 5, y: 5)
                                            .offset(y: -18)
                                    }, {
                                        ContactDetailView(contact: contact, iconColor: currentTheme.hightlightColor)
                                    })
                                }
                                .padding(.vertical, 40)
                                .frame(width: 160, height: 230)
                            }
                            
                            AddContact()
                                .frame(width: 160, height: 230)
                                .shadow(color: currentTheme.textBlack.opacity(0.5), radius: 10, x: 5, y: 5)
                               
                                
                        }
                        .padding(10)
                    }
                    .listRowBackground(currentTheme.text.opacity(0.001))
                    
                    if appConfig.EventShowCalendar {
                        ScrollView(showsIndicators: false, content: {
                            EventCalendar(events: events)
                        })
                    } else {
                        List {
                            EventSection(type: .thisWeek)
                            
                            EventSection(type: .nextWeek)
                            
                            EventSection(type: .thisMonth)
                            
                            EventSection(type: .nextMonth)

                            EventSection(type: .lastWeek, viewType: .diclosure, isExtended: appConfig.showAllPastEventsIsExtended)
                                .show(appConfig.showAllPastEvents)
                            
                            EventSection(type: .past, viewType: .diclosure, isExtended: appConfig.showPastWeekEventsIsExtended)
                                .listRowInsets(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
                                .show(appConfig.showPastWeekEvents)
                        }
                        //.frame(width: g.size.width - 5, height: g.size.height - 50, alignment: .center)
                        .scrollContentBackground(.hidden)
                        .foregroundColor(currentTheme.text)
                        .refreshable {
                            eventManager.fetchContacts()
                        }
                    }
                }
                .foregroundColor(currentTheme.text)
                .fullSizeTop()
                .blur( radius: cal.showCalendarPicker ? 4 : 0)
                
                if cal.showCalendarPicker {
                   VStack {
                       ZStack {
                           currentTheme.textBlack.opacity(0.5).ignoresSafeArea()
                           
                           VStack(spacing: 20) {
                               Spacer()
                               
                               HStack {
                                   Spacer()
                                   
                                   Button(action: {
                                       withAnimation(.easeInOut) {
                                           cal.showCalendarPicker = false
                                       }
                                   }, label: {
                                       Image(systemName: "xmark")
                                           .foregroundColor(currentTheme.text)
                                   })
                               }
                               .padding(.horizontal, 50)
                               
                               DatePicker(
                                   "",
                                   selection: $cal.selectedCalendarDate,
                                   //in: dateClosedRange,
                                   displayedComponents: .date
                               )
                               .labelsHidden()
                               .datePickerStyle(.wheel)
                               .background(.ultraThinMaterial)
                               .cornerRadius(20)
                               .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                               
                               Spacer()
                           }
                       }
                       
                       
                       Spacer()
                   }
                   
               }
            }
            .blurredOverlaySheet(.init(Material.ultraThinMaterial), show: $eventManager.isAddContactSheet, onDismiss: {
                // Show InterstitialSheet if not Pro
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    if !appConfig.hasPro {
                           ads.showInterstitial.toggle()
                    }
                })
            }, content: {
                ContentAddSheetBoby(titel: "New contact")
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            })
            .blurredOverlaySheet(.init(Material.ultraThinMaterial), show: $eventManager.isAddEventSheet, onDismiss: {
                // Show InterstitialSheet if not Pro
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    if !appConfig.hasPro {
                           ads.showInterstitial.toggle()
                    }
                })
            }, content: {
                EventAddSheetBoby(titel: "Create an appointment")
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            })
             .onAppear {
                 eventManager.fetchContacts()
                 
                 cal.selectedCalendarDate = Date()
                 cal.currentDate = Date()
                 cal.currentDates = cal.extractMonth()
              }
              .onChange(of: cal.selectedCalendarDate, perform: { (value) in
                  cal.selectedCalendarDate = value
                  cal.currentDate = value
                  cal.currentDates = cal.extractMonthByDate()
                  withAnimation(.easeInOut){
                      cal.showCalendarPicker = false
                  }
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
                    .foregroundColor(currentTheme.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Your appointments and notes at a glance.")
                    .font(.caption2)
                    .foregroundColor(currentTheme.textGray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack(spacing: 20){
                
                if !entitlementManager.hasPro {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(currentTheme.text)
                        .onTapGesture {
                            DispatchQueue.main.async {
                                tabManager.ishasProFeatureSheet.toggle()
                            }
                        }
                }
                
                Image(systemName: appConfig.EventShowCalendar ? "calendar" : "list.bullet.below.rectangle")
                    .foregroundColor(currentTheme.text)
                    .font(.title3)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.5)){
                            appConfig.EventShowCalendar.toggle()
                        }
                    }
                
                Image(systemName: "gearshape")
                    .foregroundColor(currentTheme.text)
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
                    .foregroundColor(currentTheme.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer()
            VStack(){
                Image(systemName: "gearshape")
                    .font(.title3)
                    .foregroundColor(currentTheme.text)
                    .onTapGesture {
                        tabManager.isSettingSheet.toggle()
                    }
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
    }
}


struct AddContact: View {
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    var body: some View {
        VStack(spacing: 10){
            Image(systemName: "plus")
                .multilineTextAlignment(.center)
            Text("Add \n Contact")
                .multilineTextAlignment(.center)
        }
        .foregroundColor(currentTheme.text)
        .frame(width: 160, height: 210)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(currentTheme.text, lineWidth: 2)
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
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    var body: some View {
        
        VStack(alignment: .center) {
            Image(image)
                .resizable()
                .scaledToFit()
            
            VStack{
                Text(name)
                Text(LocalizedStringKey(titel))
                    .font(.callout)
                    .foregroundColor(currentTheme.textGray)
            }
            .padding()
        }
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}
