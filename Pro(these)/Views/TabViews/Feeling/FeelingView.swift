//
//  FeelingView.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 17.05.23.
//

import SwiftUI
import CoreData
import WidgetKit

struct FeelingView: View {
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var ads: AdsViewModel

    @EnvironmentObject var pushNotificationManager: PushNotificationManager
    @EnvironmentObject var cal: MoodCalendar
    @EnvironmentObject var tabManager: TabManager
    @EnvironmentObject var entitlementManager: EntitlementManager
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    @FetchRequest(sortDescriptors: [ SortDescriptor(\.date) ]) var listFeelings: FetchedResults<Feeling>
    
    @Namespace var bottomID
    @Namespace var dateID
    @Namespace var noneID
   
    @State var attempts: Int = 0
    @State var isScreenShotSheet = false
    
    private var dateClosedRange: ClosedRange<Date> {
       let min = Calendar.current.date(byAdding: .year, value: -5, to: Date())!
       let max = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
       return min...max
    }
    
    @State var showTimePicker = false
    var body: some View {
        
        ZStack {
            VStack(spacing: 20){
                
                header()
                
                GlockRow()
                
                if cal.isCalendar {
                    FeelingCalendarView(feelings: listFeelings)
                } else {
                    FeelingListView(listFeelings: listFeelings)
                }
                
            }
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
                               in: dateClosedRange,
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
        .onAppear {
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
        
        // MARK: - Sheet
        .blurredOverlaySheet(.init(.ultraThinMaterial), show: $cal.isFeelingSheet, onDismiss: {
            // Show InterstitialSheet if not Pro
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                if !appConfig.hasPro {
                       ads.showInterstitial.toggle()
                }
            })
        }, content: {
            AddFeelingSheetBody()
        })
        
    }
    
    @ViewBuilder
    func GlockRow() -> some View {
        HStack(spacing: 10) {
            Spacer()
            
            
            HStack(spacing: 10) {
                Button(action: {
                    withAnimation(.easeInOut) {
                        if appConfig.hasPro {
                            appConfig.PushNotificationDailyMoodRemembering.toggle()
                        } else {
                            appConfig.PushNotificationDailyMoodRemembering = true
                        }
                    }
                }, label: {
                    Image(systemName: appConfig.PushNotificationDailyMoodRemembering ? "bell" : "bell.slash")
                        .padding(.vertical, 5)
                        .font(.title3)
                        .foregroundColor( appConfig.hasPro ? appConfig.PushNotificationDailyMoodRemembering ? currentTheme.hightlightColor : currentTheme.textGray : currentTheme.textGray)
                })
                .disabled(!appConfig.hasPro)
               
                
                if appConfig.PushNotificationDailyMoodRemembering {
                    Button {
                        withAnimation {
                            showTimePicker.toggle()
                        }
                    }  label: {
                        Text(appConfig.PushNotificationDailyMoodRememberingDate.dateFormatte(date: "", time: "HH:mm").time)
                            .padding(.vertical, 5)
                            .foregroundColor(currentTheme.text)
                    }
                    .offset(x: appConfig.PushNotificationDailyMoodRemembering ? 0 : 150)
                    .background(
                        DatePicker("", selection: $appConfig.PushNotificationDailyMoodRememberingDate, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .frame(width: 200, height: 100)
                            .clipped()
                            .background(currentTheme.textGray.cornerRadius(10))
                            .opacity(showTimePicker ? 1 : 0 )
                            .offset(x: -65, y: 90)
                    )
                }

            }
        }
        .padding(.horizontal)
        .zIndex(1)
    }
    
    @ViewBuilder
    func header() -> some View {
        HStack(){
            VStack(spacing: 2){
                sayHallo(name: AppConfig.shared.username)
                    .font(.title2)
                    .foregroundColor(currentTheme.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Keep track of your mood with the prosthesis.")
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
                
                Image(systemName: cal.isCalendar ? "calendar" : "list.bullet.below.rectangle")
                    .foregroundColor(currentTheme.text)
                    .font(.title3)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.5)){
                            cal.isCalendar.toggle()
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
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func FeelingListView(listFeelings: FetchedResults<Feeling>) -> some View {
        GeometryReader { screen in
            
            VStack(spacing: 10) {
                
                let sortedDates = cal.currentDates.sorted(by: {
                    $0.date.compare($1.date) == .orderedDescending
                })
                
               
                
                ScrollViewReader { scrollProxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        ForEach(sortedDates) { value in
                            // Max Date till now
                            if value.date < Date().startEndOfDay().end && value.day != -1 || Calendar.current.isDateInToday(value.date) && value.day != -1 {
                                
                                // predicate Dates with Feelings
                                if let _ = listFeelings.first(where: { return cal.isSameDay(d1: $0.date ?? Date(), d2: value.date) }) {
                                    ListSelectedDateMoods(date: value.date ,screenSize: screen.size)
                                        .padding(.horizontal, 20)
                                        
                                }

                            }
                            
                          
                        } // f
                    } // s
                    .onAppear{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                            // scroll to Tapped Date
                            withAnimation(.easeInOut(duration: 2.5)){
                                scrollProxy.scrollTo(dateID)
                                
                            }
                            
                            // Shake to Date Item .modifier(Shake(animatableData: CGFloat(cal.isSameDay(d1: date, d2: cal.currentDate) ? attempts : 0 )))
                            withAnimation(.easeInOut(duration: 0.5).delay(0.5)){
                                self.attempts += 1
                            }
                        }
                    }
                    
                    
                } // ScrollViewReader
                
            }
            // AddNewFeeling
            .blurredOverlaySheet(.init(.ultraThinMaterial), show: $cal.isFeelingSheet, onDismiss: {
                // Show InterstitialSheet if not Pro
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    if !appConfig.hasPro {
                           ads.showInterstitial.toggle()
                    }
                })
            }, content: {
                AddFeelingSheetBody()
            })
            
        }
    }
    
