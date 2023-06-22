//
//  PainAddSheet.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 26.05.23.
//

import SwiftUI

struct PainAddSheet: View {
    @EnvironmentObject var vm: PainViewModel
    private let persistenceController = PersistenceController.shared
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .reverse)]) private var PainReasons: FetchedResults<PainReason>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .reverse)]) private var PainDrugs: FetchedResults<PainDrug>
    
    var body: some View {
        GeometryReader { geo in
            
            if let pain = vm.editPain {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 30) {
                        // close
                        
                        SheetHeader("Schmerz bearbeiten", action: {
                            withAnimation(.easeInOut) {
                                vm.isPainAddSheet.toggle()
                                vm.isPainAddSheet = false
                                vm.selectedPain = 0
                                vm.painReason = ""
                                vm.AddPainReasonText = ""
                                vm.painDrug = ""
                                vm.AddPainDrugText = ""
                                vm.showPainReasonPicker = false
                                vm.showPainDrugPicker = false
                                vm.showDatePicker = false
                            }
                        })
                        
                        Spacer()
                        
                        // header
                        Header()
                        
                        // PainPicker
                        PainPicker(screen: geo.size)
                        
                        
                        // DatePicker
                        Button {
                            withAnimation {
                                vm.showDatePicker.toggle()
                            }
                        }  label: {
                            HStack(spacing: 20){
                                Image(systemName: "calendar.badge.plus")
                                    .font(.title3)
                                
                                Spacer()
                                
                                Text(vm.addPainDate, style: .date)
                            }
                            .padding()
                            .padding(.horizontal)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray)
                            )
                        }
                        .background(
                            DatePicker("", selection: $vm.addPainDate, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)
                                .frame(width: 200, height: 100)
                                .clipped()
                                .background(Color.gray.cornerRadius(10))
                                .opacity(vm.showDatePicker ? 1 : 0 )
                                .offset(x: 50, y: 90)
                        ).onChange(of: vm.addPainDate) { newValue in
                           withAnimation {
                               vm.showDatePicker.toggle()
                           }
                       }// DatePicker
                        
                        HStack(alignment: .top, spacing: 8) {
                            Reason()
                            
                            Drugs()
                        }
                        
                        Spacer()

                        HStack{
                            Button("Abbrechen"){
                                vm.resetStates()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            
                            Button("Ändern"){
                                // save
                                
                                let newPain = pain
                                newPain.date = vm.addPainDate
                                newPain.painIndex = Int16(vm.selectedPain)
                                newPain.painReasons = vm.selectedReason
                                newPain.painDrugs = vm.selectedDrug
                                
                                if vm.AddPainReasonText != "" {
                                    let newPainReason = pain.painReasons
                                    newPainReason?.name = vm.AddPainReasonText
                                    newPainReason?.date = vm.addPainDate
                                    newPain.painReasons = newPainReason
                                }
                                
                                if vm.AddPainDrugText != "" {
                                    let newPainDrug = pain.painDrugs
                                    newPainDrug?.name = vm.AddPainDrugText
                                    newPainDrug?.date = vm.addPainDate
                                    newPain.painDrugs = newPainDrug
                                }

                                do {
                                    try? persistenceController.container.viewContext.save()
                                    vm.isPainAddSheet.toggle()
                                    
                                    // reset
                                    vm.resetStates()
                                }
                               
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.05))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 10)
                        .opacity( withAnimation(.easeOut(duration: 0.3)){
                            vm.validation()
                        } )
                        
                        
                    }
                    .padding()
                    .presentationDragIndicator(.visible)
                    .foregroundColor(.white)
                    .onAppear{
                        vm.addPainDate = pain.date ?? Date()
                        vm.showDatePicker.toggle()
                        vm.selectedPain = Int(pain.painIndex)
                        vm.selectedReason = pain.painReasons
                        vm.selectedDrug = pain.painDrugs
                    }
                }
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 30) {
                        // close
                        
                        SheetHeader("Hast du Schmerzen?", action: {
                            withAnimation(.easeInOut) {
                                vm.isPainAddSheet.toggle()
                                vm.isPainAddSheet = false
                                vm.selectedPain = 0
                                vm.painReason = ""
                                vm.AddPainReasonText = ""
                                vm.painDrug = ""
                                vm.AddPainDrugText = ""
                                vm.showPainReasonPicker = false
                                vm.showPainDrugPicker = false
                                vm.showDatePicker = false
                            }
                        })
                        
                        Spacer()
                        
                        // header
                        Header()
                        
                        // PainPicker
                        PainPicker(screen: geo.size)
                        
                        
                        // DatePicker
                        Button {
                            withAnimation {
                                vm.showDatePicker.toggle()
                            }
                        }  label: {
                            HStack(spacing: 20){
                                Image(systemName: "calendar.badge.plus")
                                    .font(.title3)
                                
                                Spacer()
                                
                                Text(vm.addPainDate, style: .date)
                            }
                            .padding()
                            .padding(.horizontal)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray)
                            )
                        }
                        .background(
                            DatePicker("", selection: $vm.addPainDate, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)
                                .frame(width: 200, height: 100)
                                .clipped()
                                .background(Color.gray.cornerRadius(10))
                                .opacity(vm.showDatePicker ? 1 : 0 )
                                .offset(x: 50, y: 90)
                        ).onChange(of: vm.addPainDate) { newValue in
                           withAnimation {
                               vm.showDatePicker.toggle()
                           }
                       }// DatePicker
                        
                        HStack(alignment: .top, spacing: 8) {
                            Reason()
                            
                            Drugs()
                        }
                        
                        Spacer()

                        HStack{
                            Button("Abbrechen"){
                                vm.resetStates()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            
                            Button("Speichern"){
                                // save
                                
                                let newPain = Pain(context: persistenceController.container.viewContext)
                                newPain.date = vm.addPainDate
                                newPain.painIndex = Int16(vm.selectedPain)
                                newPain.painReasons = vm.selectedReason
                                newPain.painDrugs = vm.selectedDrug
                                
                                if vm.AddPainReasonText != "" {
                                    let newPainReason = PainReason(context: persistenceController.container.viewContext)
                                    newPainReason.name = vm.AddPainReasonText
                                    newPainReason.date = vm.addPainDate
                                    newPain.painReasons = newPainReason
                                }
                                
                                if vm.AddPainDrugText != "" {
                                    let newPainDrug = PainDrug(context: persistenceController.container.viewContext)
                                    newPainDrug.name = vm.AddPainDrugText
                                    newPainDrug.date = vm.addPainDate
                                    newPain.painDrugs = newPainDrug
                                }

                                do {
                                    try? persistenceController.container.viewContext.save()
                                    vm.isPainAddSheet.toggle()
                                    
                                    // reset
                                    vm.resetStates()
                                }
                               
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.05))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 10)
                        .opacity( withAnimation(.easeOut(duration: 0.3)){
                            vm.validation()
                        } )
                        
                        
                    }
                    .padding()
                    .presentationDragIndicator(.visible)
                    .foregroundColor(.white)
                }
            }
            
            
        }
    }
    
    @ViewBuilder
    func Header() -> some View {
        VStack(spacing: 8){
            Text("Hey! Beschreibe")
                .font(.system(size: 30, weight: .regular))
            Text("deine Schmerzen!")
                .font(.system(size: 30, weight: .regular))
        }
    }
    
    @ViewBuilder
    func PainPicker(screen: CGSize) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 10) {
            ForEach(1...10 , id: \.self) { pain in
                
                ZStack{
                    Text("\(pain)")
                        .padding()
                }
                .frame(width: screen.width / 7.5, height: screen.width / 7.5 )
                .background(vm.selectedPain == pain ? .white.opacity(0.2) : .white.opacity(0.01)) // 0.2 / 0
                .cornerRadius(20)
                .onTapGesture(perform: {
                    if vm.selectedPain == pain {
                        vm.selectedPain = 0
                    } else {
                        vm.selectedPain = pain
                    }
                })
                
            }
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    func Reason() -> some View {
        VStack{
            Button {
                withAnimation {
                    vm.showPainReasonPicker.toggle()
                }
            }  label: {
                HStack(spacing: 10){
                    Image(systemName: "figure.walk")
                    
                    Text((vm.selectedReason == nil ? "Wählen" : vm.selectedReason?.name) ?? "")
                        .font(.caption2)
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray)
                )
            }
            .background(
                Picker("Schmerzursache", selection: $vm.selectedReason) {
                    
                    ForEach(PainReasons, id: \.id) { reason in
                        Text(String(describing: reason.name!)).tag(Optional<PainReason>(reason))
                    }
                    Text("andrer Grund").tag(Optional<PainReason>(nil))
                }
                .pickerStyle(.inline)
                .frame(width: 200, height: 100)
                .clipped()
                .background(Color.black.cornerRadius(10))
                .opacity(vm.showPainReasonPicker ? 1 : 0 )
                .offset(x: 0, y: 90)
            )
            .frame(maxWidth: .infinity)
            .onChange(of: vm.selectedReason) { newValue in
               withAnimation {
                   vm.selectedReason = newValue
                   vm.showPainReasonPicker = false
               }
            }// ReasonPicker
            
            if vm.selectedReason?.name == nil && vm.showPainReasonPicker == false {
                HStack(spacing: 20){
                    Image(systemName: "figure.walk")
                        .font(.title3)
                    
                    TextField( "z.B.: Wetter, Kälte, Wärme...", text: $vm.AddPainReasonText, onEditingChanged: { (isChanged) in
                        if !isChanged {
                            if vm.AddPainReasonText == "" {
                                vm.isPainReasonValid = false
                            } else {
                                vm.isPainReasonValid = true
                            }
                       }
                    })
                    .padding(.horizontal)
                }
                .padding()
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray)
                )
                .padding(.vertical)
            }
        }
    }
    
    @ViewBuilder
    func Drugs() -> some View {
        VStack{
            Button {
                withAnimation {
                    vm.showPainDrugPicker.toggle()
                }
            }  label: {
                HStack(spacing: 10){
                    Image(systemName: "pills")
                    Text((vm.selectedDrug == nil ? "Wählen" : vm.selectedDrug?.name) ?? "")
                        .font(.caption2)
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray)
                )
            }
            .background(
                    Picker("Schmerzmittel", selection: $vm.selectedDrug) {
                        ForEach(PainDrugs, id: \.id) { drug in
                            Text(String(describing: drug.name!)).tag(Optional<PainDrug>(drug))
                        }
                        
                        Text("andere Schmerzmittel").tag(Optional<PainDrug>(nil))
                    }
                    .pickerStyle(.inline)
                    .frame(width: 200, height: 100)
                    .clipped()
                    .background(Color.black.cornerRadius(10))
                    .opacity(vm.showPainDrugPicker ? 1 : 0 )
                    .offset(x: 0, y: 90)
            )
            .frame(maxWidth: .infinity)
            .onChange(of: vm.selectedDrug) { newValue in
               withAnimation {
                   vm.selectedDrug = newValue
                   vm.showPainDrugPicker = false
               }
            }// ReasonPicker
            
            if vm.selectedDrug?.name == nil && vm.showPainDrugPicker == false {
                HStack(spacing: 20){
                    Image(systemName: "pills")
                        .font(.title3)
                    TextField( "z.B.: Ibuprofen, Tillidin, Lyrica...", text: $vm.AddPainDrugText, onEditingChanged: { (isChanged) in
                        if !isChanged {
                             if vm.AddPainDrugText == "" {
                                 vm.isPainDrugValid = false
                             } else {
                                 vm.isPainDrugValid = true
                             }
                       }
                    })
                        .padding(.horizontal)
                }
                .padding()
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray)
                )
                .padding(.vertical)
            }
        }
    }
}
