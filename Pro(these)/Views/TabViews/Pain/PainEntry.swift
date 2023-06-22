//
//  PainEntry.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 26.05.23.
//

import SwiftUI
import CoreData
import Charts

struct PainEntry: View {
    @EnvironmentObject var cal: MoodCalendar
    @EnvironmentObject var vm: PainViewModel
    @EnvironmentObject var tabManager: TabManager
    @EnvironmentObject var entitlementManager: EntitlementManager
    
    let persistenceController = PersistenceController.shared
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .reverse)]) private var Pains: FetchedResults<Pain>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .reverse)]) private var PainReasons: FetchedResults<PainReason>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .reverse)]) private var PainDrugs: FetchedResults<PainDrug>
    
    private var avg: Int {
        if Pains.count != 0 {
            return (Pains.map({ Int($0.painIndex) }).reduce(0, +) / Pains.count)
        } else {
            return 0
        }
    }
    
    private var Reasons: [String] {
        return PainReasons.map({ $0.name ?? "x" })
    }
  
    var body: some View {
        VStack(spacing: 20) {
            
            // Header
            Header()
                .padding(.top, 20)
            
            // Statistic Card
            StatisticCard(avg: avg, items: Pains.count)
                .padding(.vertical, 20)
            
            if vm.showList {
                ListPainEntrys()
            } else {
                PainStatisticEntrys(min: Pains.map{ Int($0.painIndex) }.min()!, max: Pains.map{ Int($0.painIndex) }.max()!, avg: avg)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // MARK: - AddNewPainSheet
        .blurredOverlaySheet(.init(.ultraThinMaterial), show: $vm.isPainAddSheet, onDismiss: {}, content: {
            PainAddSheet()
        })
        
        // MARK: - Delete Reason & Drugs
        .blurredOverlaySheet(.init(.ultraThinMaterial), show: $vm.isDeleteReasonDrugsSheet, onDismiss: {}, content: {
            DeleteReasonDrugsSheetBody()
        })
        
        // MARK: - Init PainDrugs & Reason
        .onAppear{
            if PainReasons.count == 0 {
                vm.addDefaultPainReason(["Wetter", "Kälte", "Wärme"])
            } else if PainDrugs.count == 0 {
                vm.addDefaultPainDrugs(["Kein Schmerzmittel","Ibuprofen", "Tillidin", "Novalgin"])
            }
        }
    }
    
    @ViewBuilder
    func Header() -> some View {
        HStack(){
            VStack(spacing: 2){
                sayHallo(name: AppConfig.shared.username)
                    .font(.title2)
                    .foregroundColor(AppConfig.shared.fontColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Dein Tagesziel ist für heute \(AppConfig.shared.targetSteps) Schritte")
                    .font(.callout)
                    .foregroundColor(AppConfig.shared.fontLight)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack(spacing: 20){
                
                if !entitlementManager.hasPro {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(AppConfig.shared.fontColor)
                        .onTapGesture {
                            DispatchQueue.main.async {
                                tabManager.ishasProFeatureSheet.toggle()
                            }
                        }
                }
                
                Image(systemName: vm.showList ? "chart.pie" : "list.bullet.below.rectangle")
                    .foregroundColor(AppConfig.shared.fontColor)
                    .font(.title3)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.5)){
                            vm.showList.toggle()
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
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func StatisticCard(avg: Int, items: Int) -> some View {
        VStack(alignment: .leading, spacing: 8){
            HStack(spacing: 8) {
                Text("Statistik")
                    .padding(.leading)
                Spacer()
            }
            
            HStack(spacing: 8) {
                Spacer()
                VStack(alignment: .leading){
                    Text("\(avg)")
                        .font(.title.bold())
                    Text("⌀ Schmerz")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    Rectangle()
                        .fill(.yellow)
                        .frame(maxWidth: .infinity, maxHeight: 5)
                }
                Spacer()
                VStack(alignment: .leading){
                    Text("\(items)")
                        .font(.title.bold())
                    
                    Text("Anzahl der Einträge")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    Rectangle()
                        .fill(AppConfig.shared.background)
                        .frame(maxWidth: .infinity, maxHeight: 5)
                }
                Spacer()
            }
        }
        .foregroundColor(.white)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func ListPainEntrys() -> some View {
        HStack(spacing: 20){
            Text("Einträge:")
                .font(.body.bold())
                .foregroundColor(.white)
            Spacer()
            
            Label("Schmerzen Eintragen", systemImage: "plus")
                .foregroundColor(AppConfig.shared.fontColor)
                .font(.body.bold())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.5)){
                        vm.isPainAddSheet.toggle()
                        
                        if PainReasons.count != 0 {
                            vm.selectedReason = PainReasons.first
                        } else {
                            vm.selectedReason = nil
                        }
                        
                        if PainDrugs.count != 0 {
                            vm.selectedDrug = PainDrugs.first
                        } else {
                            vm.selectedDrug = nil
                        }
                    }
                }
            
            Label("Verwalten", systemImage: "slider.vertical.3")
                .foregroundColor(AppConfig.shared.fontColor)
                .font(.body.bold())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.5)){
                        vm.isDeleteReasonDrugsSheet.toggle()
                    }
                }
        }
        .padding(.horizontal)
        
        ScrollView(.vertical, showsIndicators: false, content: {
            
            if Pains.count == 0 {
                HStack{
                    Label("Keine Schmerzen eingetragen!", systemImage: "chart.bar.xaxis")
                    Spacer()
                }
                .foregroundColor(.white)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            }
            
            ForEach(Pains){ pain in
                
                PainRow(pain: pain, vm: vm)

            }
            
            // In-App-ABO
            InfomationField( // In-App-ABO
                backgroundStyle: .ultraThinMaterial,
                text: "In der aktuellen Version steht die Erfassungen von Schmerzen zur Verfügung. Eine ausführlichere Erfassung, in Kombination mit einem Medikamentenplan/Reminder, ist in Planung. Des Weiteren ist eine PDF-Erstellung von den dokumentierten Daten geplant, die leicht geteilt oder per Mail an die jeweiligen Kontakte versendet werden kann. Dazu entstehen mehr Widgets und Statistiken.",
                visibility: AppConfig.shared.hasUnlockedPro ? AppConfig.shared.hideInfomations : true) 
                .padding(.horizontal)
        })
    }
    
    @ViewBuilder
    func PainStatisticEntrys(min: Int, max: Int, avg: Int) -> some View {
        VStack(spacing: 20){
            VStack(alignment: .leading, spacing: 8){

                Chart(Reasons, id: \.self) { reason in
                    let filter = Pains.filter{ $0.painReasons?.name == reason }.map{ Int($0.painIndex) }
                    
                    let avg = filter.count == 0 ? filter.count : filter.reduce(0, +) / filter.count
                    
                    BarMark(
                        x: .value("Reason", reason) ,
                        y: .value("Pain", avg)
                    )
                    .foregroundStyle(by: .value("Pain", avg))
                   
                }
                .chartForegroundStyleScale(
                    range: [.blue, .yellow, .orange, .red]
                )
                .frame(height: 200)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Schmerzbewertung")
                        .padding(.leading)
                    Text("Wie hoch ist der Schmerzwert der letzten Attacken?")
                        .padding(.leading)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                HStack(spacing: 8) {
                    Spacer()
                    
                    VStack(alignment: .leading){
                        Text("\(min)")
                            .font(.title.bold())
                        Text("niedrigste")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        
                        Rectangle()
                            .fill(.blue)
                            .frame(maxWidth: .infinity, maxHeight: 5)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading){
                        Text("\(avg)")
                            .font(.title.bold())
                        
                        Text("Durchschnittlich")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        
                        Rectangle()
                            .fill(.yellow)
                            .frame(maxWidth: .infinity, maxHeight: 5)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading){
                        Text("\(max)")
                            .font(.title.bold())
                        
                        Text("Höchste")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        
                        Rectangle()
                            .fill(.red)
                            .frame(maxWidth: .infinity, maxHeight: 5)
                    }
                    Spacer()
                }
            }
            .foregroundColor(.white)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
    }
    
    func sayHallo(name: String) -> some View {
        let hour = Calendar.current.component(.hour, from: Date())
        
        var string = ""
        
        switch hour {
            case 6..<12 : string = "Guten Morgen, \(name)!"
            case 12 : string = "Guten Tag, \(name)!"
            case 13..<17 :  string = "Hallo \(name)!"
            case 17..<22 : string = "Guten Abend, \(name)!"
            default: string = "Hallo, \(name)!"
        }
        
        return Text(string)
    }
}

struct ReasonRow: View {
    var reason: PainReason
    
    @State var confirm = false
    @ObservedObject var vm: PainViewModel
    private let persistenceController = PersistenceController.shared
    
    var body: some View {
        HStack(spacing: 8){
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.title.bold())
                    .foregroundColor(.yellow)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(reason.name ?? "Unbekannter Name")
                    .font(.body.bold())
                
                let i = vm.dateFormatte(inputDate: reason.date ?? Date(), dateString: "dd.MM.yy", timeString: "HH:mm")
                Text(i.date + " " + i.time + "Uhr")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            let arr = ["Wetter", "Kälte", "Wärme"]
            if !arr.contains(reason.name ?? "Unbekannter Name")  {
                Image(systemName: "trash")
                    .onTapGesture{
                        confirm = true
                    }
            }
        }
        .foregroundColor(.white)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .frame(maxWidth: .infinity)
        .confirmationDialog("Grund löschen?", isPresented: $confirm) {
            let i = vm.dateFormatte(inputDate: reason.date ?? Date(), dateString: "dd.MM.yy", timeString: "HH:mm")
            Button("\(reason.name ?? "") löschen?", role: .destructive) {
                withAnimation {
                    persistenceController.container.viewContext.delete(reason)
                    do {
                        try persistenceController.container.viewContext.save()
                        vm.deletePainReason = nil
                    } catch {
                        print("Grund vom \(i.date) \(i.time) gelöscht! ")
                    }
                }
            }
            .font(.callout)
        } // Confirm
    }
}

