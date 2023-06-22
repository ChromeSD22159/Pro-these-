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
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    private let persistenceController = PersistenceController.shared
    
    private let days: [String] = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var events: FetchedResults<Event>

    @State var viewState = CGSize.zero
    
    @Namespace var bottomID
    
    var body: some View {
       GeometryReader { screen in
           VStack(spacing: 20) {
               
               // prev / next Month
               HStack{
                   Button(action: {
                       cal.currentMonth -= 1
                   }, label: {
                       Image(systemName: "chevron.left")
                           .font(.title2)
                           .foregroundColor(.white)
                   })
                   
                   Spacer()
                   
                   Text(cal.currentDate.dateFormatte(date: "MMMM YYYY", time: "HH:mm").date)
                       .foregroundColor(.white)
                   
                   Spacer()
                   
                   Button(action: {
                       cal.currentMonth += 1
                   }, label: {
                       Image(systemName: "chevron.right")
                           .font(.title2)
                           .foregroundColor(.white)
                   })
               }
               .padding(.horizontal, 20)
               
               /// Header Days
               HStack(spacing: 0) {
                  
                   ForEach(days, id: \.self) { day in
                       Text("\(day)")
                           .font(.callout)
                           .fontWeight(.semibold)
                           .frame(maxWidth: .infinity)
                           .foregroundColor(.white)
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
                             cal.currentMonth += 1
                         }
                         
                         if width >= 150 && height > -30 && height < 30  {
                             cal.currentMonth -= 1
                         }
                     }
             ) // gesture
               
               
               /// List Events
               ListSelectedEvents()
           }
           
       }
        
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
                        EventDetailView( iconColor: .yellow, item: item)
                    })
                }
            } else {
                HStack {
                    Text("Kein Termin")
                }
                .padding()
            }
        })
        .tint(AppConfig.shared.fontColor)
        .listRowBackground(Color.white.opacity(0.05))
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
                               .strokeBorder(cal.isSameDay(d1: value.date , d2: cal.currentDate) ? Color.white.opacity(1) : value.date > Date() ? .white.opacity(0.05) : .white.opacity(0.5), lineWidth: 1)
                               .background{
                                   ZStack{
                                       Circle().foregroundColor( value.date > Date() ? Color.white.opacity(0.05) : Color.white.opacity(0.1))
                                       
                                       Image(systemName: eventManager.getIcon(event.contact?.titel ?? "") )
                                           .font(.callout)
                                           .foregroundColor( cal.isSameDay(d1: event.startDate ?? Date() , d2: value.date) ? Color.yellow : Color.white.opacity(0))
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
                           .strokeBorder(cal.isSameDay(d1: value.date , d2: cal.currentDate) ? Color.white.opacity(1) : value.date > Date() ? .white.opacity(0.05) : .white.opacity(0.5), lineWidth: 1)
                           .background(
                               ZStack{
                                   Circle().foregroundColor( value.date > Date() ? Color.white.opacity(0.05) : Color.white.opacity(0.1))
                                   
                                   Text("\(value.day)")
                                      .font(.footnote)
                                      .foregroundColor(.white.opacity(0.3))
                               }
                           )
                           .frame(width: itemWidth, height: itemWidth )
                           .onTapGesture(perform: {
                               cal.currentDate = value.date
                               
                               if value.date >= Date() || cal.isSameDay(d1: value.date , d2: Date()) {
                                   eventManager.openAddEventSheet(date: value.date)
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
