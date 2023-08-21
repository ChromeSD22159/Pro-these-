//
//  LinerOverview.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 03.08.23.
//

import SwiftUI

struct LinerOverview: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @EnvironmentObject var appConfig: AppConfig
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @FetchRequest var allProthesis: FetchedResults<Prothese>
    
    @FetchRequest var allLiners: FetchedResults<Liner>
    
    init() {
        _allProthesis = FetchRequest<Prothese>(
            sortDescriptors: []
        )
        
        _allLiners = FetchRequest<Liner>(
            sortDescriptors: []
        )
    }
    
    @State var showLinerDatePicker = false
    @State var newLinerDate = Date()
    @State var selectedLiner: Liner?
    
    @State var showProtheseDatePicker = false
    @State var newMaintageDate = Date()
    @State var newMaintageInterval = 6
    @State var showMaintageIntervalPicker = false
    @State var selectedProthese: Prothese?

    
    // newLiner
    @State var addLinerSheet = false
    @State var editLinerSheet = false
    @State var newLiner: newLiner? = nil
    @State var protheseLiner: Prothese? = nil
    @State var linerType = ""
    @State var linerBrand = ""
    @State var linerModel = ""
    @State var LastLinerDate : Date = Date()
    @State var linerInterval = 6
    
    // newProthesis
    @State var addProsthesisSheet = false
    @State var editProsthesisSheet = false
    @State var newProsthetic: newProthesis = newProthesis(kind: .none)
    @State var maintageSelection: Int = 12
    @State var LastProstheticMainTage: Date = Date()
    
    var body: some View {
        ZStack {
            Background()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // MARK: - Page Header
                    Header("Manage Prosthesis & Liners")
                        .padding(.bottom)
                    
                    
                    // MARK: - List Liners
                    card(
                        header: "Prosthesis Liner",
                        subheader: "Manage all your Prosthesis-Liners",
                        content: {
                            VStack(spacing: 6) {
                                ForEach(allLiners) { liner in
                                    
                                    LinerItem(
                                        liner: liner,
                                        showDatePicker: $showLinerDatePicker,
                                        newLinerDate: $newLinerDate,
                                        selectedLiner: $selectedLiner,
                                        addLinerSheet: $addLinerSheet,
                                        editLinerSheet: $editLinerSheet
                                    )
                                    
                                }
                            }
                        }, add: {
                            Menu(
                                content: {
                                    Button(action: {
                                        withAnimation(.easeInOut) {
                                            newProsthetic = newProthesis(type: .none)
                                            addLinerSheet = true
                                        }
                                    }, label: {
                                        Text(LocalizedStringKey("Prosthetic liner"))
                                            .padding(.vertical, 6)
                                            .padding(.horizontal, 12)
                                    })
                                },
                                label: {
                                    Image(systemName: "plus")
                                        .padding([.top, .bottom, .leading])
                                }
                            )
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                        })
                    .padding(.horizontal)
                    .foregroundColor(currentTheme.text)
                    // .homeScrollCardStyle(currentTheme: currentTheme)
                    
                    card(
                        header: "Prosthesis",
                        subheader: "Manage all your Prosthesis",
                        content: {
                            VStack(spacing: 6) {
                                ForEach(allProthesis) { prothese in
                                    
                                    ProthesenItem(
                                        prothese: prothese,
                                        showDatePicker: $showProtheseDatePicker,
                                        showMaintageIntervalPicker: $showMaintageIntervalPicker,
                                        newMaintageInterval: $newMaintageInterval,
                                        newMaintageDate: $newMaintageDate,
                                        selectedProthese: $selectedProthese,
                                        editProsthesisSheet: $editProsthesisSheet
                                    )
                                    
                                }
                            }
                        }, add: {
                            Menu(
                                content: {
                                    Button(action: {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                            newProsthetic = newProthesis(type: .belowKnee)
                                        })
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                            addProsthesisSheet = true
                                        })
                                    }, label: {
                                        Text("Below knee Prothesis")
                                            .padding(.vertical, 6)
                                            .padding(.horizontal, 12)
                                    })
                                    
                                    Button(action: {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                            newProsthetic = newProthesis(type: .aboveKnee)
                                        })
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                            addProsthesisSheet = true
                                        })
                                    }, label: {
                                        Text("Above knee Prothesis")
                                            .padding(.vertical, 6)
                                            .padding(.horizontal, 12)
                                    })
                                },
                                label: {
                                    Image(systemName: "plus")
                                        .padding([.top, .bottom, .leading])
                                }
                            )
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                        }
                    )
                    .padding(.horizontal)
                    .foregroundColor(currentTheme.text)
                }
            }
            .blur(radius: showLinerDatePicker || showProtheseDatePicker || showMaintageIntervalPicker ? 4 : 0)
            
            if showLinerDatePicker {
                DatepickerOverlay(
                    state: $showLinerDatePicker,
                    date: $newLinerDate,
                    dateCloseRange: selectedLiner?.interval != nil ? Calendar.current.dateRangeMinusMonth(Int(selectedLiner!.interval)) : nil,
                    content: {
                        HStack(content: {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.35)) {
                                    showLinerDatePicker = false
                                }
                            }, label: {
                                Text("Cancel")
                                    .foregroundColor(currentTheme.text)
                                    .padding()
                            })
                            .background(currentTheme.hightlightColor)
                            .cornerRadius(10)
                            
                            Spacer()
                            
                            Button(action: {
                                guard selectedLiner != nil else {
                                    return
                                }
                                if selectedLiner?.identifier == "NOID" {
                                    selectedLiner?.linerID = UUID().uuidString
                                }
                                
                                selectedLiner?.date = newLinerDate
                                
                                do {
                                    try viewContext.save()
                                    
                                    if let newLinerDate = selectedLiner {
                                        newLinerDate.removeAndRegisterNewLinerNotification()
                                    }
                                    
                                    withAnimation(.easeInOut(duration: 0.35)) {
                                        showLinerDatePicker = false
                                    }
                                } catch {
                                    // handle the Core Data error
                                }
                            }, label: {
                                Text("Save")
                                    .foregroundColor(currentTheme.text)
                                    .padding()
                            })
                            .background(currentTheme.hightlightColor)
                            .cornerRadius(10)
                        })
                    }
                )
            }
            
            if showProtheseDatePicker {
                DatepickerOverlay(
                    state: $showProtheseDatePicker,
                    date: $newMaintageDate,
                    dateCloseRange: selectedProthese?.maintageInterval != nil ? Calendar.current.dateRangeMinusMonth(Int(selectedProthese!.maintageInterval)) : nil,
                    content: {
                        HStack(content: {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.35)) {
                                    showProtheseDatePicker = false
                                }
                            }, label: {
                                Text("Cancel")
                                    .foregroundColor(currentTheme.text)
                                    .padding()
                            })
                            .background(currentTheme.hightlightColor)
                            .cornerRadius(10)
                            
                            Spacer()
                            
                            Button(action: {
                                guard selectedProthese != nil else {
                                    return
                                }
                                
                                if selectedProthese?.identifier == "NOID" {
                                    selectedProthese?.protheseID = UUID().uuidString
                                }
                                
                                selectedProthese?.maintage = newMaintageDate
                                
                                do {
                                    try viewContext.save()
                                    
                                    if let pro = selectedProthese, pro.hasMaintage {
                                        pro.registerNewProtheseNotification()
                                    }

                                    withAnimation(.easeInOut(duration: 0.35)) {
                                        showProtheseDatePicker = false
                                    }
                                } catch {
                                    // handle the Core Data error
                                }
                            }, label: {
                                Text("Save")
                                    .foregroundColor(currentTheme.text)
                                    .padding()
                            })
                            .background(currentTheme.hightlightColor)
                            .cornerRadius(10)
                        })
                    }
                )
            }
            
            if showMaintageIntervalPicker {
                
                IntervalPickerOverlay(
                    state: $showMaintageIntervalPicker,
                    value: $newMaintageInterval,
                    content: {
                        HStack(content: {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.35)) {
                                    showMaintageIntervalPicker = false
                                }
                            }, label: {
                                Text("Cancel")
                                    .foregroundColor(currentTheme.text)
                                    .padding()
                            })
                            .background(currentTheme.hightlightColor)
                            .cornerRadius(10)
                            
                            Spacer()
                            
                            Button(action: {
                                guard selectedProthese != nil else {
                                    return
                                }
                                
                                if selectedProthese?.identifier == "NOID" {
                                    selectedProthese?.protheseID = UUID().uuidString
                                }
                                
                                selectedProthese?.maintageInterval = Int16(newMaintageInterval)
                                
                                do {
                                    try viewContext.save()
                                    
                                    if let pro = selectedProthese, pro.hasMaintage {
                                        pro.registerNewProtheseNotification()
                                    }
                                    
                                    withAnimation(.easeInOut(duration: 0.35)) {
                                        showMaintageIntervalPicker = false
                                    }
                                } catch {
                                    // handle the Core Data error
                                }
                            }, label: {
                                Text("Save")
                                    .foregroundColor(currentTheme.text)
                                    .padding()
                            })
                            .background(currentTheme.hightlightColor)
                            .cornerRadius(10)
                        })
                    }
                )
            }
        }
        // ADDLINER
        .blurredOverlaySheet(.init(.ultraThinMaterial), show: $addLinerSheet, onDismiss: {
            newProsthetic = newProthesis(type: .none)
        }, content: {
            AddLinerSheetBody(sheet: $addLinerSheet)
        })
        // EDITLiner
        .blurredSheet(.init(.ultraThinMaterial), show: $editLinerSheet, onDismiss: {
            selectedLiner = nil
        }, content: {
            EditLinerBody(selectedLiner: $selectedLiner, editLinerSheet: $editLinerSheet)
                .padding()
                .presentationDragIndicator(.visible)
        })
        // EDITPROTHESE
        .blurredSheet(.init(.ultraThinMaterial), show: $editProsthesisSheet, onDismiss: {
            selectedProthese = nil
        }, content: {
            EditProsthesisBody(selectedProsthesis: $selectedProthese, editProsthesisSheet: $editProsthesisSheet)
                .padding()
                .presentationDragIndicator(.visible)
        })
        // ADDPROTHESE
        .blurredOverlaySheet(.init(.ultraThinMaterial), show: $addProsthesisSheet, onDismiss: {
            newProsthetic = newProthesis(type: .none)
        }, content: {
            AddProsthesisSheetBody(sheet: $addProsthesisSheet)
        })
    }
    
    @ViewBuilder
    func Background() -> some View {
        currentTheme.gradientBackground(nil)
            .ignoresSafeArea()
        
        CircleAnimationInBackground(delay: 0.3, duration: 2)
            .opacity(0.2)
            .ignoresSafeArea()
    }
    
    @ViewBuilder
    func Header(_ text: LocalizedStringKey) -> some View {
        HStack{
            Spacer()
            
            Text(text)
                .foregroundColor(currentTheme.text)
            
            Spacer()
        }
        .padding(.top, 25)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func AddLinerSheetBody(sheet: Binding<Bool>) -> some View {
        ZStack {
            
            VStack {
                
                SheetHeader(title: "Prosthetic liner", action: {
                    sheet.wrappedValue.toggle()
                })
                
                VStack {
                    if linerType == "" {
                        Text("What purpose would you like to add?")
                            .font(.title.bold())
                            .foregroundColor(currentTheme.text)
                            .padding(.top, 50)
                            .padding(.vertical, 50)

                        VStack(spacing: 20) {
                            Button {
                                withAnimation(.easeInOut) {
                                    linerType = "oneToOne"
                                    newLiner = Pro_these_.newLiner(name: "", model: "", brand: "", lastDate: Date(), interval: 0, prothese: nil)
                                }
                            } label: {
                                HStack {
                                    Spacer()
                                    
                                    Text("One to One").padding()
                                    
                                    Spacer()
                                }
                                .font(.body.bold())
                                .foregroundColor(currentTheme.primary)
                                .background(currentTheme.hightlightColor.gradient)
                                .cornerRadius(15)
                            }
                            
                            Button {
                                withAnimation(.easeInOut) {
                                    linerType = "oneToMany"
                                    newLiner = Pro_these_.newLiner(name: "", model: "", brand: "", lastDate: Date(), interval: 0, prothese: nil)
                                }
                            } label: {
                                HStack {
                                    Spacer()
                                    
                                    Text("One to Many").padding()
                                    
                                    Spacer()
                                }
                                .font(.body.bold())
                                .foregroundColor(currentTheme.primary)
                                .background(currentTheme.hightlightColor.gradient)
                                .cornerRadius(15)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    // MARK: - Choose PROTHESE KIND (SPORT/EVERYDAY/WATERPROOF)
                    if linerType == "oneToOne" && protheseLiner == nil {
                        Text("What kind of prosthesis would you like to add?")
                            .font(.title.bold())
                            .foregroundColor(currentTheme.text)
                            .padding(.top, 50)
                            .padding(.vertical, 50)

                        VStack(spacing: 20) {
                            ForEach(allProthesis, id: \.hashValue) { prothese in
                                Button {
                                    if (newLiner != nil) {
                                        self.protheseLiner = prothese
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
                        
                        Spacer()
                    }
                    
                    // MARK: - Choose PROTHESE SUMMERY
                    if linerType == "oneToMany" || linerType == "oneToOne" && protheseLiner != nil {
                        if let liner = newLiner {
                            VStack(spacing: 40) {
                                
                                HStack {
                                    Spacer()
                                    
                                    Image("prothese.liner")
                                        .font(.largeTitle)
                                        .scaleEffect(2)
                                        .foregroundColor(currentTheme.hightlightColor)

                                    Spacer()
                                }
                                .padding(.top, 100)
                                
                                VStack {
                                    Text("What's the name of the manufacturer?")
                                        .font(.title3.bold())
                                        .foregroundColor(currentTheme.text)

                                    TextField(linerBrand == "" ? LocalizedStringKey("Enter the Brand Name").localizedstring() : linerBrand, text: $linerBrand)
                                        .multilineTextAlignment(.center)
                                        .font(.title3.bold())
                                }
                                
                                VStack {
                                    Text("What is the name of the liner model?")
                                        .font(.title3.bold())
                                        .foregroundColor(currentTheme.text)
                                    
                                    TextField(linerModel == "" ? LocalizedStringKey("Enter the Product Name").localizedstring() : linerModel, text: $linerModel)
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
                                    
                                    Picker(LocalizedStringKey("Date Interval:"), selection: $linerInterval, content: {
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
                                            linerBrand = ""
                                            linerModel = ""
                                            linerType = ""
                                            protheseLiner = nil
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
                }
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    func AddProsthesisSheetBody(sheet: Binding<Bool>) -> some View {
        ZStack {
            
            VStack {
                
                SheetHeader(title: newProsthetic.type.rawValue, action: {
                    sheet.wrappedValue.toggle()
                    newProsthetic = newProthesis(type: .none)
                })
                
                VStack {
                    // MARK: - Choose PROTHESE TYP (BELOW/ABOVE)
                    if newProsthetic.type == prothesis.type.none {
                        Text("What type of prosthesis would you like to add?")
                            .font(.title.bold())
                            .foregroundColor(currentTheme.text)
                            .padding(.top, 50)
                            .padding(.vertical, 50)
                        
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
                                                .underline(newProsthetic.type == type, color: currentTheme.hightlightColor)
                                        }
                                       
                                    })
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    
                    if newProsthetic.type != prothesis.type.none && newProsthetic.kind == prothesis.kind.none {
                        
                        VStack(alignment: .center, spacing: 15) {
                            Image(newProsthetic.type.icon)
                                .font(.largeTitle.bold())
                                .foregroundStyle(currentTheme.hightlightColor, currentTheme.textGray)
                                
                            Text("What kind of prosthesis would you like to add?")
                                .font(.title.bold())
                                .foregroundColor(currentTheme.text)
                        }
                        .padding(.top, 50)
                        .padding(.vertical, 50)

                        VStack(spacing: 20) {
                            ForEach(prothesis.allKinds, id: \.hashValue) { kind in
                                Button {
                                    withAnimation(.easeInOut) {
                                        newProsthetic =  newProthesis(type: newProsthetic.type, kind: kind)
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
                        
                        Spacer()
                    }
                    
                    if newProsthetic.type != prothesis.type.none && newProsthetic.kind != prothesis.kind.none {
                        
                        // if below
                        if newProsthetic.kind != prothesis.kind.none && newProsthetic.type == prothesis.type.belowKnee {
                            VStack(spacing: 40) {
                                HStack {
                                    Spacer()
                                    
                                    if newProsthetic.type == prothesis.type.belowKnee {
                                        Image(prothesis.type.belowKnee.icon)
                                            .font(.largeTitle)
                                            .scaleEffect(2)
                                            .foregroundStyle(currentTheme.hightlightColor, currentTheme.textGray)
                                    }
                                    
                                    if newProsthetic.type == prothesis.type.aboveKnee {
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
                                        Text(newProsthetic.kind.rawValue)
                                    }
                                    .padding(.horizontal)
                                    
                                    HStack {
                                        Text("Type: ")
                                        Spacer()
                                        Text(newProsthetic.type.rawValue)
                                    }
                                    .padding(.horizontal)
                                }
                                
                                HStack(spacing: 40) {
                                    Button(action: {
                                        withAnimation(.easeInOut) {
                                            newProsthetic = newProthesis(type: .none)
                                            
                                            withAnimation(.easeInOut) {
                                                addProsthesisSheet = false
                                            }
                                        }
                                    }, label: {
                                        Text("Cancel")
                                    })
                                    .padding()
                                    .font(.body.bold())
                                    .foregroundColor(currentTheme.primary)
                                    .background(currentTheme.hightlightColor)
                                    .cornerRadius(15)
                                    
                                    saveBelow(newProsthetic)
                                }
                               
                                Spacer()
                            }
                        } else {
                            VStack(spacing: 40) {

                                HStack {
                                    Spacer()
                                    
                                    if newProsthetic.type == prothesis.type.belowKnee {
                                        Image(prothesis.type.belowKnee.icon)
                                            .font(.largeTitle)
                                            .scaleEffect(2)
                                            .foregroundStyle(currentTheme.hightlightColor, currentTheme.textGray)
                                    }
                                    
                                    if newProsthetic.type == prothesis.type.aboveKnee {
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
                                            newProsthetic = newProthesis(type: .none)
                                            
                                            withAnimation(.easeInOut) {
                                                addProsthesisSheet = false
                                            }
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
                                    
                                    saveAbove(newProsthetic)
                                }
                                
                                Spacer()
                                
                            }
                        }
                      
                        
                    }
                }
                .padding(.horizontal)
            }
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
                newProsthetic = newProthesis(type: .none)
                
                withAnimation(.easeInOut) {
                    addProsthesisSheet = false
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
                newProsthetic = newProthesis(type: .none)
                
                withAnimation(.easeInOut) {
                    addProsthesisSheet = false
                }
                
                if new.hasMaintage {
                    new.registerNewProtheseNotification()
                }
            }
        }, label: {
            Text("Add")
        })
        .padding()
        .font(.body.bold())
        .foregroundColor(currentTheme.primary)
        .background(currentTheme.hightlightColor)
        .cornerRadius(15)
    }
    
    @ViewBuilder
    func saveLiner(_ input: newLiner) -> some View {
        Button(action: {
            let new = Liner(context: viewContext)
            new.name = linerBrand + " " + linerModel
            new.linerID = UUID().uuidString
            new.brand = linerBrand
            new.model = linerModel
            new.date = LastLinerDate
            new.interval = Int16(linerInterval)
            if let p = protheseLiner {
                new.addToProthese(p)
            }
            
            do {
                try? viewContext.save()
                
                newLiner = nil
                linerBrand = ""
                linerModel = ""
                linerType = ""
                protheseLiner = nil
                LastLinerDate = Date()
                
                new.registerNewLinerNotification()
                
                withAnimation(.easeInOut) {
                    addLinerSheet = false
                }
            }
        }, label: {
            Text("Add")
        })
        .padding()
        .font(.body.bold())
        .foregroundColor(currentTheme.primary)
        .background(currentTheme.hightlightColor)
        .cornerRadius(15)
    }
}

struct card<Content:View, Add: View>: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    private var content: Content
    private var add: Add
    private var header: LocalizedStringKey
    private var subheader: LocalizedStringKey
    
    init(header: LocalizedStringKey, subheader: LocalizedStringKey, @ViewBuilder content: @escaping () -> Content, @ViewBuilder add: @escaping () -> Add ) {
        self.content = content()
        self.add = add()
        self.header = header
        self.subheader = subheader
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(header) 
                        .font(.body.bold())
                        .foregroundColor(currentTheme.text)
                    
                    Text(subheader)
                        .font(.caption2)
                        .foregroundColor(currentTheme.text)
                        .padding(.bottom, 6)
                }
                
                Spacer()

                add
            }
            
            content
        }
    }
}

struct LinerItem: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @ObservedObject var liner: Liner
    
    @State var showMoreOptions: Bool = false
    
    @Binding var showDatePicker: Bool
    
    @Binding var newLinerDate: Date
    
    @Binding var selectedLiner: Liner?
    
    @Binding var addLinerSheet: Bool
    
    @Binding var editLinerSheet: Bool
    
    var body: some View {
        VStack(spacing: 0) {
           
            Button(action: {
                withAnimation(.easeInOut(duration: 0.35)) {
                    showMoreOptions.toggle()
                }
            }, label: {
                HStack(alignment: .top) {
                    VStack {
                        Image("prothese.liner")
                            .rotationEffect(.degrees(180))
                            .font(.largeTitle)
                            .foregroundColor(currentTheme.hightlightColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text("\(liner.brand ?? "") - \(liner.model ?? "")")
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        
                        HStack {
                            let prothesen = liner.prothese?.allObjects as? [Prothese]
                            ForEach(prothesen ??  []) { prothese in
                                Text(prothese.kind?.prosthesisKinds ?? LocalizedStringKey(""))
                            }
                            
                            Spacer()
                        }
                        .font(.caption2.bold())
                        .foregroundColor(currentTheme.textGray)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Spacer()
          
                            Text(liner.nextLinerCounterText)
                                .font(.headline.bold())
                                .foregroundColor(liner.nextLinerDateIsInFuture ? currentTheme.hightlightColor : .red)
                            
                        }
                        .frame(maxWidth: .infinity)
                        
                        HStack {
                            Spacer()
                            
                            Text("Last Liner: \(liner.date?.dateFormatte(date: "dd.MM.yy", time: "").date ?? "")")
                                .font(.caption2)
                                .foregroundColor(currentTheme.textGray)
                            
                        }
                        .font(.caption2.bold())
                        .foregroundColor(currentTheme.textGray)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical)
                .padding(.horizontal)
                .background(.ultraThinMaterial.opacity(0.6))
                .cornerRadius(15)
            })
            
            if showMoreOptions {
                HStack {
                    Menu("Options") {
                        Button(action: {
                            liner.date = Date().setHourTo8am
                            
                            if liner.identifier == "NOID" {
                                liner.linerID = UUID().uuidString
                            }
                            
                            do {
                                try viewContext.save()
                                
                                liner.removeAndRegisterNewLinerNotification()
                            } catch {
                                // handle the Core Data error
                            }
                        }, label: {
                            Text("Recieved today")
                        })
                        
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.35)) {
                                showDatePicker = true
                                selectedLiner = liner
                                newLinerDate = Date()
                            }
                        }, label: {
                            Text("Received another day")
                        })
                        
                        Button(action: {
                            liner.removeLinerNotification()
                            
                            viewContext.delete(liner)
                            
                            do {
                                try viewContext.save()
                            } catch {
                                // handle the Core Data error
                            }
                        }, label: {
                            HStack {
                                Text("Delete")
                                Spacer()
                                Image(systemName: "trash")
                            }
                        })
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .font(.footnote.bold())
                    .foregroundColor(currentTheme.primary)
                    .background(currentTheme.hightlightColor)
                    .cornerRadius(15)
                    
                    Button(action: {
                        selectedLiner = liner
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            editLinerSheet = true
                        })
                    }, label: {
                        Text("Edit")
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                    })
                    .font(.footnote.bold())
                    .foregroundColor(currentTheme.primary)
                    .background(currentTheme.hightlightColor)
                    .cornerRadius(15)
                    
                    Spacer()
                }
                .padding(.vertical)
                .padding(.horizontal)
            }
            
        }
        .background(.ultraThinMaterial.opacity(0.4))
        .cornerRadius(10)
    }
}

struct EditLinerBody: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @Binding var selectedLiner: Liner?
    
    @Binding var editLinerSheet: Bool
    
    @State var brand: String = ""
    
    @State var model: String = ""
    
    @State var date: Date = Date()
    
    @State var interval = 0
    
    
    var body: some View {
        VStack(spacing: 40) {
            
            HStack {
                Spacer()
                
                Image("prothese.liner")
                    .font(.largeTitle)
                    .scaleEffect(2)
                    .foregroundColor(currentTheme.hightlightColor)

                Spacer()
            }
            .padding(.top, 100)
            
            VStack {
                Text("What's the name of the manufacturer?")
                    .font(.title3.bold())
                    .foregroundColor(currentTheme.text)

                TextField(brand == "" ? "Enter the Brand Name" : brand, text: $brand)
                    .multilineTextAlignment(.center)
                    .font(.title3.bold())
            }
            
            VStack {
                Text("What is the name of the liner model?")
                    .font(.title3.bold())
                    .foregroundColor(currentTheme.text)
                
                TextField(model == "" ? "Enter the Product Name" : model, text: $model)
                    .multilineTextAlignment(.center)
                    .font(.title3.bold())
            }
            
            DatePicker(LocalizedStringKey("Get last liner?:"), selection: $date, displayedComponents: .date)
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
                        withAnimation(.easeInOut) {
                            editLinerSheet = false
                            selectedLiner = nil
                        }
                    }
                }, label: {
                    Text("Cancel")
                        .foregroundColor(currentTheme.primary)
                })
                .padding()
                .background(currentTheme.hightlightColor)
                .cornerRadius(15)
                
                Button(action: {
                    selectedLiner?.brand = brand
                    selectedLiner?.model = model
                    selectedLiner?.interval = Int16(interval)
                    selectedLiner?.date = date
                    
                    if selectedLiner?.identifier == "NOID" {
                        selectedLiner?.linerID = UUID().uuidString
                    }
                    
                    do {
                        try viewContext.save()
                        
                        selectedLiner?.removeAndRegisterNewLinerNotification()
                        
                        withAnimation(.easeInOut) {
                            editLinerSheet = false
                            selectedLiner = nil
                        }
                    } catch let error as NSError {
                        print("Fail: \(error.localizedDescription)")
                    }
                }, label: {
                    Text("Save")
                        .foregroundColor(currentTheme.primary)
                })
                .padding()
                .background(currentTheme.hightlightColor)
                .cornerRadius(15)
            }
            
            Spacer()
        }
        .onAppear {
            brand = selectedLiner?.brand ?? ""
            model = selectedLiner?.model ?? ""
            interval = Int(selectedLiner?.interval ?? 1)
            date = selectedLiner?.date ?? Date()
        }
    }
}

struct EditProsthesisBody: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @Binding var selectedProsthesis: Prothese?
    @Binding var editProsthesisSheet: Bool
    
    @State var lastProstheticMainTage = Date()
    @State var maintageSelection = 1
    
    var body: some View {
        VStack(spacing: 40) {
            if let prothese = selectedProsthesis {
                if LocalizedStringKey(prothese.type ?? "").localizedstring() == prothesis.type.belowKnee.rawValue.localizedstring() {
                    HStack {
                        Spacer()
                        
                        if LocalizedStringKey(prothese.type ?? "").localizedstring() == prothesis.type.belowKnee.rawValue.localizedstring() {
                            Image(prothesis.type.belowKnee.icon)
                                .font(.largeTitle)
                                .scaleEffect(2)
                                .foregroundStyle(currentTheme.hightlightColor, currentTheme.textGray)
                        }
                        
                        if LocalizedStringKey(prothese.type ?? "").localizedstring() == prothesis.type.aboveKnee.rawValue.localizedstring() {
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
                            Text(prothese.kind ?? "")
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Text("Type: ")
                            Spacer()
                            Text(prothese.type ?? "")
                        }
                        .padding(.horizontal)
                    }
                    
                    HStack(spacing: 40) {
                        Button(action: {
                            lastProstheticMainTage = Date()
                            maintageSelection = 1
                            withAnimation(.easeInOut) {
                                editProsthesisSheet = false
                                selectedProsthesis = nil
                            }
                        }, label: {
                            Text("Cancel")
                                .foregroundColor(currentTheme.primary)
                        })
                        .padding()
                        .background(currentTheme.hightlightColor)
                        .cornerRadius(15)
                        
                        Button(action: {
                            selectedProsthesis?.maintage = lastProstheticMainTage
                            selectedProsthesis?.maintageInterval = Int16(maintageSelection)
                            
                            if selectedProsthesis?.protheseID == "NOID" {
                                selectedProsthesis?.protheseID = UUID().uuidString
                            }
                            
                            do {
                                try viewContext.save()
                                if selectedProsthesis?.hasMaintage != nil {
                                    selectedProsthesis?.removeAndRegisterNewProtheseNotification()
                                }
                                
                                withAnimation(.easeInOut) {
                                    editProsthesisSheet = false
                                    selectedProsthesis = nil
                                }
                            } catch let error as NSError {
                                print("Fail: \(error.localizedDescription)")
                            }
                        }, label: {
                            Text("Save")
                                .foregroundColor(currentTheme.primary)
                        })
                        .padding()
                        .background(currentTheme.hightlightColor)
                        .cornerRadius(15)
                    }
                   
                    Spacer()
                } else {
                    HStack {
                        Spacer()

                        if LocalizedStringKey(prothese.type ?? "").localizedstring() == prothesis.type.belowKnee.rawValue.localizedstring() {
                            Image(prothesis.type.belowKnee.icon)
                                .font(.largeTitle)
                                .scaleEffect(2)
                                .foregroundStyle(currentTheme.hightlightColor, currentTheme.textGray)
                        }
                        
                        if LocalizedStringKey(prothese.type ?? "").localizedstring() == prothesis.type.aboveKnee.rawValue.localizedstring() {
                            Image(prothesis.type.aboveKnee.icon)
                                .font(.largeTitle)
                                .scaleEffect(2)
                                .foregroundStyle(currentTheme.hightlightColor, currentTheme.textGray)
                        }

                        Spacer()
                    }
                    .padding(.top, 100)

                    DatePicker(LocalizedStringKey("Last Maintage:"), selection: $lastProstheticMainTage, displayedComponents: .date)
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
                            lastProstheticMainTage = Date()
                            maintageSelection = 1
                            withAnimation(.easeInOut) {
                                editProsthesisSheet = false
                                selectedProsthesis = nil
                            }
                        }, label: {
                            Text("Cancel")
                                .foregroundColor(currentTheme.primary)
                        })
                        .padding()
                        .background(currentTheme.hightlightColor)
                        .cornerRadius(15)
                        
                        Button(action: {
                            selectedProsthesis?.maintage = lastProstheticMainTage
                            selectedProsthesis?.maintageInterval = Int16(maintageSelection)
                            
                            if selectedProsthesis?.protheseID == "NOID" {
                                selectedProsthesis?.protheseID = UUID().uuidString
                            }
                            
                            do {
                                try viewContext.save()
                                
                                if selectedProsthesis?.hasMaintage != nil {
                                    selectedProsthesis?.removeAndRegisterNewProtheseNotification()
                                }
                                
                                withAnimation(.easeInOut) {
                                    editProsthesisSheet = false
                                    selectedProsthesis = nil
                                }
                            } catch let error as NSError {
                                print("Fail: \(error.localizedDescription)")
                            }
                        }, label: {
                            Text("Save")
                                .foregroundColor(currentTheme.primary)
                        })
                        .padding()
                        .background(currentTheme.hightlightColor)
                        .cornerRadius(15)
                    }
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            lastProstheticMainTage = selectedProsthesis?.maintage ?? Date()
            maintageSelection = Int(selectedProsthesis?.maintageInterval ?? 0)
        }
    }
}

struct ProthesenItem: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @ObservedObject var prothese: Prothese
    
    @State var showMoreOptions: Bool = false
    
    @Binding var showDatePicker: Bool
    
    @Binding var showMaintageIntervalPicker: Bool
    
    @Binding var newMaintageInterval: Int
    
    @Binding var newMaintageDate: Date
    
    @Binding var selectedProthese: Prothese?
    
    @Binding var editProsthesisSheet: Bool
    
    var body: some View {
        VStack(spacing: 0) {
           
            Button(action: {
                withAnimation(.easeInOut(duration: 0.35)) {
                    showMoreOptions.toggle()
                }
            }, label: {
                VStack(alignment: .leading) {
                    
                    HStack(alignment: .top) {
                        VStack {
                            Image(prothese.prosthesisIcon)
                                .font(.title)
                                .foregroundStyle(currentTheme.hightlightColor, currentTheme.textGray)
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text(prothese.prosthesisKind)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            
                            HStack {
                                Text(prothese.prosthesisType)
                                
                                Spacer()
                            }
                            .font(.caption2.bold())
                            .foregroundColor(currentTheme.textGray)
                            .frame(maxWidth: .infinity)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        
                        if prothese.hasMaintage && prothese.nextMaintenanceIsInLessThan90Days || prothese.hasMaintage && !prothese.nextMaintenanceDateIsInFuture {
                            VStack {
                                HStack {
                                    Spacer()
                  
                                    Text(prothese.MaintenanceCounterText)
                                        .font(.headline.bold())
                                        .foregroundColor(prothese.nextMaintenanceDateIsInFuture ? currentTheme.hightlightColor : .red)
                                    
                                }
                                .frame(maxWidth: .infinity)
                                
                                HStack {
                                    Spacer()
                                    
                                    Text("\(prothese.nextMaintenanceDateString)")
                                        .font(.caption2)
                                        .foregroundColor(currentTheme.textGray)
                                    
                                }
                                .font(.caption2.bold())
                                .foregroundColor(currentTheme.textGray)
                                .frame(maxWidth: .infinity)
                                .frame(maxWidth: .infinity)
                            }
                        }
                     
                    }
                    
                    if prothese.hasMaintage {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(prothese.prosthesisMaintageDate)
                                    .font(.headline.bold())
                                    .foregroundColor(currentTheme.hightlightColor)
                                
                                Text(LocalizedStringKey("Last maintenance"))
                                    .font(.caption2)
                                    .foregroundColor(currentTheme.textGray)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(prothese.prosthesisMaintageInterval)
                                    .font(.headline.bold())
                                    .foregroundColor(currentTheme.hightlightColor)
                                
                                Text(LocalizedStringKey("Maintenance interval"))
                                    .font(.caption2)
                                    .foregroundColor(currentTheme.textGray)
                            }
                        }
                        .font(.caption2.bold())
                        .foregroundColor(currentTheme.textGray)
                    }
                }
                .padding(.vertical)
                .padding(.horizontal)
                .background(.ultraThinMaterial.opacity(0.6))
                .cornerRadius(15)
            })
            
            if showMoreOptions {
                HStack {
                    Menu("Options") {
                        if prothese.hasMaintage {
                            Button(action: {
                                if prothese.identifier == "NOID" {
                                    prothese.protheseID = UUID().uuidString
                                }
                                
                                prothese.maintage = Date().setHourTo8am
                                
                                do {
                                    try viewContext.save()
                                    
                                    if prothese.hasMaintage {
                                        prothese.registerNewProtheseNotification()
                                    }
                                } catch {
                                    // handle the Core Data error
                                }
                               
                            }, label: {
                                Text("Maintenance was today") 
                            })
                            
                            Button(action: {
                                showDatePicker = true
                                selectedProthese = prothese
                                newMaintageDate = Date()
                            }, label: {
                                Text("Maintenance was another day")
                            })
                            
                            Button(action: {
                                showMaintageIntervalPicker = true
                                selectedProthese = prothese
                                newMaintageInterval = Int(prothese.maintageInterval)
                            }, label: {
                                Text("Change Maintenance Interval")
                            })
                        }
                        
                        Button(action: {
                            prothese.removeProtheseNotification()
                            viewContext.delete(prothese)
                            
                            do {
                                try viewContext.save()
                            } catch {
                                // handle the Core Data error
                            }
                        }, label: {
                            HStack {
                                Text("Delete")
                                Spacer()
                                Image(systemName: "trash")
                            }
                        })
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .font(.footnote.bold())
                    .foregroundColor(currentTheme.primary)
                    .background(currentTheme.hightlightColor)
                    .cornerRadius(15)
                    
                    Button(action: {
                        selectedProthese = prothese
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            editProsthesisSheet.toggle()
                        })
                    }, label: {
                        Text("Edit")
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                    })
                    .font(.footnote.bold())
                    .foregroundColor(currentTheme.primary)
                    .background(currentTheme.hightlightColor)
                    .cornerRadius(15)
                    
                    Spacer()
                }
                .padding(.vertical)
                .padding(.horizontal)
            }
            
        }
        .background(.ultraThinMaterial.opacity(0.4))
        .cornerRadius(10)
    }
}

