//
//  PainViewModel.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 26.05.23.
//

import SwiftUI

class PainViewModel: ObservableObject {
    
    let viewContext = PersistenceController.shared.container.viewContext
    
    // Add New Pain States
    @Published var isPainAddSheet:  Bool = false
    @Published var showDatePicker:  Bool = false
    @Published var addPainDate:     Date = Date()
    @Published var selectedPain:    Int = 0
    
    
    // Add New Pain - ReasonStates
    @Published var showPainReasonPicker = false
    @Published var painReason: String = "Wetter"
    @Published var selectedReason: PainReason?
    @Published var AddPainReasonText: String = ""
    @Published var isPainReasonValid = false
    
    // Add New Pain - DrugStates
    @Published var showPainDrugPicker = false
    @Published var painDrug: String = "Kein Schmerzmittel"
    @Published var selectedDrug: PainDrug?
    @Published var AddPainDrugText: String = ""
    @Published var isPainDrugValid = false
    
    
    // Toggel List and Statistic View
    @Published var showList:        Bool = true
    
    
    // Delete
    @Published var isPresentingConfirmDeleteItem: Bool = false
    @Published var isDeleteReasonDrugsSheet: Bool = false
    @Published var deletePain:Pain?
    @Published var deletePainDrug:PainDrug?
    @Published var deletePainReason:PainReason?
    
    // Edit Pain
    @Published var editPain:Pain?
    
    func dateFormatte(inputDate: Date, dateString: String, timeString: String) -> (date:String, time:String) {
        let formattedDate = DateFormatter()
        formattedDate.dateFormat = dateString
        
        let formattedTime = DateFormatter()
        formattedTime.dateFormat = timeString
        return (date: formattedDate.string(from: inputDate), time: formattedTime.string(from: inputDate))
    }
    
    func validation() -> Double {
        // hide buttons when Pain is 0, Reason is Other or nil
        let isNotPainAndReason = self.selectedPain == 0 || self.painReason == "andrer Grund"
        let isNotReason = self.painReason == "andrer Grund"
        
        let isPickerNotClosed = self.showPainDrugPicker == true || self.showPainReasonPicker == true
        
        let isDrugTextEntry = self.painDrug == "Neues Schmerzmittel" && self.isPainDrugValid == false
        let isReasonTextEntry = self.painReason == "Neuer Grund" && self.isPainReasonValid == false
        
        let validation = isNotReason || isNotPainAndReason || isPickerNotClosed || isReasonTextEntry || isDrugTextEntry
        return validation ? 0 : 1
    }
    
    func resetStates(){
        self.isPainAddSheet = false
        self.selectedPain = 0
        self.painReason = ""
        self.AddPainReasonText = ""
        self.painDrug = ""
        self.AddPainDrugText = ""
        self.showPainReasonPicker = false
        self.showPainDrugPicker = false
        self.showDatePicker = false
    }
    
    func addDefaultPainReason(_ input: [String]){
        for reason in input {
            let newReason = PainReason(context: viewContext)
            newReason.name = reason
            newReason.date = Date()
            
            do {
                try? self.viewContext.save()
            }
        }
    }
    
    func addDefaultPainDrugs(_ input: [String]){
        for drug in input {
            let newPainDrug = PainDrug(context: viewContext)
            newPainDrug.name = drug
            newPainDrug.date = Date()
            
            do {
                try? self.viewContext.save()
            }
        }
    }
}
