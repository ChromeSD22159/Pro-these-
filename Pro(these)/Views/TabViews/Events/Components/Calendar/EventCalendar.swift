//
//  EventCalendar.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 09.06.23.
//

import SwiftUI
import CoreData

struct EventCalendar: View {
    @EnvironmentObject var cal: MoodCalendar
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    private let persistenceController = PersistenceController.shared
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var events: FetchedResults<Event>

    @State var viewState = CGSize.zero
    
    @Namespace var bottomID
    
    var body: some View {
       GeometryReader { screen in
           VStack(spacing: 20) {
               CalendarControl()
               
               
               /// Header Days
               HStack(spacing: 0) {
                  
                   ForEach(Date().extractWeekByDate, id: \.weekday) { day in
                       Text("\(day.weekday)")
                           .font(.callout)
                           .fontWeight(.semibold)
                           .frame(maxWidth: .infinity)
                           .foregroundColor(currentTheme.text)
                   }
                   
               }
               .padding(.horizontal, 20)
               
               /// Calendar View
               LazyVGrid(columns: columns, spacing: 10) {
                   ForEach(cal.currentDates) { value in
                       DayButton(value: value, screenSize: screen.size)
                   }
               }
               .padding(.horizontal, 20)
               .gesture(
                   DragGesture()
                     .onChanged() { value in
                         viewState = value.translation
                     }
                     .onEnded { proxy in
                         let height = proxy.translation.height
                         let width = proxy.translation.width
                         
                         if width <= -150 && height > -30 && height < 30  {
                             cal.selectedCalendarDate = Calendar.current.date(byAdding: .month, value: +1, to: cal.selectedCalendarDate)!
                         }
                         
                         if width >= 150 && height > -30 && height < 30  {
                             cal.selectedCalendarDate = Calendar.current.date(byAdding: .month, value: -1, to: cal.selectedCalendarDate)!
                         }
                     }
             ) // gesture

               /// List Events
               ListSelectedEvents()
           }
           
       }
        
    }

    @ViewBuilder
    func CalendarControl() -> some View {
        HStack{
               if !cal.showCalendarPicker {
                   Button(action: {
                       cal.selectedCalendarDate = Calendar.current.date(byAdding: .month, value: -1, to: cal.selectedCalendarDate)!
                         
                     }, label: {
                         Image(systemName: "chevron.left")
                             .font(.title2)
                             .foregroundColor(currentTheme.text)
                     })
                     
                     Spacer()
                     
                     Button(action: {
                         withAnimation(.easeInOut){
                             cal.showCalendarPicker = true
                         }
                     }, label: {
                         Text(cal.currentDate.dateFormatte(date: "MMM yyyy", time: "").date)
                         
                     })
                     .frame(maxWidth: .infinity)
                     
                     Spacer()
                     
                     Button(action: {
                         cal.selectedCalendarDate = Calendar.current.date(byAdding: .month, value: +1, to: cal.selectedCalendarDate)!
                     }, label: {
                         Image(systemName: "chevron.right")
                             .font(.title2)
                             .foregroundColor(currentTheme.text)
                     })
               }
           }
           .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    func ListSelectedEvents() -> some View {
        
        let selectedEvents = events.filter( { return cal.isSameDay(d1: $0.startDate ?? Date(), d2: cal.currentDate) })
        Section(content: {
            
            if selectedEvents.count > 0 {
                ForEach( selectedEvents, id: \.startDate ){ item in
                    NavigateTo({
                        EventPreview(item: item)
                    }, {
                        EventDetailView( iconColor: currentTheme.hightlightColor, item: item)
                    })
                }
            } else {
                HStack {
                    Text("No appointment")
                }
                .padding()
            }
        })
        .tint(currentTheme.text)
        .listRowBackground(currentTheme.text.opacity(0.05))
        .padding(.bottom, 50)

    }
    
    @ViewBuilder // MARK: - Calendar Day Circle
    func DayButton(value: DateValue, screenSize: CGSize) -> some View {
       VStack(spacing: 10) {
           
           let itemWidth = screenSize.width / 14
           
           if value.day != -1 {

               if let event = events.first(where: { return cal.isSameDay(d1: $0.startDate ?? Date(), d2: value.date) }) {
                   let ev = events.map( { return  cal.isSameDay(d1: $0.startDate ?? Date(), d2: value.date) ? Int(($0.titel?.trimFeelings()) ?? "") : nil } )
                   if ev.count > 0 {
                    
                       // Found feeling
                       VStack(spacing: 5){
                           Circle()
                               .strokeBorder(cal.isSameDay(d1: value.date , d2: cal.currentDate) ? currentTheme.text.opacity(1) : value.date > Date() ? currentTheme.text.opacity(0.05) : currentTheme.text.opacity(0.5), lineWidth: 1)
                               .background{
                                   ZStack{
                                       Circle().foregroundColor( value.date > Date() ? currentTheme.text.opacity(0.05) : currentTheme.text.opacity(0.1))
                                       
                                       //let _ = print(eventManager.getIcon(event.contact?.titel ?? ""))
                                       
                                       Image(systemName: eventManager.getIcon(event.contact?.titel ?? "") )
                                           .font(.callout)
                                           .foregroundColor( cal.isSameDay(d1: event.startDate ?? Date() , d2: value.date) ? currentTheme.hightlightColor : currentTheme.text.opacity(0))
                                           .clipShape(Circle())
                                   }
                               }
                               .frame(width: itemWidth, height: itemWidth )
                               .onTapGesture {
                                   cal.currentDate = value.date
                               }
                       }
                       .padding(5)
                        
                       
                   } // Mapfeeltings
                   
               } else {
                   // none Event
                   VStack(spacing: 5){
                       Circle()
                           .strokeBorder(cal.isSameDay(d1: value.date , d2: cal.currentDate) ? currentTheme.text.opacity(1) : value.date > Date() ? currentTheme.text.opacity(0.05) : currentTheme.text.opacity(0.5), lineWidth: 1)
                           .background(
                               ZStack{
                                   Circle().foregroundColor( value.date > Date() ? currentTheme.text.opacity(0.05) : currentTheme.text.opacity(0.1))
                                   
                                   Text("\(value.day)")
                                      .font(.footnote)
                                      .foregroundColor(currentTheme.text.opacity(0.3))
                               }
                           )
                           .frame(width: itemWidth, height: itemWidth )
                           .onTapGesture(perform: {
                               cal.currentDate = value.date
                               
                               if value.date >= Date() || cal.isSameDay(d1: value.date , d2: Date()) {
                                   // openAddEventSheet set date + 1
                                   eventManager.openAddEventSheet(date: Calendar.current.date(byAdding: .day, value: -1, to: value.date)!)
                               }
                               
                           })
                       
                   }
                   .padding(5)
               }
                   
           }
       }
       .onTapGesture(perform: {
           cal.currentDate = value.date
       })
    }
}