struct DatepickerOverlay<Content:View>: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    private var content: Content

    @Binding var state: Bool
    @Binding var date: Date
    
    private var dateClosedRange: ClosedRange<Date>
    
    init(
        state: Binding<Bool>,
        date: Binding<Date>,
        dateCloseRange: ClosedRange<Date>?,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._state = state
        self._date = date
        self.dateClosedRange = dateCloseRange ?? Calendar.current.dateRangeMinusMonth(6)
        self.content = content()
    }
    
    var body: some View {
        if state {
           VStack {
               ZStack {
                   currentTheme.textBlack.opacity(0.5).ignoresSafeArea()
                   
                   VStack(spacing: 20) {
                       Spacer()
                       
                       HStack {
                           Spacer()
                           
                           Button(action: {
                               withAnimation(.easeInOut) {
                                   state = false
                               }
                           }, label: {
                               Image(systemName: "xmark")
                                   .foregroundColor(currentTheme.text)
                           })
                       }
                       .padding(.horizontal, 50)
                       
                       DatePicker(
                           "",
                           selection: $date,
                           in: dateClosedRange,
                           displayedComponents: .date
                       )
                       .labelsHidden()
                       .datePickerStyle(.wheel)
                       .background(.ultraThinMaterial)
                       .cornerRadius(20)
                       .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                       
                       content
                           .padding(.horizontal, 50)
                       
                       Spacer()
                   }
               }
               
               Spacer()
           }
           
       }
    }
}

