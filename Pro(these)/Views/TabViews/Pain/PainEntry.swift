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
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var ads: AdsViewModel
    
    let persistenceController = PersistenceController.shared
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .reverse)]) private var Pains: FetchedResults<Pain>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .reverse)]) private var PainReasons: FetchedResults<PainReason>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .reverse)]) private var PainDrugs: FetchedResults<PainDrug>
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
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
                PainStatisticEntrys(min: Pains.map{ Int($0.painIndex) }.min() ?? 0, max: Pains.map{ Int($0.painIndex) }.max() ?? 0, avg: avg)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // MARK: - AddNewPainSheet
        .blurredOverlaySheet(.init(.ultraThinMaterial), show: $vm.isPainAddSheet, onDismiss: {
            // Show InterstitialSheet if not Pro
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                if !appConfig.hasPro {
                       ads.showInterstitial.toggle()
                }
            })
            
            vm.editPain = nil
            vm.resetStates()
        }, content: {
            PainAddSheet()
        })
        
        // MARK: - Delete Reason & Drugs
        .blurredOverlaySheet(.init(.ultraThinMaterial), show: $vm.isDeleteReasonDrugsSheet, onDismiss: {
            // Show InterstitialSheet if not Pro
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                if !appConfig.hasPro {
                       ads.showInterstitial.toggle()
                }
            })
        }, content: {
            DeleteReasonDrugsSheetBody()
        })
        
        // MARK: - Init PainDrugs & Reason
        .onAppear{
            if PainReasons.count == 0 {
                //vm.addDefaultPainReason([LocalizedStringKey("weather").stringKey!, LocalizedStringKey("cold").stringKey!, LocalizedStringKey("warmth").stringKey!])
                vm.addDefaultPainReason([translateReasons("weather"), translateReasons("cold"), translateReasons("warmth")])
            } else if PainDrugs.count == 0 {
                //vm.addDefaultPainDrugs([LocalizedStringKey("No Painkiller").stringKey!]) // "Ibuprofen", "Tillidin", "Novalgin"
                vm.addDefaultPainDrugs([translateReasons("No Painkiller")])
            }
        }
    }
    
    @ViewBuilder
    func Header() -> some View {
        HStack(){
            VStack(spacing: 2){
                sayHallo(name: AppConfig.shared.username)
                    .font(.title2)
                    .foregroundColor(currentTheme.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Keep track of your phantom limb pain.")
                    .font(.caption2)
                    .foregroundColor(currentTheme.textGray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack(spacing: 20){
                
                if !entitlementManager.hasPro {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(currentTheme.text)
                        .onTapGesture {
                            DispatchQueue.main.async {
                                tabManager.ishasProFeatureSheet.toggle()
                            }
                        }
                }
                
                Image(systemName: vm.showList ? "chart.pie" : "list.bullet.below.rectangle")
                    .foregroundColor(currentTheme.text)
                    .font(.title3)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.5)){
                            vm.showList.toggle()
                        }
                    }
                
                Image(systemName: "gearshape")
                    .foregroundColor(currentTheme.text)
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
                Text("statistics")
                    .padding(.leading)
                Spacer()
            }
            
            HStack(spacing: 8) {
                Spacer()
                VStack(alignment: .leading){
                    Text("\(avg)")
                        .font(.title.bold())
                    Text("⌀ Pain value")
                        .font(.caption2)
                        .foregroundColor(currentTheme.textGray)
                    
                    Rectangle()
                        .fill(currentTheme.hightlightColor)
                        .frame(maxWidth: .infinity, maxHeight: 5)
                }
                Spacer()
                VStack(alignment: .leading){
                    Text("\(items)")
                        .font(.title.bold())
                    
                    Text("Number of entries")
                        .font(.caption2)
                        .foregroundColor(currentTheme.textGray)
                    
                    Rectangle()
                        .fill(currentTheme.primary)
                        .frame(maxWidth: .infinity, maxHeight: 5)
                }
                Spacer()
            }
        }
        .foregroundColor(currentTheme.text)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func ListPainEntrys() -> some View {
        HStack(spacing: 20){
            Text("entries:")
                .font(.body.bold())
                .foregroundColor(currentTheme.text)
            Spacer()
            
            Label("Add", systemImage: "plus")
                .foregroundColor(currentTheme.text)
                .font(.body.bold())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.5)){
                        vm.isPainAddSheet.toggle()
                        
                        if PainReasons.count != 0 {
                            vm.selectedReason = PainReasons.first(where: { LocalizedStringKey($0.name!) == LocalizedStringKey("weather") })
                        } else {
                            vm.selectedReason = nil
                        }
                        
                        if PainDrugs.count != 0 {
                            vm.selectedDrug = PainDrugs.first(where: { LocalizedStringKey($0.name!) == LocalizedStringKey("No Painkiller") })
                        } else {
                            vm.selectedDrug = nil
                        }
                    }
                }
            
            Label("Administer", systemImage: "slider.vertical.3")
                .foregroundColor(currentTheme.text)
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
                    Label("No pain recorded!", systemImage: "chart.bar.xaxis")
                    Spacer()
                }
                .foregroundColor(currentTheme.text)
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
                text: LocalizedStringKey("The pain recorder is available in the current version. A more detailed recording is planned, in combination with a medication plan/reminder. In addition, a PDF creation of the documented data is planned, which can be easily shared or emailed to the appropriate contacts. In addition, other widgets and statistics are created."),
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
                        x: .value("Reason", translateReasons(reason)) ,
                        y: .value("Pain", avg)
                    )
                    .foregroundStyle(by: .value("Pain", avg))
                   
                }
                .chartForegroundStyleScale(
                    range: [.blue, .yellow, .orange, .red]
                )
                .frame(height: 200)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pain assessment")
                        .padding(.leading)
                    Text("What was your last pain?")
                        .padding(.leading)
                        .font(.caption2)
                        .foregroundColor(currentTheme.textGray)
                }
                
                HStack(spacing: 8) {
                    Spacer()
                    
                    VStack(alignment: .leading){
                        Text("\(min)")
                            .font(.title.bold())
                        Text("Lowest")
                            .font(.caption2)
                            .foregroundColor(currentTheme.textGray)
                        
                        Rectangle()
                            .fill(.blue)
                            .frame(maxWidth: .infinity, maxHeight: 5)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading){
                        Text("\(avg)")
                            .font(.title.bold())
                        
                        Text("Average")
                            .font(.caption2)
                            .foregroundColor(currentTheme.textGray)
                        
                        Rectangle()
                            .fill(currentTheme.hightlightColor)
                            .frame(maxWidth: .infinity, maxHeight: 5)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading){
                        Text("\(max)")
                            .font(.title.bold())
                        
                        Text("Highest")
                            .font(.caption2)
                            .foregroundColor(currentTheme.textGray)
                        
                        Rectangle()
                            .fill(.red)
                            .frame(maxWidth: .infinity, maxHeight: 5)
                    }
                    Spacer()
                }
            }
            .foregroundColor(currentTheme.text)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
    }
}

