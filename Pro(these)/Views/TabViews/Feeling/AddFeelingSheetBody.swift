//
//  AddFeelingSheetBody.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 24.05.23.
//

import SwiftUI
import WidgetKit



struct AddFeelingSheetBody: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var cal: MoodCalendar
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var ads: AdsViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    @FetchRequest var allProthesis: FetchedResults<Prothese>
    
    @FetchRequest var allLiners: FetchedResults<Liner>
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    var dynamicGrid: Int {
        if allProthesis.count <= 3 {
            return allProthesis.count
        } else {
            return 3
        }
    }

    init() {
        _allProthesis = FetchRequest<Prothese>(
            sortDescriptors: []
        )
        
        _allLiners = FetchRequest<Liner>(
            sortDescriptors: []
        )
    }
    
    var body: some View {
        GeometryReader { geo in
            
            if let feeling = cal.editFeeling {
                VStack {
                    // close
                    
                    SheetHeader(title: LocalizedStringKey("change your mood"), action: {
                        cal.isFeelingSheet.toggle()
                        
                        dismiss()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            cal.showDatePicker = false
                        })
                    })
                    
                    Spacer()
                    
                    VStack(spacing: 8){
                        Text("Hey! How are you\nfeeling today?")
                            .font(.system(size: 30, weight: .regular))
                            .multilineTextAlignment(.center)
                    }
                    
                    /*
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
                                .stroke(currentTheme.textGray)
                        )
                    }
                    .background(
                        DatePicker("", selection: $cal.addFeelingDate, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .frame(width: 200, height: 100)
                            .clipped()
                            .background(currentTheme.textGray.cornerRadius(10))
                            .opacity(cal.showDatePicker ? 1 : 0 )
                            .offset(x: 50, y: 90)
                    ).onChange(of: cal.addFeelingDate) { newValue in
                       withAnimation {
                           cal.showDatePicker.toggle()
                       }
                    }// DatePicker
                    */
                    
                    Spacer()
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: dynamicGrid), spacing: 10) {
                        ForEach(allProthesis, id: \.hashValue) { prothese in
                            Button {
                                cal.prothese = prothese
                            } label: {
                                VStack {
                                    Image(prothese.prosthesisIcon)
                                        .font(.title)
                                        .foregroundStyle(currentTheme.hightlightColor, currentTheme.textGray)
                                    
                                    Text(prothese.prosthesisKindLineBreak).padding()
                                        .font(.caption.bold())
                                        .foregroundColor(currentTheme.text)
                                }
                                .padding()
                                .background(cal.prothese == prothese ? Material.ultraThinMaterial.opacity(1) : Material.ultraThinMaterial.opacity(0.4))
                                
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(cal.prothese == prothese ? .white : .clear, lineWidth: 2)
                                )
                                .cornerRadius(15)
                            }
                        }
                    }
                        .padding(.bottom, 20)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 10) {
                        ForEach(cal.feelingItems , id: \.name) { feeling in
                            Button {
                                cal.selectedFeeling = "feeling_\(feeling.image)"
                                
                                let newFeeling = Feeling(context: persistenceController.container.viewContext)
                                newFeeling.date = cal.addFeelingDate
                                newFeeling.name = cal.selectedFeeling
                                
                                if let pro = cal.prothese {
                                    newFeeling.prothese = pro
                                    cal.prothese?.addToFeelings(newFeeling)
                                }

                                do {
                                    try? persistenceController.container.viewContext.save()
                                    cal.isFeelingSheet.toggle()
                                    WidgetCenter.shared.reloadAllTimelines()
                                    cal.selectedFeeling = ""
                                    cal.prothese = nil
                                }
                            } label: {
                                VStack {
                                    Image("feeling_\(feeling.image)")
                                        .font(.largeTitle)
                                        .scaleEffect(2)
                                        .foregroundColor(feeling.color)
                                }
                                .padding()
                                .background(cal.selectedFeeling == "feeling_\(feeling.image)" ? Material.ultraThinMaterial.opacity(1) : Material.ultraThinMaterial.opacity(0.4))
                                .cornerRadius(15)
                            }
                        }
                    }
                    
                    /*
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
                            .background(cal.selectedFeeling == "feeling_\(feeling.image)" ? currentTheme.text.opacity(0.2) : currentTheme.text.opacity(0))
                            .cornerRadius(20)
                            
                        }
                    }
                    .padding(.horizontal, 20)
                    */
                    
                    HStack {
                        Button("Cancel") {
                            cal.isFeelingSheet.toggle()
                            cal.selectedFeeling = ""
                            cal.addFeelingDate = Calendar.current.date(byAdding: .year, value: -5, to: Date())!
                            cal.editFeeling = nil
                            cal.prothese = nil
                        }
                        
                        Spacer()
                        
                        Button("Edit") {
                            let newFeeling = feeling
                            newFeeling.date = cal.addFeelingDate
                            newFeeling.name = cal.selectedFeeling
                            
                            if let pro = cal.prothese {
                                newFeeling.prothese = pro
                                cal.prothese?.addToFeelings(newFeeling)
                            }
                            
                            do {
                                try? persistenceController.container.viewContext.save()
                                cal.isFeelingSheet.toggle()
                                WidgetCenter.shared.reloadAllTimelines()
                                cal.selectedFeeling = ""
                                cal.prothese = nil
                                cal.editFeeling = nil
                                
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding()
                .presentationDragIndicator(.visible)
                .foregroundColor(currentTheme.text)
                .onAppear{
                    cal.selectedFeeling = feeling.name ?? ""
                    cal.addFeelingDate = feeling.date ?? Date()
                    cal.prothese = feeling.prothese 
                    DispatchQueue.main.async {
                        cal.showDatePicker = false
                    }
                }
                
            } else {
                VStack {
                    // close
                    
                    SheetHeader(title: LocalizedStringKey("How are you doing?"), action: {
                        cal.isFeelingSheet.toggle()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            cal.showDatePicker = false
                        })
                    })
                    
                    Spacer()
                    VStack(spacing: 8){
                        Text("Hey! How are you\nfeeling today?")
                            .font(.system(size: 30, weight: .regular))
                            .multilineTextAlignment(.center)
                    }
                    
                    /*
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
                                .stroke(currentTheme.textGray)
                        )
                    }
                    .background(
                        DatePicker("", selection: $cal.addFeelingDate, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .frame(width: 200, height: 100)
                            .clipped()
                            .background(currentTheme.textGray.cornerRadius(10))
                            .opacity(cal.showDatePicker ? 1 : 0 )
                            .offset(x: 50, y: 90)
                    ).onChange(of: cal.addFeelingDate) { newValue in
                       withAnimation {
                           cal.showDatePicker.toggle()
                       }
                    }// DatePicker
                     */
                    
                    Spacer()

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: dynamicGrid), spacing: 10) {
                        ForEach(allProthesis, id: \.hashValue) { prothese in
                            Button {
                                cal.prothese = prothese
                            } label: {
                                VStack {
                                    Image(prothese.prosthesisIcon)
                                        .font(.title)
                                        .foregroundStyle(currentTheme.hightlightColor, currentTheme.textGray)
                                    
                                    Text(prothese.prosthesisKindLineBreak).padding()
                                        .font(.caption2.bold())
                                        .foregroundColor(currentTheme.text)
                                }
                                .padding(10)
                                .background(cal.prothese == prothese ? Material.ultraThinMaterial.opacity(1) : Material.ultraThinMaterial.opacity(0.4))
                                .cornerRadius(15)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 10) {
                        ForEach(cal.feelingItems , id: \.name) { feeling in
                            Button {
                                cal.selectedFeeling = "feeling_\(feeling.image)"
                                
                                let newFeeling = Feeling(context: persistenceController.container.viewContext)
                                newFeeling.date = cal.addFeelingDate
                                newFeeling.name = cal.selectedFeeling
                                
                                if let pro = cal.prothese {
                                    newFeeling.prothese = pro
                                    cal.prothese?.addToFeelings(newFeeling)
                                }

                                do {
                                    try? persistenceController.container.viewContext.save()
                                    cal.isFeelingSheet.toggle()
                                    WidgetCenter.shared.reloadAllTimelines()
                                    cal.selectedFeeling = ""
                                    cal.prothese = nil
                                }
                            } label: {
                                VStack {
                                    Image("feeling_\(feeling.image)")
                                        .font(.largeTitle)
                                        .scaleEffect(2)
                                        .foregroundColor(feeling.color)
                                }
                                .padding()
                                .background(cal.selectedFeeling == "feeling_\(feeling.image)" ? Material.ultraThinMaterial.opacity(1) : Material.ultraThinMaterial.opacity(0.4))
                                .cornerRadius(15)
                            }
                        }
                    }

                    /*
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
                                        
                                        if var pro = cal.prothese {
                                            newFeeling.prothese = pro
                                            cal.prothese?.addToFeelings(newFeeling)
                                        }

                                        do {
                                            try? persistenceController.container.viewContext.save()
                                            cal.isFeelingSheet.toggle()
                                            WidgetCenter.shared.reloadAllTimelines()
                                            cal.selectedFeeling = ""
                                            cal.prothese = nil
                                        }
                                    }
                            }
                            .padding()
                            .frame(width: geo.size.width / 7.5, height: geo.size.width / 7.5 )
                            .background(cal.selectedFeeling == "feeling_\(feeling.image)" ? currentTheme.text.opacity(0.2) : currentTheme.text.opacity(0))
                            .cornerRadius(20)
                            
                        }
                    }
                    .padding(.horizontal, 20)
                    */
                    
                    Spacer()
                }
                .padding()
                .presentationDragIndicator(.visible)
                .foregroundColor(currentTheme.text)
            }
            
            
        }
    }
}


struct AddFeelingSheetBody_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Theme.blue.gradientBackground(nil).ignoresSafeArea()
            
            AddFeelingSheetBody()
                .environmentObject(MoodCalendar())
                .colorScheme(.dark)
        }
    }
}
