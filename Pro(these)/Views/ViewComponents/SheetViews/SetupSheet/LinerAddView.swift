//
//  ProthesisAddView.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 31.07.23.
//

import SwiftUI

struct LinerAddView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.managedObjectContext) var viewContext
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @Binding var nextButton: Bool
    
    @State private var index: Int = 0

    @FetchRequest var allProthesis: FetchedResults<Prothese>
    
    @FetchRequest var allLiners: FetchedResults<Liner>
    
    @State var newLiner: newLiner? = nil

    init(nextButton: Binding<Bool>) {
        self._nextButton = nextButton
        
        _allProthesis = FetchRequest<Prothese>(
            sortDescriptors: []
        )
        
        _allLiners = FetchRequest<Liner>(
            sortDescriptors: []
        )
    }
    
    @State var type = ""
    
    @State var brand = ""
    
    @State var model = ""
    
    @State var LastLinerDate : Date = Date()
    
    @State var prothese: Prothese? = nil
    
    @State var interval = 6
    
    var body: some View {
        VStack(spacing: 20) {
            
            if newLiner == nil {
                Text(LocalizedStringKey("Your Prosthesis-Liners?"))
                    .font(.title.bold())
                    .foregroundColor(currentTheme.text)
            }
            
            Spacer()
            
            // MARK: - Show All registered prostheses
            showAllRegisteredNewLiner(newLiner == nil)
          
            Spacer()
            
            // MARK: - Add Button
            addLinerButton(newLiner == nil)
            
            // MARK: - Add Button
            AddProsthesisLinerSteps((newLiner != nil))
            
            Spacer()
           
        }
    }

    @ViewBuilder
    func addLinerButton(_ bool: Bool) -> some View {
        if bool {
            Button(action: {
                withAnimation(.easeOut) {
                    newLiner = Pro_these_.newLiner(name: "", model: "", brand: "", lastDate: Date(), interval: 0, prothese: nil)
                    nextButton = false
                }
            }, label: {
                Label(allLiners.isEmpty ? LocalizedStringKey("Add your first Prosthesis liner") : LocalizedStringKey("Add another Prosthesis liner"), systemImage: "plus")
                    .padding()
                    .foregroundColor(currentTheme.primary)
            })
            .background(currentTheme.hightlightColor)
            .cornerRadius(15)
        }
    }
    
    @ViewBuilder
    func showAllRegisteredNewLiner(_ bool: Bool) -> some View {
        if bool {
            if !allLiners.isEmpty {
                ForEach(allLiners) { liner in
                    HStack(alignment: .top) {
                        VStack {
                            HStack(spacing: 6) {
                                Text("\(liner.brand ?? "Unknown Liner") \(liner.model ?? "")")
                                
                                Spacer()
                            }
                          
                            
                            HStack(spacing: 6) {
                                ForEach(liner.prothese?.allObjects as? [Prothese] ?? []) { prothese in
                                    HStack {
                                        Text("-")
                                            .font(.caption2.bold())
                                            .foregroundColor(currentTheme.textGray)
                                        
                                        Text(prothese.prosthesisKind)
                                            .font(.caption2.bold())
                                            .foregroundColor(currentTheme.textGray)
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                        
                        Spacer()
   
                        VStack {
                            Button(action: {
                                
                                viewContext.delete(liner)
                                
                                do {
                                    liner.removeLinerNotification()
                                    try viewContext.save()
                                } catch {
                                    // handle the Core Data error
                                }
                            }, label: {
                                Image(systemName: "trash")
                                    .foregroundColor(currentTheme.text)
                                    .padding()
                            })
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func AddProsthesisLinerSteps(_ bool: Bool) -> some View {
        if bool {
            TabView(selection: $index) {
                AddProstesisLinerType()
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
    
    @ViewBuilder
    func AddProstesisLinerType() -> some View {
        VStack(spacing: 20) {
           
            // MARK: - Choose PROTHESE TYP (BELOW/ABOVE)
            if type == "" {
                    Text("What purpose would you like to add?")
                        .font(.title.bold())
                        .foregroundColor(currentTheme.text)

                    Spacer()
                
                VStack(spacing: 20) {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                type = "oneToOne"
                                newLiner = Pro_these_.newLiner(name: "", model: "", brand: "", lastDate: Date(), interval: 0, prothese: nil)
                            }
                        }, label: {
                            HStack {
                                Spacer()
                                
                                Text("One to One").padding()
                                
                                Spacer()
                            }
                            .font(.body.bold())
                            .foregroundColor(currentTheme.primary)
                            .background(currentTheme.hightlightColor.gradient)
                            .cornerRadius(15)
                        })
                        
                        Button(action: {
                            withAnimation(.easeInOut) {
                                type = "oneToMany"
                                newLiner = Pro_these_.newLiner(name: "", model: "", brand: "", lastDate: Date(), interval: 0, prothese: nil)
                            }
                        }, label: {
                            HStack {
                                Spacer()
                                
                                Text("One to Many").padding()
                                
                                Spacer()
                            }
                            .font(.body.bold())
                            .foregroundColor(currentTheme.primary)
                            .background(currentTheme.hightlightColor.gradient)
                            .cornerRadius(15)
                        })
                    }
                }
  
            
            // MARK: - Choose PROTHESE KIND (SPORT/EVERYDAY/WATERPROOF)
            if type == "oneToOne" && prothese == nil {
                    Text("What kind of prosthesis would you like to add?")
                        .font(.title.bold())
                        .foregroundColor(currentTheme.text)

                    Spacer()
                    
                    VStack(spacing: 20) {
                        ForEach(allProthesis, id: \.hashValue) { prothese in
                            Button {
                                if (newLiner != nil) {
                                    self.prothese = prothese
                                }
                            } label: {
                                HStack {
                                    Spacer()
                                    
                                    Text(prothese.prosthesisKind).padding()
                                    
                                    Spacer()
                                }
                                .font(.body.bold())
                                .foregroundColor(currentTheme.primary)
                                .background(currentTheme.hightlightColor.gradient)
                                .cornerRadius(15)
                            }
                        }
                    }
            }
            
            
            // MARK: - Choose PROTHESE SUMMERY
            if type == "oneToMany" || type == "oneToOne" && prothese != nil {
                if let liner = newLiner {
                    VStack(spacing: 30) {
                        
                        VStack {
                            Text("What's the name of the manufacturer?")
                                .font(.headline.bold())
                                .foregroundColor(currentTheme.text)

                            TextField(brand == "" ? LocalizedStringKey("Enter the Brand Name").localizedstring() : brand, text: $brand)
                                .multilineTextAlignment(.center)
                                .font(.title3.bold())
                        }
                        
                        VStack {
                            Text("What is the name of the liner model?")
                                .font(.headline.bold())
                                .foregroundColor(currentTheme.text)
                            
                            TextField(model == "" ? LocalizedStringKey("Enter the Product Name").localizedstring() : model, text: $model)
                                .multilineTextAlignment(.center)
                                .font(.title3.bold())
                        }
                        
                        DatePicker(LocalizedStringKey("Get last liner?:"), selection: $LastLinerDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(currentTheme.text)
                            .cornerRadius(10)
                        
                        HStack {
                            HStack {
                                Text("Date Interval:")
                                    .font(.body.bold())
                            }
                            
                            Picker(LocalizedStringKey("Date Interval:"), selection: $interval, content: {
                                ForEach([6,12], id: \.self) { int in
                                    Text(LocalizedStringKey("\(int) Months")).tag(int as Int)
                                }
                            })
                            .pickerStyle(.segmented)
                        }
                        
                        HStack(spacing: 40) {
                            Button(action: {
                                withAnimation(.easeInOut) {
                                    newLiner = nil
                                    brand = ""
                                    model = ""
                                    type = ""
                                    prothese = nil
                                    nextButton = true
                                }
                            }, label: {
                                Text("Cancel")
                            })
                            .padding()
                            .font(.body.bold())
                            .foregroundColor(currentTheme.primary)
                            .background(currentTheme.hightlightColor)
                            .cornerRadius(15)
                            
                            saveLiner(liner)
                        }
                        
                        Spacer()
                    }
                }
            }
           
            
            Spacer()
        }
    }

    @ViewBuilder
    func saveLiner(_ input: newLiner) -> some View {
        Button(action: {
            let new = Liner(context: viewContext)
            new.name = brand + " " + model
            new.linerID = UUID().uuidString
            new.brand = brand
            new.model = model
            new.date = LastLinerDate
            new.interval = Int16(interval)
            
            if let p = prothese {
                new.addToProthese(p)
            }
            
            do {
                try? viewContext.save()
                
                newLiner = nil
                brand = ""
                model = ""
                type = ""
                prothese = nil
                LastLinerDate = Date()
                
                new.registerNewLinerNotification()
                
                withAnimation(.easeInOut) {
                    nextButton = true
                }
            }
        }, label: {
            Text("Add")
                .foregroundColor(currentTheme.primary)
        })
        .padding()
        .background(currentTheme.hightlightColor)
        .cornerRadius(15)
    }
    
    @ViewBuilder
    func listAllLiners() -> some View {
        ForEach(allLiners) { liner in
            HStack(spacing: 10) {
                Text(LocalizedStringKey(liner.name ?? "Unknown Liner"))
                    .font(.footnote)
                
                Spacer()
                
                Text(LocalizedStringKey(liner.brand ?? "Unknown Liner Brand"))
                    .font(.footnote)
                
                Spacer()
                
                Text(LocalizedStringKey(liner.model ?? "Unknown Liner Model"))
                    .font(.footnote)
                
                Spacer()
                
                Text(liner.date?.dateFormatte(date: "dd.MM.yyyy", time: "").date ?? "")
                    .font(.footnote)
                
                Spacer()
                
                Button(action: {
                    viewContext.delete(liner)
                    
                    do {
                        liner.removeLinerNotification()
                        
                        try viewContext.save()
                        
                        
                    } catch {
                        print(error)
                    }
                }, label: {
                    Image(systemName: "trash")
                        .padding()
                })
            }
            .foregroundColor(currentTheme.text)
        }
    }
}

class newLiner {
    var name: String
    var model: String
    var brand: String
    var lastDate: Date
    var interval: Int
    
    var prothese: Prothese?
    
    init(name: String, model: String, brand: String, lastDate: Date, interval: Int, prothese: Prothese?) {
        self.name = name
        self.model = model
        self.brand = brand
        self.lastDate = lastDate
        self.interval = interval
        self.prothese = prothese
   }
}