struct ReasonRow: View {
    var reason: PainReason
    
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var ads: AdsViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    @State var confirm = false
    @ObservedObject var vm: PainViewModel
    private let persistenceController = PersistenceController.shared
    
    var body: some View {
        HStack(spacing: 8){
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.title.bold())
                    .foregroundColor(currentTheme.hightlightColor)
            }
            
            VStack(alignment: .leading, spacing: 8) {

                Text(LocalizedStringKey(reason.name ?? "")) // translateReasons(reason.name)
                    .font(.body.bold())
                
                let i = vm.dateFormatte(inputDate: reason.date ?? Date(), dateString: "dd.MM.yy", timeString: "HH:mm")
                Text(i.date + " " + i.time)
                    .font(.caption2)
                    .foregroundColor(currentTheme.textGray)
            }
            
            Spacer()
            let arr = [LocalizedStringKey("weather"), LocalizedStringKey("cold"), LocalizedStringKey("warmth")]
            if !arr.contains(LocalizedStringKey(reason.name ?? "Unknown Name"))  {
                Image(systemName: "trash")
                    .onTapGesture{
                        confirm = true
                    }
            }
        }
        .foregroundColor(currentTheme.text)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .frame(maxWidth: .infinity)
        .confirmationDialog("Delete reason?", isPresented: $confirm) {
            let i = vm.dateFormatte(inputDate: reason.date ?? Date(), dateString: "dd.MM.yy", timeString: "HH:mm")
            Button("Delete \(reason.name ?? "")?", role: .destructive) {
                withAnimation {
                    persistenceController.container.viewContext.delete(reason)
                    do {
                        try persistenceController.container.viewContext.save()
                        vm.deletePainReason = nil
                    } catch {
                        print("Reason deleted from \(i.date) \(i.time)! ")
                    }
                    
                    // Show InterstitialSheet if not Pro
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        if !appConfig.hasPro {
                               ads.showInterstitial.toggle()
                        }
                    })
                }
            }
            .font(.callout)
        } // Confirm
    }
}