    @ViewBuilder
    func ListSelectedDateMoods(date: Date ,screenSize: CGSize) -> some View {
        let feelings = listFeelings.filter({ cal.isSameDay(d1: $0.date ?? Date(), d2: date) })

        if feelings.count > 0 {
            feelingDayRow(feelings: feelings, screenSize: screenSize, date: date, attempts: $attempts, bottomID: bottomID, dateID: dateID, noneID: noneID )
        }
    }
}

struct feelingRowItem: View {
    var feeling: Feeling
    var screenSize: CGSize
    
    @State var confirm = false
    @EnvironmentObject var cal: MoodCalendar
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    private let persistenceController = PersistenceController.shared.container.viewContext
    
    private var feelingDate: (date: String, time: String) {
        return self.feeling.date?.dateFormatte(date: "dd.MM.yy", time: "HH:mm") ?? (date: "String", time: "String")
    }
    
    var body: some View {
        VStack(spacing: 5){
            ZStack{
                let size = screenSize.width / 8
                
                Image("chart_" + (feeling.name ?? "feeling_1") )
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: size, height: size )
                
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
                        .offset(x: (size) / 2.5, y: -(size) / 2.5)
                }
            }
            
            VStack{
                Text("\(feelingDate.time)")
                    .font(.caption2)
                    .foregroundColor(currentTheme.text)
            }
        }
        .padding(.top, feeling.prothese?.prosthesisIcon != nil ? 5 : 0)
        .padding(5)
        .onTapGesture {
            confirm = true
            cal.editFeeling = feeling
        }
        .confirmationDialog("Delete entry from \(feelingDate.date) ", isPresented: $confirm) {
           
            Button("To edit this entry??", role: .destructive) {
                cal.isFeelingSheet.toggle()
                print(feeling)
                cal.editFeeling = feeling
            }
            .font(.callout)
            
            Button("Delete Entry?", role: .destructive) {
                withAnimation{
                    persistenceController.delete(feeling)
                }
                
                do {
                    try persistenceController.save()
                    WidgetCenter.shared.reloadAllTimelines()
                } catch {
                    print("Entry from \(feelingDate.date) \(feelingDate.time) deleted! ")
                }
            }
            .font(.callout)
            
            
            
        } // Confirm
    }
}

struct feelingDayRow: View {
    
    var feelings: [FetchedResults<Feeling>.Element]
    var screenSize: CGSize
    var date: Date
    
    @Binding var attempts: Int

    var bottomID: Namespace.ID
    var dateID: Namespace.ID
    var noneID: Namespace.ID
    
    @EnvironmentObject var cal: MoodCalendar
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @State private var confirm = false
    
    private let viewContext = PersistenceController.shared.container.viewContext
    
    private var current: (date: String, time: String) {
        return self.date.dateFormatte(date: "dd.MM.yy", time: "HH:mm")
    }
    
    private var sortedFeelings: [FetchedResults<Feeling>.Element] {
        return self.feelings.sorted(by: { $0.date?.compare($1.date!) == .orderedAscending })
    }
    
    var body: some View {
        VStack{
            
            HStack{
                Text("\(current.date)")
                    .font(.body.weight(.semibold))
                    .foregroundColor(currentTheme.hightlightColor)
                
                Spacer()
                
                Image(systemName: "ellipsis")
                    .foregroundColor(currentTheme.text)
                    .font(.title3)
                    .rotationEffect(Angle(degrees: -90))
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.5)){
                            confirm.toggle()
                        }
                    }
            }
            .padding(.horizontal)
            
            ScrollViewReader { value in
                ScrollView(.horizontal, showsIndicators: false){

                    HStack(alignment: .center, spacing: screenSize.width / 8){
                        Text("").id("")
                        
                        ForEach(sortedFeelings, id: \.self) { feeling in
                            let _ = feeling.date?.dateFormatte(date: "dd.MM.yy", time: "HH:mm")
                            feelingRowItem(feeling: feeling, screenSize: screenSize)
                            
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
            .confirmationDialog("All entries from \(current.date)", isPresented: $confirm) {
                Button("Delete all entries", role: .destructive) {
                    for feel in sortedFeelings {
                        let d = feel.date?.dateFormatte(date: "dd.MM.yy", time: "HH:mm")
                        
                        withAnimation{
                            viewContext.delete(feel)
                        }
                        
                        do {
                            try viewContext.save()
                            WidgetCenter.shared.reloadAllTimelines()
                        } catch {
                            print("Entry from \(String(describing: d?.date)) \(String(describing: d?.time)) deleted!")
                        }
                    }
                } 
            }
            
        }
        .padding(.vertical)
        .background(.ultraThinMaterial.opacity(0.5))
        .cornerRadius(20)
        .id(cal.isSameDay(d1: date, d2: cal.currentDate) ? dateID : noneID)
        .modifier(Shake(animatableData: CGFloat(cal.isSameDay(d1: date, d2: cal.currentDate) ? attempts : 0 )))
        
    }
}

struct FeelingView_Previews: PreviewProvider {
    var themeManager = ThemeManager()
    
    static var currentTheme: Theme {
        return ThemeManager().currentTheme()
    }
    
    static var previews: some View {
        ZStack {
            currentTheme.backgroundColor.ignoresSafeArea()
            
            AddFeelingSheetBody()
                .environmentObject(MoodCalendar())
                .environmentObject(TabManager())
                .environmentObject(EntitlementManager())
                .colorScheme(.dark)
        }
    }
}
