//
//  FeelingView.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 17.05.23.
//

import SwiftUI
import CoreData

struct FeelingView: View {
    
    @EnvironmentObject var cal: MoodCalendar
    @EnvironmentObject var tabManager: TabManager
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(sortDescriptors: [ SortDescriptor(\.date) ]) var listFeelings: FetchedResults<Feeling>
    
    @Namespace var bottomID
    @Namespace var dateID
    @Namespace var noneID
   
    @State var attempts: Int = 0
    @State var isScreenShotSheet = false
    var body: some View {
        VStack(spacing: 20){
            
            HStack(){
                VStack(spacing: 2){
                    Text("Hallo, \(AppConfig.shared.username)")
                        .font(.title2)
                        .foregroundColor(AppConfig.shared.fontColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Dein Tagesziel ist für heute \(AppConfig.shared.targetSteps) Schritte")
                        .font(.callout)
                        .foregroundColor(AppConfig.shared.fontLight)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                HStack(spacing: 20){
                    Image(systemName: cal.isCalendar ? "calendar" : "list.bullet.below.rectangle")
                        .foregroundColor(AppConfig.shared.fontColor)
                        .font(.title3)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.5)){
                                cal.isCalendar.toggle()
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
            .padding(.top, 20)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            
            if cal.isCalendar {
                FeelingCalendarView(feelings: listFeelings)
                
                Spacer()
            } else {
                FeelingListView(listFeelings: listFeelings)
            }

        }
        .onAppear{
            cal.checkNotificationExistAndRegister(identifier: "PROTHESE_MOOD_REMINDER_DAILY_1")
            cal.currentDate = Date()
            cal.currentDates = cal.extractMonth()
        }
        // MARK: - Set Current Month to the selected Date and Extract the current Month
        .onChange(of: cal.currentMonth, perform: { value in
            cal.currentDate = cal.getCurrentMonth()
            cal.currentDates = cal.extractMonth()
            
        })
        // MARK: - Sheet
        .blurredOverlaySheet(.init(.ultraThinMaterial), show: $cal.isFeelingSheet, onDismiss: {}, content: {
            AddFeelingSheetBody()
        })
        
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
                            if value.date < Date().endOfDay() && value.day != -1 || Calendar.current.isDateInToday(value.date) && value.day != -1 {
                                
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
            .blurredOverlaySheet(.init(.ultraThinMaterial), show: $cal.isFeelingSheet, onDismiss: {}, content: {
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
    
    private let persistenceController = PersistenceController.shared.container.viewContext
    
    private var feelingDate: (date: String, time: String) {
        return self.feeling.date?.dateFormatte(date: "dd.MM.yy", time: "HH:mm") ?? (date: "String", time: "String")
    }
    
    var body: some View {
        VStack(spacing: 5){
            ZStack{
                Image("chart_" + (feeling.name ?? "feeling_1") )
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: screenSize.width / 8, height: screenSize.width / 8 )
            }
            
            VStack{
                Text("\(feelingDate.time)")
                    .font(.caption2)
                    .foregroundColor(.white)
            }
        }
        .padding(5)
        .onTapGesture {
            confirm = true
        }
        .confirmationDialog("Lösche Eintrag vom \(feelingDate.date) ", isPresented: $confirm) {
           
            Button("Eintrag löschen?", role: .destructive) {
                withAnimation{
                    persistenceController.delete(feeling)
                }
                
                do {
                    try persistenceController.save()
                } catch {
                    print("Eintrag vom \(feelingDate.date) \(feelingDate.time) gelöscht! ")
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
                    .foregroundColor(.yellow)
                
                Spacer()
                
                Image(systemName: "ellipsis")
                    .foregroundColor(AppConfig.shared.fontColor)
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
            .confirmationDialog("Alle Einträge vom \(current.date)", isPresented: $confirm) {
                Button("Alle Einträge Löschen", role: .destructive) {
                    for feel in sortedFeelings {
                        let d = feel.date?.dateFormatte(date: "dd.MM.yy", time: "HH:mm")
                        
                        withAnimation{
                            viewContext.delete(feel)
                        }
                        
                        do {
                            try viewContext.save()
                        } catch {
                            print("Eintrag vom \(String(describing: d?.date)) \(String(describing: d?.time)) gelöscht! ")
                        }
                    }
                } // FIXME: Add Share
                // Button("Teilen", role: .destructive) {} // FIXME: Add Share
                // Button("Bearbeiten", role: .destructive) {} // FIXME: Add Edit
            }
            
        }
        .padding(.vertical)
        .background(.ultraThinMaterial.opacity(0.5))
        .cornerRadius(20)
        .id(cal.isSameDay(d1: date, d2: cal.currentDate) ? dateID : noneID)
        .modifier(Shake(animatableData: CGFloat(cal.isSameDay(d1: date, d2: cal.currentDate) ? attempts : 0 )))
        
    }
}