struct DrugRow: View {
    var drug: PainDrug
    
    @State var confirm = false
    @ObservedObject var vm: PainViewModel
    private let persistenceController = PersistenceController.shared
    
    var body: some View {
        HStack(spacing: 8){
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "pills.fill")
                    .font(.title.bold())
                    .foregroundColor(.yellow)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(drug.name ?? "Unbekannter Name")
                    .font(.body.bold())
                
                let i = vm.dateFormatte(inputDate: drug.date ?? Date(), dateString: "dd.MM.yy", timeString: "HH:mm")
                Text(i.date + " " + i.time + "Uhr")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if drug.name != "Kein Schmerzmittel" {
                VStack(alignment: .trailing, spacing: 8) {
                    Image(systemName: "trash")
                        .onTapGesture {
                            confirm = true
                        }
                    
                }
            }
            
        }
        .foregroundColor(.white)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .frame(maxWidth: .infinity)
        .confirmationDialog("Schmerzmittel löschen?", isPresented: $confirm) {
            let i = vm.dateFormatte(inputDate: drug.date ?? Date(), dateString: "dd.MM.yy", timeString: "HH:mm")
            Button("\(drug.name ?? "") löschen?", role: .destructive) {
                withAnimation {
                    persistenceController.container.viewContext.delete(drug)
                    do {
                        try persistenceController.container.viewContext.save()
                        vm.deletePainDrug = nil
                    } catch {
                        print("Grund vom \(i.date) \(i.time) gelöscht! ")
                    }
                }
            }
            .font(.callout)
        } // Confirm
    }
}

