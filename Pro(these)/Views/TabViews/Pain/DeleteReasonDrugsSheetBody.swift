//
//  DeleteReasonDrugsSheetBody.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 21.06.23.
//

import SwiftUI

struct DeleteReasonDrugsSheetBody: View {
    @EnvironmentObject var vm: PainViewModel
    private let persistenceController = PersistenceController.shared
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .reverse)]) private var PainReasons: FetchedResults<PainReason>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .reverse)]) private var PainDrugs: FetchedResults<PainDrug>
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(.vertical, showsIndicators: false) {
                // Close Button
                SheetHeader("Verwalte Parameter", action: {
                    vm.isDeleteReasonDrugsSheet.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        vm.showDatePicker = false
                    })
                })
                
                // List PainReasons
                VStack(spacing: 15) {
                    HStack(){
                        Text("Schmerzgründe:")
                        Spacer()
                    }
                    
                    if PainReasons.count == 0 {
                        HStack{
                            Text("Keine Gründe Vorhanden")
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .frame(maxWidth: .infinity)
                    }
                    
                    ForEach(PainReasons){ reason in
                        
                        ReasonRow(reason: reason, vm: vm)
                    }
                }
                .padding()
                
                // List PainDrugs
                VStack(spacing: 15) {
                    HStack(){
                        Text("Schmerzmittel:")
                        Spacer()
                    }
                    
                    if PainDrugs.count == 0 {
                        HStack{
                            Label("Keine Schmerzmittel Vorhanden", systemImage: "pills.fill")
                                .font(.body.bold())
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .frame(maxWidth: .infinity)
                    }
                    
                    ForEach(PainDrugs){ drug in
                        
                        DrugRow(drug: drug, vm: vm)
                        
                    }
                    
                    InfomationField( // In-App-ABO
                        backgroundStyle: .ultraThinMaterial,
                        text: "Die Parameter \"Gründe\" und \"Schmerzmittel\"  können hier gelöscht werden. Eine Bearbeitung setht nicht zur Verfügung. Die Parameter können beim bearbeiten oder erstellen des Schmerz-Eintrages neu erstellt werden.",
                        visibility: AppConfig.shared.hasUnlockedPro ? AppConfig.shared.hideInfomations : true
                    )
                }
                .padding()
            }
        }
    }

}

struct DeleteReasonDrugsSheetBody_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppConfig.shared.background.ignoresSafeArea()
            
            DeleteReasonDrugsSheetBody()
                .environmentObject(PainViewModel())
                .colorScheme(.dark)
        }
    }
}
