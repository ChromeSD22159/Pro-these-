//
//  AddFeelingSheetBody.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 24.05.23.
//

import SwiftUI
import WidgetKit



struct AddFeelingSheetBody: View {
    @EnvironmentObject var cal: MoodCalendar
    @Environment(\.dismiss) private var dismiss
    
    let persistenceController = PersistenceController.shared
    
    var body: some View {
        GeometryReader { geo in
            
            if let feeling = cal.editFeeling {
                VStack {
                    // close
                    
                    SheetHeader("Ändere dein Stimmung", action: {
                        cal.isFeelingSheet.toggle()
                        
                        dismiss()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            cal.showDatePicker = false
                        })
                    })
                    
                    Spacer()
                    
                    VStack(spacing: 8){
                        Text("Hey! Wie fühlst")
                            .font(.system(size: 30, weight: .regular))
                        Text("du dich heute?")
                            .font(.system(size: 30, weight: .regular))
                    }
                    
                    // DatePicker
                    Button {
                        withAnimation {
                            cal.showDatePicker.toggle()
                        }
                    }  label: {
                        HStack(spacing: 20){
                            Image(systemName: "calendar.badge.plus")
                                .font(.title3)
                            Text(cal.addFeelingDate, style: .date)
                        }
                        .padding()
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray)
                        )
                    }
                    .background(
                        DatePicker("", selection: $cal.addFeelingDate, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .frame(width: 200, height: 100)
                            .clipped()
                            .background(Color.gray.cornerRadius(10))
                            .opacity(cal.showDatePicker ? 1 : 0 )
                            .offset(x: 50, y: 90)
                    ).onChange(of: cal.addFeelingDate) { newValue in
                       withAnimation {
                           cal.showDatePicker.toggle()
                       }
                   }// DatePicker

                    
                    Spacer()

                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 10) {
                        ForEach(cal.feelingItems , id: \.name) { feeling in
                            
                            ZStack{
                                Image("feeling_\(feeling.image)")
                                    .resizable()
                                    .frame(width: geo.size.width / 6.5, height: geo.size.width / 6.5 )
                                    .foregroundColor(feeling.color)
                                    .onTapGesture {
                                        cal.selectedFeeling = "feeling_\(feeling.image)"
                                    }
                            }
                            .padding()
                            .frame(width: geo.size.width / 7.5, height: geo.size.width / 7.5 )
                            .background(cal.selectedFeeling == "feeling_\(feeling.image)" ? .white.opacity(0.2) : .white.opacity(0))
                            .cornerRadius(20)
                            
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    
                    HStack {
                        Button("Abbrechen") {
                            cal.isFeelingSheet.toggle()
                            cal.selectedFeeling = ""
                            cal.addFeelingDate = Calendar.current.date(byAdding: .year, value: -5, to: Date())!
                            cal.editFeeling = nil
                        }
                        
                        Spacer()
                        
                        Button("Ändern") {
                            let newFeeling = feeling
                            newFeeling.date = cal.addFeelingDate
                            newFeeling.name = cal.selectedFeeling
                            
                            do {
                                try? persistenceController.container.viewContext.save()
                                cal.isFeelingSheet.toggle()
                                WidgetCenter.shared.reloadAllTimelines()
                                cal.selectedFeeling = ""
                                cal.editFeeling = nil
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .presentationDragIndicator(.visible)
                .foregroundColor(.white)
                .onAppear{
                    cal.selectedFeeling = feeling.name ?? ""
                    cal.addFeelingDate = feeling.date ?? Date()
                    DispatchQueue.main.async {
                        cal.showDatePicker = false
                    }
                }
                
            } else {
                VStack {
                    // close
                    
                    SheetHeader("Wie geht es dir?", action: {
                        cal.isFeelingSheet.toggle()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            cal.showDatePicker = false
                        })
                    })
                    
                    Spacer()
                    VStack(spacing: 8){
                        Text("Hey! Wie fühlst")
                            .font(.system(size: 30, weight: .regular))
                        Text("du dich heute?")
                            .font(.system(size: 30, weight: .regular))
                    }
                    
                    // DatePicker
                    Button {
                        withAnimation {
                            cal.showDatePicker.toggle()
                        }
                    }  label: {
                        HStack(spacing: 20){
                            Image(systemName: "calendar.badge.plus")
                                .font(.title3)
                            Text(cal.addFeelingDate, style: .date)
                        }
                        .padding()
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray)
                        )
                    }
                    .background(
                        DatePicker("", selection: $cal.addFeelingDate, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .frame(width: 200, height: 100)
                            .clipped()
                            .background(Color.gray.cornerRadius(10))
                            .opacity(cal.showDatePicker ? 1 : 0 )
                            .offset(x: 50, y: 90)
                    ).onChange(of: cal.addFeelingDate) { newValue in
                       withAnimation {
                           cal.showDatePicker.toggle()
                       }
                   }// DatePicker

                    
                    Spacer()

                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 10) {
                        ForEach(cal.feelingItems , id: \.name) { feeling in
                            
                            ZStack{
                                Image("feeling_\(feeling.image)")
                                    .resizable()
                                    .frame(width: geo.size.width / 6.5, height: geo.size.width / 6.5 )
                                    .foregroundColor(feeling.color)
                                    .onTapGesture {
                                        cal.selectedFeeling = "feeling_\(feeling.image)"
                                        
                                        let newFeeling = Feeling(context: persistenceController.container.viewContext)
                                        newFeeling.date = cal.addFeelingDate
                                        newFeeling.name = cal.selectedFeeling
                                        
                                        do {
                                            try? persistenceController.container.viewContext.save()
                                            cal.isFeelingSheet.toggle()
                                            WidgetCenter.shared.reloadAllTimelines()
                                            cal.selectedFeeling = ""
                                        }
                                        
                                    }
                            }
                            .padding()
                            .frame(width: geo.size.width / 7.5, height: geo.size.width / 7.5 )
                            .background(cal.selectedFeeling == "feeling_\(feeling.image)" ? .white.opacity(0.2) : .white.opacity(0))
                            .cornerRadius(20)
                            
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    
                    Spacer()
                }
                .padding()
                .presentationDragIndicator(.visible)
                .foregroundColor(.white)
            }
            
            
        }
    }
}


struct AddFeelingSheetBody_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppConfig.shared.background.ignoresSafeArea()
            
            AddFeelingSheetBody()
                .environmentObject(MoodCalendar())
                .colorScheme(.dark)
        }
    }
}