struct PainRow: View {
    var pain: Pain
    
    @State var confirm = false
    @ObservedObject var vm: PainViewModel
    private let persistenceController = PersistenceController.shared
    
    
    var body: some View {
        HStack(spacing: 8){
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "bolt.fill")
                    .font(.title.bold())
                    .foregroundColor(.yellow)
            }
            VStack(alignment: .leading, spacing: 8) {
                
                HStack {
                    Text("\(Int(pain.painIndex)) Schmerzgrad")
                        .font(.body.bold())
                }
                
                let i = vm.dateFormatte(inputDate: pain.date ?? Date(), dateString: "dd.MM.yy", timeString: "HH:mm")
                Text(i.date + " " + i.time + "Uhr")
                    .font(.caption2)
                    .foregroundColor(.gray)
                
            }
            
            Spacer()
            
            HStack(alignment: .center, spacing: 15) {
                Image(systemName: "pencil")
                    .onTapGesture {
                        vm.isPainAddSheet.toggle()
                        vm.editPain = pain
                    }
                
                Image(systemName: "trash")
                    .onTapGesture {
                        confirm = true
                    }
            }
        }
        .foregroundColor(.white)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .confirmationDialog("Lösche Eintrag", isPresented: $confirm) {
            let i = vm.dateFormatte(inputDate: pain.date ?? Date(), dateString: "dd.MM.yy", timeString: "HH:mm")
            Button("\(pain.painIndex) löschen?", role: .destructive) {
                withAnimation {
                    persistenceController.container.viewContext.delete(pain)
                    do {
                        try persistenceController.container.viewContext.save()
                        vm.deletePain = nil
                    } catch {
                        print("Grund vom \(i.date) \(i.time) gelöscht! ")
                    }
                }
            }
            .font(.callout)
            
        } // Confirm
    }
}

struct PainChartData {
    var id = UUID()
    var avgPain: Int
    var reason: String
}

struct dynamicColor {
    var int: Int
    
    var render: some ShapeStyle {
        switch int {
            case 1: return Color.blue
            case 2: return Color.blue
            case 3: return Color.blue
            case 4: return Color.yellow
            case 5: return Color.yellow
            case 6: return Color.yellow
            case 7: return Color.orange
            case 8: return Color.orange
            case 9: return Color.red
            case 10: return Color.red
            default: return Color.black
        }
    }
}

struct BarView: View {
  var datum: Double
  var colors: [Color]

  var gradient: LinearGradient {
    LinearGradient(gradient: Gradient(colors: colors), startPoint: .top, endPoint: .bottom)
  }

  var body: some View {
    Rectangle()
      .fill(gradient)
      .opacity(datum == 0.0 ? 0.0 : 1.0)
  }
}

struct PainEntry_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppConfig.shared.background.ignoresSafeArea()
            
            PainEntry()
                .environmentObject(MoodCalendar())
                .environmentObject(PainViewModel())
                .environmentObject(TabManager())
                .environmentObject(EntitlementManager())
                .colorScheme(.dark)
        }
    }
}