struct DrugRow: View {
    var drug: PainDrug
    
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var ads: AdsViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    @State var confirm = false
    @ObservedObject var vm: PainViewModel
    private let persistenceController = PersistenceController.shared
    
    var body: some View {
        HStack(spacing: 8){
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "pills.fill")
                    .font(.title.bold())
                    .foregroundColor(currentTheme.hightlightColor)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                if let p = drug.name {
                    Text(LocalizedStringKey(p)) // translateReasons(p)
                        .font(.body.bold())
                }
                
                
                let i = vm.dateFormatte(inputDate: drug.date ?? Date(), dateString: "dd.MM.yy", timeString: "HH:mm")
                Text(i.date + " " + i.time)
                    .font(.caption2)
                    .foregroundColor(currentTheme.textGray)
            }
            
            Spacer()
            
            if drug.name! != "No Painkiller" {
                VStack(alignment: .trailing, spacing: 8) {
                    Image(systemName: "trash")
                        .onTapGesture {
                            confirm = true
                        }
                    
                }
            }
            
        }
        .foregroundColor(currentTheme.text)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .frame(maxWidth: .infinity)
        .confirmationDialog("Delete painkillers?", isPresented: $confirm) {
            let i = vm.dateFormatte(inputDate: drug.date ?? Date(), dateString: "dd.MM.yy", timeString: "HH:mm")
            Button("Delete \(drug.name ?? "")?", role: .destructive) {
                withAnimation {
                    persistenceController.container.viewContext.delete(drug)
                    do {
                        try persistenceController.container.viewContext.save()
                        vm.deletePainDrug = nil
                    } catch {
                        print("Reason deleted from \(i.date) \(i.time)! ")
                    }
                    
                    // Show InterstitialSheet if not Pro
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        if !appConfig.hasPro {
                               ads.showInterstitial.toggle()
                        }
                    })
                }
            }
            .font(.callout)
        } // Confirm
    }
}

struct PainRow: View {
    var pain: Pain
    
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var ads: AdsViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    @State var confirm = false
    @ObservedObject var vm: PainViewModel
    private let persistenceController = PersistenceController.shared
    
    
    var body: some View {
        HStack(spacing: 8){
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "bolt.fill")
                    .font(.title.bold())
                    .foregroundColor(currentTheme.hightlightColor)
            }
            VStack(alignment: .leading, spacing: 8) {
                
                HStack {
                    Text("\(Int(pain.painIndex)) pain index")
                        .font(.body.bold())
                }
                
                let i = vm.dateFormatte(inputDate: pain.date ?? Date(), dateString: "dd.MM.yy", timeString: "HH:mm")
                Text(i.date + " " + i.time)
                    .font(.caption2)
                    .foregroundColor(currentTheme.textGray)
                
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
        .foregroundColor(currentTheme.text)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .confirmationDialog("Delete entry", isPresented: $confirm) {
            let i = vm.dateFormatte(inputDate: pain.date ?? Date(), dateString: "dd.MM.yy", timeString: "HH:mm")
            Button("Delete \(pain.painIndex)?", role: .destructive) {
                withAnimation {
                    persistenceController.container.viewContext.delete(pain)
                    do {
                        try persistenceController.container.viewContext.save()
                        vm.deletePain = nil
                    } catch {
                        print("Reason deleted from \(i.date) \(i.time)! ")
                    }
                }
                
                // Show InterstitialSheet if not Pro
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    if !appConfig.hasPro {
                           ads.showInterstitial.toggle()
                    }
                })
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
            Theme.blue.gradientBackground(nil).ignoresSafeArea()
            
            PainEntry()
                .environmentObject(MoodCalendar())
                .environmentObject(PainViewModel())
                .environmentObject(TabManager())
                .environmentObject(EntitlementManager())
                .colorScheme(.dark)
        }
    }
}