struct IntervalPickerOverlay<Content:View>: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    private var content: Content

    @Binding var state: Bool
    @Binding var value: Int
    
    init(
        state: Binding<Bool>,
        value: Binding<Int>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._state = state
        self._value = value
        self.content = content()
    }
    
    var body: some View {
        if state {
           VStack {
               ZStack {
                   currentTheme.textBlack.opacity(0.5).ignoresSafeArea()
                   
                   VStack(spacing: 20) {
                       Spacer()
                       
                       HStack {
                           Spacer()
                           
                           Button(action: {
                               withAnimation(.easeInOut) {
                                   state = false
                               }
                           }, label: {
                               Image(systemName: "xmark")
                                   .foregroundColor(currentTheme.text)
                           })
                       }
                       .padding(.horizontal, 50)
                       
                       Picker("Set interval", selection: $value) {
                              ForEach([6,12], id: \.self) { int in
                                  Text(LocalizedStringKey("\(int) months interval")).tag(int)
                                      .foregroundColor(currentTheme.text)
                              }
                       }
                       .pickerStyle(.wheel)
                       .tint(currentTheme.text)
                       .background(.ultraThinMaterial)
                       .cornerRadius(20)
                       .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                       .frame(height: 150)
                       .padding(.horizontal, 50)
                       .compositingGroup()
                       
                       content
                           .padding(.horizontal, 50)
                       
                       Spacer()
                   }
               }
               
               Spacer()
           }
           
       }
    }
}

struct LinerOverview_Previews: PreviewProvider {
    static var previews: some View {
        LinerOverview()
    }
}

