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
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(.vertical, showsIndicators: false) {
                // Close Button
                SheetHeader(title: "Manage parameters", action: {
                    vm.isDeleteReasonDrugsSheet.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        vm.showDatePicker = false
                    })
                })
                
                // List PainReasons
                VStack(spacing: 15) {
                    HStack(){
                        Text("Pain reasons:")
                        Spacer()
                    }
                    
                    if PainReasons.count == 0 {
                        HStack{
                            Text("No reasons available")
                            Spacer()
                        }
                        .foregroundColor(currentTheme.text)
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
                        Text("Painkiller:")
                        Spacer()
                    }
                    
                    if PainDrugs.count == 0 {
                        HStack{
                            Label("No painkillers available", systemImage: "pills.fill")
                                .font(.body.bold())
                            Spacer()
                        }
                        .foregroundColor(currentTheme.text)
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
                        text: LocalizedStringKey("The parameters “reasons” and “painkillers” can be deleted here. Editing is not possible. The parameters can be recreated when editing or creating the pain record."),
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
            Theme.blue.gradientBackground(nil).ignoresSafeArea()
            
            DeleteReasonDrugsSheetBody()
                .environmentObject(PainViewModel())
                .colorScheme(.dark)
        }
    }
}
