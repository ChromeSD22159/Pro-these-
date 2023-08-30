//
//  FeelingCalendarView.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 23.05.23.
//

import SwiftUI

struct FeelingCalendarView: View {
    @EnvironmentObject var cal: MoodCalendar
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var ads: AdsViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    private let persistenceController = PersistenceController.shared
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var feelings: FetchedResults<Feeling>

    @State var viewState = CGSize.zero
    
    @Namespace var bottomID
    
    var body: some View {
       GeometryReader { screen in
           
           ScrollView(showsIndicators: false, content: {
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
                   
                ListSelectedDateMoods(screenSize: screen.size)
               }
               // MARK: - Sheet
               .blurredOverlaySheet(.init(.ultraThinMaterial), show: $cal.isFeelingSheet, onDismiss: {
                   // Show InterstitialSheet if not Pro
                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                       if !appConfig.hasPro {
                              ads.showInterstitial.toggle()
                       }
                   })
                   
                   cal.editFeeling = nil
               }, content: {
                   AddFeelingSheetBody()
               })
           })
           
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
                      .foregroundColor(currentTheme.text)
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
    
    func groupingAndCountingProtheses(date: Date) -> [Dictionary<Prothese, Int>.Element] {
        
        let fe = feelings.filter({ return cal.isSameDay(d1: $0.date ?? Date(), d2: date) })
        
        let proth = fe.compactMap({
            return $0.prothese
        })
        
        let groupedProtheses = Dictionary(grouping: proth, by: { $0 }).mapValues({ items in items.count }).sorted(by: {
            $0.value > $1.value
        })

        return groupedProtheses
    }

    @ViewBuilder // MARK: - Calendar Day Circle
    func DayButton(value: DateValue, screenSize: CGSize) -> some View {
       VStack(spacing: 10) {
           if value.day != -1 {

               if let feeling = feelings.first(where: { return cal.isSameDay(d1: $0.date ?? Date(), d2: value.date) }) {
                   let fe = feelings.map( { return  cal.isSameDay(d1: $0.date ?? Date(), d2: value.date) ? Int(($0.name?.trimFeelings()) ?? "") : nil } )
                   
                   if fe.count > 0 {

                       let avg:Int = fe.compactMap{ $0 }.reduce(0, +) / fe.compactMap{ $0 }.count

                       // Found feeling
                       VStack(spacing: 5){
                           Circle()
                               .strokeBorder(.clear, lineWidth: 1)
                               .background{
                                   ZStack{
                                       let size = screenSize.width / 9
                                       
                                       Circle().foregroundColor( cal.isSameDay(d1: feeling.date ?? Date() , d2: value.date) ? feelingBackgroundColor(feeling.name!) : currentTheme.textGray.opacity(0))
                                            .frame(width: size, height: size )
                                       Image("chart_feeling_" + String(avg) ) //  + String(feeling.name?.trimFeelings() ?? "")
                                           .resizable()
                                           .scaledToFit()
                                           .foregroundColor( cal.isSameDay(d1: feeling.date ?? Date() , d2: value.date) ? currentTheme.textGray : currentTheme.text.opacity(0))
                                           //.font(.system(size: screenSize.width / 8, weight: .semibold))
                                           .imageScale(.large)
                                           .clipShape(Circle())
                                       
                                      // if let icon = feeling.prothese?.prosthesisIcon {
                                       if let icon = groupingAndCountingProtheses(date: value.date).first?.key.prosthesisIcon {
                                           Image(icon)
                                               .font(.body.bold())
                                               .foregroundStyle(currentTheme.hightlightColor, currentTheme.textGray)
                                               .background {
                                                   ZStack {
                                                       Circle()
                                                           .fill(.ultraThickMaterial)
                                                           .frame(width: screenSize.width / 16, height: screenSize.width / 16 )
                                                           .shadow(color: .black, radius: 5)
                                                       
                                                       Circle()
                                                           .stroke(currentTheme.text, lineWidth: 1)
                                                           .frame(width: screenSize.width / 16, height: screenSize.width / 16 )
                                                   }
                                               }
                                               .offset(x: size / 2.5, y: -size / 2.5)
                                       }
                                       
                                       
                                   }
                               }
                               .onTapGesture(perform: {
                                   cal.isFeelingSheet.toggle()
                                   cal.editFeeling = nil
                                   print("none feeling")
                                   let calendar = Calendar.current
                                   var dateComponents = DateComponents()
                                   dateComponents.year = calendar.component(.year, from: value.date)
                                   dateComponents.month = calendar.component(.month, from: value.date)
                                   dateComponents.day = calendar.component(.day, from: value.date)
                                   dateComponents.hour = calendar.component(.hour, from: Date())
                                   dateComponents.minute = calendar.component(.minute, from: Date())
                                   
                                   cal.addFeelingDate = Calendar.current.date(from: dateComponents)!
                               })
                               .frame(width: screenSize.width / 9, height: screenSize.width / 9 )
                           
                           VStack{
                               Text("\(value.day)")
                                   .font(.system(size: 10))
                                   .foregroundColor(currentTheme.text)
                           }
                           .frame(maxWidth: .infinity)
                           .padding(.vertical, 5)
                           .padding(.horizontal, 10)
                           .background(cal.isSameDay(d1: value.date , d2: cal.currentDate) ? currentTheme.textGray.opacity(0.1) : currentTheme.textGray.opacity(0))
                           .onTapGesture(perform: {
                               cal.currentDate = value.date
                           })
                           .cornerRadius(20)
                       }
                       .padding(5)
                        
                       
                   } // Mapfeeltings
                   
               } else {
                   // none feeling
                   VStack(spacing: 5){
                       Circle()
                           .strokeBorder(value.date > Date() ? currentTheme.textGray.opacity(0.05) : currentTheme.textGray.opacity(0.5), lineWidth: 1)
                           .background(
                               ZStack{
                                   Circle().foregroundColor( value.date > Date() ? currentTheme.textGray.opacity(0.05) : currentTheme.textGray.opacity(0.1))
                                   if value.date > Date() {
                                       Text("\(value.day)")
                                          .font(.footnote)
                                          .foregroundColor(currentTheme.textGray.opacity(0.3))
                                   } else {
                                       Image("figure.prothese")
                                           .font(.title)
                                           .foregroundColor(currentTheme.textGray.opacity(0.1))
                                   }
                               }
                           )
                           .frame(width: screenSize.width / 9, height: screenSize.width / 9 )
                           .onTapGesture(perform: {
                               if value.date < Date().startEndOfDay().end || Calendar.current.isDateInToday(value.date) {
                                   cal.isFeelingSheet.toggle()
                                   cal.editFeeling = nil
                                   print("none feeling")
                                   let calendar = Calendar.current
                                   var dateComponents = DateComponents()
                                   dateComponents.year = calendar.component(.year, from: value.date)
                                   dateComponents.month = calendar.component(.month, from: value.date)
                                   dateComponents.day = calendar.component(.day, from: value.date)
                                   dateComponents.hour = calendar.component(.hour, from: Date())
                                   dateComponents.minute = calendar.component(.minute, from: Date())
                                   
                                   cal.addFeelingDate = Calendar.current.date(from: dateComponents)!
                               }
                           })
                       
                       VStack{
                           Text(value.date > Date() ? "" : "\(value.day)")
                               .font(.system(size: 10))
                               .foregroundColor(currentTheme.text)
                       }
                       .frame(maxWidth: .infinity)
                       .padding(.vertical, 5)
                       .padding(.horizontal, 10)
                       .background(cal.isSameDay(d1: value.date , d2: cal.currentDate) ? currentTheme.textGray.opacity(0.1) : currentTheme.textGray.opacity(0))
                       .cornerRadius(20)
                       .onTapGesture(perform: {
                           cal.currentDate = value.date
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
    
    @ViewBuilder
    func ListSelectedDateMoods(screenSize: CGSize) -> some View {
        let feelings = feelings.filter({ cal.isSameDay(d1: $0.date ?? Date(), d2: cal.currentDate) })
        if  feelings.count > 0 {
            VStack{
                let current = cal.currentDate.dateFormatte(date: "dd.MM.yy", time: "HH:mm")
                
                HStack{
                    Text("Entries from: ")
                        .foregroundColor(currentTheme.text)
                    Text("\(current.date)")
                        .font(.callout.weight(.semibold))
                        .foregroundColor(currentTheme.hightlightColor)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)

                ScrollViewReader { value in
                    ScrollView(.horizontal, showsIndicators: false){
                        
                        let sortedFeelings = feelings.sorted(by: {
                            $0.date!.compare($1.date!) == .orderedAscending
                        })
                        
                        HStack(alignment: .center, spacing: 20){
                            ForEach(sortedFeelings, id: \.self) { feeling in

                                VStack(spacing: 5){
                                    ZStack{
                                        Image("chart_" + feeling.name! )
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(Circle())
                                            .frame(width: screenSize.width / 8, height: screenSize.width / 8 )

                                        if let icon = feeling.prothese?.prosthesisIcon {
                                            Image(icon)
                                                .font(.body.bold())
                                                .foregroundStyle(currentTheme.hightlightColor, currentTheme.textGray)
                                                .background {
                                                    ZStack {
                                                        Circle()
                                                            .fill(.ultraThickMaterial)
                                                            .frame(width: screenSize.width / 16, height: screenSize.width / 16 )
                                                            .shadow(color: .black, radius: 5)
                                                        
                                                        Circle()
                                                            .stroke(currentTheme.text, lineWidth: 1)
                                                            .frame(width: screenSize.width / 16, height: screenSize.width / 16 )
                                                    }
                                                }
                                                .offset(x: (screenSize.width / 8) / 2.5, y: -(screenSize.width / 8) / 2.5)
                                        }
                                    }
                                    
                                    VStack{
                                        let feel = feeling.date!.dateFormatte(date: "dd.MM.yy", time: "HH:mm")
                                        Text("\(feel.time)")
                                            .font(.caption2)
                                            .foregroundColor(currentTheme.text)
                                    }
                                }
                                .padding(.top)
                                .padding(5)
                                .onTapGesture {
                                    cal.isCalendar = false
                                    cal.currentDate = feeling.date!
                                    print("tapped: \(cal.currentDate)")
                                }
                                
                            } // Foreach
                            
                            Text("").id(bottomID)
                            
                        } // Hstack
                    } // scrollview
                    .onChange(of: cal.currentDate){ new in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                            withAnimation(.easeInOut(duration: 2.5)){
                                value.scrollTo(bottomID)
                            }
                        }
                    }
                    .onAppear{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                            withAnimation(.easeInOut(duration: 2.5)){
                                value.scrollTo(bottomID)
                            }
                        }
                    }
                }
                
            }
        }
    }
    
    // MARK: - Return the Mood Color for each Mood name
    func feelingBackgroundColor(_ string: String) -> Color {
        switch string {
        case "feeling_1": return .green
        case "feeling_2": return .green
        case "feeling_3": return .yellow
        case "feeling_4": return .orange
        case "feeling_5": return .red
        default: return currentTheme.textGray.opacity(0.1)
        }
    }
}


struct FeelingCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Theme.blue.gradientBackground(nil).ignoresSafeArea()
            
            AddFeelingSheetBody()
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

struct ScrollingHStackModifier: ViewModifier {
    
    @State private var scrollOffset: CGFloat
    @State private var dragOffset: CGFloat
    
    var items: Int
    var itemWidth: CGFloat
    var itemSpacing: CGFloat
    
    init(items: Int, itemWidth: CGFloat, itemSpacing: CGFloat) {
        self.items = items
        self.itemWidth = itemWidth
        self.itemSpacing = itemSpacing
        
        // Calculate Total Content Width
        let contentWidth: CGFloat = CGFloat(items) * itemWidth + CGFloat(items - 1) * itemSpacing
        let screenWidth = UIScreen.main.bounds.width
        
        // Set Initial Offset to first Item
        let initialOffset = (contentWidth/2.0) - (screenWidth/2.0) + ((screenWidth - itemWidth) / 2.0)
        
        self._scrollOffset = State(initialValue: initialOffset)
        self._dragOffset = State(initialValue: 0)
    }
    
    func body(content: Content) -> some View {
        content
            .offset(x: scrollOffset + dragOffset, y: 0)
            .gesture(DragGesture()
                .onChanged({ event in
                    dragOffset = event.translation.width
                })
                .onEnded({ event in
                    // Scroll to where user dragged
                    scrollOffset += event.translation.width
                    dragOffset = 0
                    
                    // Now calculate which item to snap to
                    let contentWidth: CGFloat = CGFloat(items) * itemWidth + CGFloat(items - 1) * itemSpacing
                    let screenWidth = UIScreen.main.bounds.width
                    
                    // Center position of current offset
                    let center = scrollOffset + (screenWidth / 2.0) + (contentWidth / 2.0)
                    
                    // Calculate which item we are closest to using the defined size
                    var index = (center - (screenWidth / 2.0)) / (itemWidth + itemSpacing)
                    
                    // Should we stay at current index or are we closer to the next item...
                    if index.remainder(dividingBy: 1) > 0.5 {
                        index += 1
                    } else {
                        index = CGFloat(Int(index))
                    }
                    
                    // Protect from scrolling out of bounds
                    index = min(index, CGFloat(items) - 1)
                    index = max(index, 0)
                    
                    // Set final offset (snapping to item)
                    let newOffset = index * itemWidth + (index - 1) * itemSpacing - (contentWidth / 2.0) + (screenWidth / 2.0) - ((screenWidth - itemWidth) / 2.0) + itemSpacing
                    
                    // Animate snapping
                    withAnimation {
                        scrollOffset = newOffset
                    }
                    
                })
            )
    }
}
