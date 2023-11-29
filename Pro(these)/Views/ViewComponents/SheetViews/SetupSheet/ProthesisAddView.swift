//
//  ProthesisAddView.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 31.07.23.
//

import SwiftUI

struct ProthesisAddView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.managedObjectContext) var viewContext
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @Binding var nextButton: Bool
    
    @State private var index: Int = 0

    @FetchRequest var allProthesis: FetchedResults<Prothese>
    
    @FetchRequest var allLiners: FetchedResults<Liner>
    
    @State var newProsthetic: newProthesis? = nil
    
    @State var LastProstheticMainTage: Date = Date()
    
    @State var maintageSelection: Int = 12

    @State private var RowItemHeight = CGFloat.zero
    
    init(nextButton: Binding<Bool>) {
        self._nextButton = nextButton
        
        _allProthesis = FetchRequest<Prothese>(
            sortDescriptors: []
        )
        
        _allLiners = FetchRequest<Liner>(
            sortDescriptors: []
        )
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
            }
            .onAppear {
                //print("newProsthetic: \(newProsthetic)")
            }
            
            if newProsthetic == nil {
                Text(LocalizedStringKey("Your Prosthesis?"))
                    .font(.title.bold())
                    .foregroundColor(currentTheme.text)
            }
            
            
            // MARK: - Show All registered prostheses
            showAllRegisteredProsthesis(newProsthetic == nil)
          
            Spacer()
            
            // MARK: - Add Button
            addProstheticsButton(newProsthetic == nil)
            
            // MARK: - Add Button
            AddProsthesisSteps(newProsthetic != nil)
            
            Spacer()
           
        }
    }
    
    @ViewBuilder
    func addProstheticsButton(_ bool: Bool) -> some View {
        if bool {
            Button(action: {
                withAnimation(.easeOut) {
                    newProsthetic = newProthesis(type: .none)
                    nextButton = false
                }
            }, label: {
                Label(allProthesis.isEmpty ? LocalizedStringKey("Add your first Prosthetics") : LocalizedStringKey("Add another Prosthetics"), systemImage: "plus")
                    .padding()
                    .foregroundColor(currentTheme.primary)
            })
            .background(currentTheme.hightlightColor)
            .cornerRadius(15)
        }
    }
    
    @ViewBuilder
    func addLinerButton(_ bool: Bool) -> some View {
        if bool {
            Button(action: {
                withAnimation(.easeOut) {
                    newProsthetic = newProthesis(type: .none)
                    nextButton = false
                }
            }, label: {
                Label(allProthesis.isEmpty ? LocalizedStringKey("Add your first Prosthesis liner") : LocalizedStringKey("Add another Prosthesis liner"), systemImage: "plus")
                    .padding()
                    .foregroundColor(currentTheme.primary)
            })
            .background(currentTheme.hightlightColor)
            .cornerRadius(15)
        }
    }
    
    @ViewBuilder
    func showAllRegisteredProsthesis(_ bool: Bool) -> some View {
        if bool {
            if !allProthesis.isEmpty {
                ForEach(allProthesis) { prothese in
                    HStack {
                        Text(LocalizedStringKey(prothese.name ?? "Unknown Prothesis"))
                        
                        Spacer()
                        
                        Text(LocalizedStringKey(prothese.type ?? "Unknown Prothesis type"))
                        
                        Button(action: {
                            prothese.removeProtheseNotification()
                            viewContext.delete(prothese)
                            
                            do {
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
    
    @ViewBuilder
    func AddProsthesisSteps(_ bool: Bool) -> some View {
        if bool {
            TabView(selection: $index) {
                
                AddProstesisType()
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
    
    @ViewBuilder
    func AddProstesisType() -> some View {
        VStack(spacing: 20) {
           
            // MARK: - Choose PROTHESE TYP (BELOW/ABOVE)
            if newProsthetic?.type == prothesis.type.none {
                Text("What type of prosthesis would you like to add?")
                    .font(.title.bold())
                    .foregroundColor(currentTheme.text)

                Spacer()
            
                HStack(spacing: 50) {
                    ForEach(prothesis.allTypes, id: \.hashValue) { type in
                        
                        if type != .none {
                            
                            Button(action: {
                                withAnimation(.easeInOut) {
                                   newProsthetic = newProthesis(type: type, kind: .none)
                                }
                            }, label: {
                                VStack(spacing: 40) {
                                    if type == .aboveKnee {
                                        Image(prothesis.type.aboveKnee.icon)
                                            .font(.largeTitle)
                                            .scaleEffect(2)
                                            .foregroundStyle(currentTheme.hightlightColor, currentTheme.textGray)
                                    }
                                    
                                    if type == .belowKnee {
                                        Image(prothesis.type.belowKnee.icon)
                                            .font(.largeTitle)
                                            .scaleEffect(2)
                                            .foregroundStyle(currentTheme.hightlightColor, currentTheme.textGray)
                                    }
                                    
                                    
                                    Text(type.rawValue)
                                        .font(.body.bold())
                                        .foregroundColor(currentTheme.text)
                                        //.underline(newProsthetic.type == type, color: currentTheme.hightlightColor)
                                }
                               
                            })
                        }
                    }
                }
            }
               
            
            // MARK: - Choose PROTHESE KIND (SPORT/EVERYDAY/WATERPROOF)
            if newProsthetic?.type != prothesis.type.none && newProsthetic?.kind == prothesis.kind.none {
                    Text("What kind of prosthesis would you like to add?")
                        .font(.title.bold())
                        .foregroundColor(currentTheme.text)

                    Spacer()
                
                    VStack(spacing: 20) {
                        ForEach(prothesis.allKinds, id: \.hashValue) { kind in
                            Button {
                                withAnimation(.easeInOut) {
                                    if let type = newProsthetic?.type {
                                        newProsthetic =  newProthesis(type: type, kind: kind)
                                    }
                                }
                            } label: {
                                HStack {
                                    Spacer()
                                    
                                    Text(kind.fullValue).padding()
                                    
                                    Spacer()
                                }
                                .font(.body.bold())
                                .foregroundColor(currentTheme.primary)
                                .background(currentTheme.hightlightColor.gradient)
                                .cornerRadius(15)
                            }

                        }
                    }
                    
                    /*
                    LazyHGrid(rows: Array(repeating: GridItem(.adaptive(minimum: 100, maximum: 160)), count: 2), spacing: 15, content: {
                            ForEach(prothesis.allKinds, id: \.hashValue) { kind in
                                Button(action: {
                                    withAnimation(.easeInOut) {
                                        if let pro = newProsthetic {
                                            newProsthetic =  newProthesis(type: pro.type, kind: kind)
                                        }
                                    }
                                }, label: {
                                    VStack {
                                        Spacer()
                                        
                                        Text(LocalizedStringKey(kind.rawValueWithBreak))
                                            .font(.body.bold())
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(currentTheme.text)
                                            .padding()
                                    }
                                    
                                })
                                .frame(maxWidth: .infinity, maxHeight: 150)
                                .background(.ultraThinMaterial.opacity(0.2))
                                .cornerRadius(15)
                                .overlay(
                                   RoundedRectangle(cornerRadius: 20)
                                       .stroke(Color.white, lineWidth: 1)
                                )
                            }
                        })
                        .frame(maxWidth: .infinity)
                     */
            }
            
             
            // MARK: - Choose PROTHESE SUMMERY
            if let pro = newProsthetic {
                if pro.type != prothesis.type.none && pro.kind != prothesis.kind.none {
                    
                    if newProsthetic?.kind != prothesis.kind.none && newProsthetic?.type == prothesis.type.belowKnee {
                        VStack(spacing: 40) {
                            HStack {
                                Spacer()
                                
                                if newProsthetic?.type == prothesis.type.belowKnee {
                                    Image(prothesis.type.belowKnee.icon)
                                        .font(.largeTitle)
                                        .scaleEffect(2)
                                        .foregroundStyle(currentTheme.hightlightColor, currentTheme.textGray)
                                }
                                
                                if newProsthetic?.type == prothesis.type.aboveKnee {
                                    Image(prothesis.type.aboveKnee.icon)
                                        .font(.largeTitle)
                                        .scaleEffect(2)
                                        .foregroundStyle(currentTheme.hightlightColor, currentTheme.textGray)
                                }

                                Spacer()
                            }
                            .padding(.top, 100)
                            
                            VStack(spacing: 20) {
                                HStack {
                                    Text("Your Prosthetic:")
                                        .font(.headline.bold())
                                    Spacer()
                                }
                                .padding(.horizontal)
                                
                                HStack {
                                    Text("Kind: ")
                                    Spacer()
                                    Text(newProsthetic?.kind.rawValue ?? "")
                                }
                                .padding(.horizontal)
                                
                                HStack {
                                    Text("Type: ")
                                    Spacer()
                                    Text(newProsthetic?.type.rawValue ?? "")
                                }
                                .padding(.horizontal)
                            }
                            
                            HStack(spacing: 40) {
                                Button(action: {
                                    withAnimation(.easeInOut) {
                                        newProsthetic = nil
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
                                
                                if let new = newProsthetic {
                                    saveBelow(new)
                                }
                                
                            }
                           
                            Spacer()
                        }
                    } else {
                        VStack(spacing: 40) {

                            HStack {
                                Spacer()
                                
                                if newProsthetic?.type == prothesis.type.belowKnee {
                                    Image(prothesis.type.belowKnee.icon)
                                        .font(.largeTitle)
                                        .scaleEffect(2)
                                        .foregroundStyle(currentTheme.hightlightColor, currentTheme.textGray)
                                }
                                
                                if newProsthetic?.type == prothesis.type.aboveKnee {
                                    Image(prothesis.type.aboveKnee.icon)
                                        .font(.largeTitle)
                                        .scaleEffect(2)
                                        .foregroundStyle(currentTheme.hightlightColor, currentTheme.textGray)
                                }

                                Spacer()
                            }
                            .padding(.top, 100)
                            
                            DatePicker(LocalizedStringKey("Last Maintage:"), selection: $LastProstheticMainTage, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(currentTheme.text)
                                .cornerRadius(10)
                            
                            HStack {
                                HStack {
                                    Text("Maintage Interval:")
                                        .font(.body.bold())
                                }
                                
                                Picker(LocalizedStringKey("Maintage Interval:"), selection: $maintageSelection, content: {
                                    ForEach([6,12], id: \.self) { int in
                                        Text(LocalizedStringKey("\(int) Months")).tag(int as Int)
                                    }
                                })
                                .pickerStyle(.segmented)
                            }
                            
                            HStack(spacing: 40) {
                                Button(action: {
                                    withAnimation(.easeInOut) {
                                        newProsthetic = nil
                                        nextButton = true
                                    }
                                }, label: {
                                    Text("Cancel")
                                        .foregroundColor(currentTheme.primary)
                                })
                                .padding()
                                .font(.body.bold())
                                .foregroundColor(currentTheme.primary)
                                .background(currentTheme.hightlightColor)
                                .cornerRadius(15)
                                
                                if let new = newProsthetic {
                                    saveAbove(new)
                                }
                                
                            }
                            
                            Spacer()
                            
                        }
                    }
                    
                    
                    /*
                    // if below
                    if pro.kind != prothesis.kind.none && pro.type == prothesis.type.belowKnee {
                        VStack(spacing: 40) {
                            
                            Image("prostheticBelow")
                                .resizable()
                                .frame(width: 150, height: 150)
                            
                            VStack(spacing: 20) {
                                HStack {
                                    Text("Your Prosthetic:")
                                        .font(.headline.bold())
                                    Spacer()
                                }
                                .padding(.horizontal)
                                
                                HStack {
                                    Text("Kind: ")
                                    Spacer()
                                    Text(pro.kind.rawValue)
                                }
                                .padding(.horizontal)
                                
                                HStack {
                                    Text("Type: ")
                                    Spacer()
                                    Text(pro.type.rawValue)
                                }
                                .padding(.horizontal)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 40) {
                                Button(action: {
                                    withAnimation(.easeInOut) {
                                        newProsthetic = nil
                                        nextButton = true
                                    }
                                }, label: {
                                    Text("Cancel")
                                        .foregroundColor(currentTheme.primary)
                                })
                                .padding()
                                .background(currentTheme.hightlightColor)
                                .cornerRadius(15)
                                
                                saveBelow(pro)
                            }
                           
                        }
                    } else {
                        VStack(spacing: 20) {

                            Image("prostheticAbove")
                                .resizable()
                                .frame(width: 150, height: 150)
                            
                            DatePicker(LocalizedStringKey("Last Maintage:"), selection: $LastProstheticMainTage, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(currentTheme.text)
                                .cornerRadius(10)
                            
                            HStack {
                                HStack {
                                    Text("Maintage Interval:")
                                        .font(.body.bold())
                                }
                                
                                Picker(LocalizedStringKey("Maintage Interval:"), selection: $maintageSelection, content: {
                                    ForEach([6,12], id: \.self) { int in
                                        Text(LocalizedStringKey("\(int) Months")).tag(int as Int)
                                    }
                                })
                                .pickerStyle(.segmented)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 40) {
                                Button(action: {
                                    withAnimation(.easeInOut) {
                                        newProsthetic = nil
                                        nextButton = true
                                    }
                                }, label: {
                                    Text("Cancel")
                                        .foregroundColor(currentTheme.primary)
                                })
                                .padding()
                                .background(currentTheme.hightlightColor)
                                .cornerRadius(15)
                                
                                saveAbove(pro)
                            }
                        }
                    } */
                  
                    
                }
            }

            
            Spacer()
        }
    }
    
    @ViewBuilder
    func saveBelow(_ input: newProthesis) -> some View {
        Button(action: {
            let new = Prothese(context: viewContext)
            new.name = input.kind.rawValue.stringKey
            new.protheseID = UUID().uuidString
            new.kind = input.kind.rawValue.stringKey
            new.type = input.type.rawValue.stringKey
            
            do {
                try? viewContext.save()
                newProsthetic = nil
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
    func saveAbove(_ input: newProthesis) -> some View {
        Button(action: {
            
            let new = Prothese(context: viewContext)
            new.name = input.kind.rawValue.stringKey
            new.protheseID = UUID().uuidString
            new.kind = input.kind.rawValue.stringKey
            new.type = input.type.rawValue.stringKey
            new.maintage = LastProstheticMainTage
            new.maintageInterval = Int16(maintageSelection )
            
            do {
                try? viewContext.save()
                newProsthetic = nil
                withAnimation(.easeInOut) {
                    nextButton = true
                }
                
                if new.hasMaintage {
                    new.registerNewProtheseNotification()
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
                    liner.removeLinerNotification()
                    
                    viewContext.delete(liner)
                    
                    do {
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

struct ProthesisAddView_Previews: PreviewProvider {
    static var currentTheme: Theme {
        return ThemeManager().currentTheme()
    }
    
    static var previews: some View {
        ZStack {
            currentTheme.backgroundColor.ignoresSafeArea()
            
            CircleAnimationInBackground(delay: 1, duration: 2)
            
            ProthesisAddView(nextButton: .constant(true))
        }
      
    }
}

/// New  Prothesis
/// ```newProthesis
/// let aboveKnee = newProthesis(type: <#T##Prothese#>, lastMaintage: <#T##Date#>, maintageInterval: <#T##Int#>)
/// let belowKnee = newProthesis(type: <#T##Prothese#>,)
/// ```
class newProthesis {
    var type: prothesis.type
    var kind: prothesis.kind
    var LastMaintage: Date?
    var maintageInterval: Int?
    
    /// New belowKnee Prothesis
    init(type: prothesis.type = .none, kind: prothesis.kind = .none) {
           self.type = type
           self.kind = kind
       }
    
    /// New aboveKnee Prothesis
    init(type: prothesis.type = .none, kind: prothesis.kind = .none, lastMaintage: Date, maintageInterval : Int) {
        self.type = type
        self.kind = kind
        self.LastMaintage = lastMaintage
        self.maintageInterval = maintageInterval
   }

}
