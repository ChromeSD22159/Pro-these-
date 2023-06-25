//
//  WorkoutStatisticView.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 19.05.23.
//

import SwiftUI
import Charts
import Foundation
import WidgetKit

struct WorkoutStatisticView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var vm: WorkoutStatisticViewModel
    @EnvironmentObject var entitlementManager: EntitlementManager
    @State var activeActivityChart:WorkoutActivityTab = .steps
    @State var workoutTime:Int = 0
    
    // Widget Entrys
    @AppStorage("Entry steps") var entrySteps: Int = -10
    
    @Binding var isScreenShotSheet: Bool
    
    private var weekRange: ClosedRange<Int> {
        let min = vm.CollectionWeeklySteps.map { $0.weekNr }.min() ?? 0
        let max = vm.CollectionWeeklySteps.map { $0.weekNr }.max() ?? 52
        
        return min...max
    }
    
    private var stepsRange: ClosedRange<Int> {
        return 0...(vm.CollectionWeeklySteps.map { $0.avg }.max() ?? 25000) 
    }
    
    private var weeksAvg: Int {
        let weeks = vm.CollectionWeeklySteps.count
        let sumSteps = vm.CollectionWeeklySteps.map { week in week.avg }.reduce(0, +)
        
        if weeks == 0 {
            return 0
        } else {
            return sumSteps / weeks
        }
    }
    
    var body: some View {
        VStack(spacing: 12){
            // Statistic Card
            StatisticCard()
            
            // TextCard
            TextStatisticCard()
            
            // StepAvgWeekChart
            StepAvgWeekChart()
            
            // Charts
            StatisticsCharts()
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .onAppear{
            /// set currenct Day as today
            let day = vm.currentDay
            /// fetch Steps and Distance by day and save it in selected variable
            vm.getStepsForDate( day )
            vm.getDistanceForDate( day )
            
            /// extraxt weekdays and save it in weekly based arrays
            vm.extractWeeks(numberofWeeks: 8)
            
            vm.getCollectionOfWeeklyHealthData()
            
            entrySteps = Int(vm.CollectionWeeklySteps.last?.data.last?.value ?? 0)
            WidgetCenter.shared.reloadAllTimelines()
            
            let week = Calendar.current.component(.weekOfYear, from: day)
            let collection = vm.CollectionWeeklyWorkouts.filter { $0.weekNr == week }
            
            if collection.count != 0 {
                let found = collection[0].data.filter { Calendar.current.isDate($0.date, inSameDayAs: day) }
                if found.count != 0 {
                    vm.selectedWorkout = found[0].value
                }
            }
        }
        .onChange(of: vm.currentDay, perform: { newDay in
            /// fetch Steps and Distance by day
            vm.getStepsForDate( newDay )
            vm.getDistanceForDate( newDay )
            
            /// get week of the new Date
            let week = Calendar.current.component(.weekOfYear, from: newDay)
            
            /// search Data in array by the new WeekNr
            /// if is data from this week, then set the Step data as selectedSteps or add the first Stepday as selected Steps
            let steps = vm.CollectionWeeklySteps.sorted { $0.weekNr > $1.weekNr }.reversed().filter { $0.weekNr == week }
            vm.selectedAvgSteps = Calendar.current.isDateInThisWeek(newDay) ? Double(steps.last?.avg ?? 1) : Double(steps.first?.avg ?? 1)
            
            /// search Data in array by the new WeekNr
            /// if is data from this week, then set the Distance data as selectedDistance or add the first Distanceday as selected Distance
            let distance = vm.CollectionWeeklyDistanz.sorted { $0.weekNr > $1.weekNr }.reversed().filter { $0.weekNr == week }
            vm.selectedAvgDistance = Calendar.current.isDateInThisWeek(newDay) ? Double(distance.last?.avg ?? 1) : Double(distance.first?.avg ?? 1)
        })
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .background: break
            case .active:
                /// set currenct Day as today
                let day = vm.currentDay
                /// fetch Steps and Distance by day and save it in selected variable
                vm.getStepsForDate( day )
                vm.getDistanceForDate( day )
                
                /// extraxt weekdays and save it in weekly based arrays
                vm.extractWeeks(numberofWeeks: 8)
                
                vm.getCollectionOfWeeklyHealthData()
            default: break
            }
        }
        // MARK: - Delete Reason & Drugs
        .blurredOverlaySheet(.init(.ultraThinMaterial), show: $isScreenShotSheet, onDismiss: {}, content: {
            SnapShotView(sheet: $isScreenShotSheet, steps: seperator(vm.selectedSteps), distance: "\( String(format: "%.1f", vm.selectedDistance / 1000 ) )km", date: vm.currentDay)
        })
    }
    
    @ViewBuilder
    func StatisticCard() -> some View {
        VStack(alignment: .leading, spacing: 10){
            /*Text("Live Statistik")
                .font(.callout)*/
            
            HStack{
                // left
                VStack{
                    HStack{
                        Image(systemName: "figure.run")
                            .font(.largeTitle)
                        
                        // selected Values
                        VStack(alignment: .leading) {
                            
                            let (h,m,s) = secondsToHoursMinutesSeconds(Int(findWorkOutTime()))
                            switch activeActivityChart {
                            case .workouts : Text("\(h):\(m):\(s)h").font(.title2).fontWeight(.bold)
                            case .steps : Text(seperator(vm.selectedSteps)).font(.title2).fontWeight(.bold)
                            case .distance: Text("\( String(format: "%.1f", vm.selectedDistance / 1000 ) )km ").font(.title2).fontWeight(.bold)
                            }
                            
                            Text(formateDate(date:vm.currentDay , dateFormat: "dd.MM.y"))
                        }
                        
                        Spacer()
                    }
                }
                //right
                
                VStack(alignment: .leading, spacing: 8){
                    
                    /// percentual to target steps
                    HStack(){
                        let (targetReached, targetPercent) = vm.checkTargetSteps(steps: vm.selectedSteps)
                        Image(systemName: targetReached ? "hand.thumbsup.circle" : "hand.thumbsdown.circle")
                            .font(.title3)
                            .foregroundColor( targetReached ? .green : .red )
                        Text("\(targetPercent) % des Tagesziel").font(.footnote).foregroundColor(.white)
                        Spacer(minLength: 5)
                    } /// percentual to target steps
                    
                    /// avg steps
                    HStack(){
                        Image(systemName: vm.compareWeekAvg(date: vm.currentDay, arr: vm.CollectionWeeklySteps) ? "arrow.up.right.circle" : "arrow.down.right.circle")
                            .font(.title3)
                            .foregroundColor( vm.compareWeekAvg(date: vm.currentDay, arr: vm.CollectionWeeklySteps) ? .green : .red )
                        Text("⌀ " + seperator(vm.selectedAvgSteps) + " Schritte ").font(.footnote).foregroundColor(.white)
                        Spacer(minLength: 5)
                    } /// avg steps
                    
                    /// avg Distance
                    HStack(){
                        Image(systemName: vm.compareWeekAvg(date: vm.currentDay, arr: vm.CollectionWeeklySteps) ? "arrow.up.right.circle" : "arrow.down.right.circle")
                            .font(.title3)
                            .foregroundColor( vm.compareWeekAvg(date: vm.currentDay, arr: vm.CollectionWeeklySteps) ? .green : .red )
                        Text("⌀ " + String(format: "%.2f", vm.selectedAvgDistance / 1000) + " Kilometer").font(.footnote).foregroundColor(.white)
                        Spacer(minLength: 5)
                    } /// avg Distance
                }
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
    func TextStatisticCard() -> some View {
        
        VStack(alignment: .leading, spacing: 10){
            Text("Vergleich zur Vorwoche")
                .font(.callout)
         
            HStack{
                switch activeActivityChart {
                case .workouts :    Text( vm.calculateAvgDifference(date: vm.currentDay, toCalc: vm.CollectionWeeklySteps, value: Int(vm.selectedAvgWorkout) , type: "h") ).foregroundColor(.gray).font(.caption2)
                case .steps :       Text( vm.calculateAvgDifference(date: vm.currentDay, toCalc: vm.CollectionWeeklySteps, value: Int(vm.selectedAvgSteps) , type: "Schritte") ).foregroundColor(.gray).font(.caption2)
                case .distance:     Text( vm.calculateAvgDifference(date: vm.currentDay, toCalc: vm.CollectionWeeklyDistanz, value: Int(vm.selectedAvgDistance) , type: "km") ).foregroundColor(.gray).font(.caption2)
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
    func StepAvgWeekChart() -> some View {
        VStack(alignment: .leading, spacing: 10){
            Text("Schritte der letzten Wochen")
                .font(.callout)
            
            Chart() {
                
                let weeks = vm.CollectionWeeklySteps.sorted { $0.weekNr > $1.weekNr }.reversed()
                
                RuleMark(y: .value("Durchschnitt", weeksAvg ) )
                    .foregroundStyle(.yellow)
                    .lineStyle(StrokeStyle(lineWidth: 0.5, dash: [8]))
                    .annotation(position: .automatic, alignment: .leading, spacing: 10) {
                        Text("⌀ \(weeksAvg) Schritte")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.yellow)
                    }
                
                ForEach(weeks, id: \.id) { week in
                                            
                    AreaMark(
                        x: .value("Week", week.weekNr),
                        y: .value("Steps", week.avg)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        .linearGradient(
                            colors: [
                                Color(red: 167/255, green: 178/255, blue: 210/255).opacity(0),
                                Color(red: 167/255, green: 178/255, blue: 210/255).opacity(0.1),
                                Color(red: 167/255, green: 178/255, blue: 210/255).opacity(0.5)
                            ],
                            startPoint: .bottom,
                            endPoint: .top)
                    )
                    
                    LineMark(
                        x: .value("Week", week.weekNr),
                        y: .value("Steps", week.avg)
                    )
                    .interpolationMethod(.catmullRom)
                    .symbol {
                        VStack(spacing: 5){
                            ZStack{
                                Image(systemName: "circle.fill")
                                    .scaleEffect(0.5)
                                    .foregroundColor(.white)
                                    .shadow(color: .black, radius: 10)
                            }
                        }
                    }
                    .foregroundStyle(
                        .linearGradient(
                            colors: [
                                .yellow.opacity(0.5),
                                .white.opacity(1)
                            ],
                            startPoint: .bottom,
                            endPoint: .top)
                    )
                    .lineStyle(.init(lineWidth: 2))
                }
            }
            .chartXAxis{
                let min = vm.CollectionWeeklySteps.compactMap { $0.weekNr }.min()
                let max = vm.CollectionWeeklySteps.compactMap { $0.weekNr }.max()
                
                let test = Array(stride(from: min ?? 0, to: max ?? 52, by: 1))
                
                AxisMarks(position: .bottom, values: test) { axis in
                    AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 0.1, dash: [10]))

                    AxisValueLabel() {
                        if let axis = axis.as(Int.self) {
                            Text("KW \(axis)")
                                .font(.caption2)
                        }
                    }
                }
                
            }
            .chartYAxis {
                let max = (vm.CollectionWeeklySteps.map { $0.avg }.max() ?? -8) + 2500
                let _ = (vm.CollectionWeeklySteps.map { $0.avg }.min() ?? -8) - 500

                let test = Array(stride(from: 0, to: max , by: 2500))
                
                AxisMarks(position: .trailing, values: test) { axis in
                    AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 0.1, dash: [10]))

                    AxisValueLabel() {
                        if let axis = axis.as(Int.self) {
                            Text("\(axis)")
                                .font(.system(size: 6))
                        }
                    }
                }
            }
            .chartYScale(domain: stepsRange, range: .plotDimension(padding: 10))
            .chartXScale(domain: weekRange, range: .plotDimension(padding: 10))
        }
        .foregroundColor(.white)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .frame(maxWidth: .infinity, maxHeight: 150)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func StatisticsCharts() -> some View {
        VStack(spacing: 10){
            switch activeActivityChart {
            case .workouts : WorkoutChart()
            case .steps : StepChart()
            case .distance: DistanceChart()
            }

            // Tab
            HStack(spacing: 10) {
                ForEach(WorkoutActivityTab.allCases, id: \.self) { tab in

                    VStack{
                        Text("\(tab.rawValue)")
                            .foregroundColor(activeActivityChart == tab ? .yellow : .white)
                            .font(.callout)
                    }
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity)
                    .background(activeActivityChart == tab ? Material.ultraThinMaterial.opacity(1) : Material.ultraThinMaterial.opacity(0.25))
                    .cornerRadius(15)
                    .onTapGesture {
                        withAnimation(.easeInOut){
                            activeActivityChart = tab
                        }
                    }

                }
            } // tab
            .padding(.horizontal)
        }
    }

    func findWorkOutTime() -> Int {
        let kw = vm.getWeekNumberFromDate(vm.currentDay)
        
        guard let workOutWeek = vm.CollectionWeeklyWorkouts.first(where: { return $0.weekNr == kw } ) else {
            return 0
        }
        
        guard let w = workOutWeek.data.first(where: { return isSameDay(d1: $0.date , d2: vm.currentDay) } )?.value else {
            return 0
        }
        
        return Int(w)
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (String, String, String) {
        let hour = String(format: "%02d", seconds / 3600)
        let minute = String(format: "%02d", (seconds % 3600) / 60)
        let second = String(format: "%02d", (seconds % 3600) % 60)
        return (hour, minute, second)
    }
    
    func isSameDay(d1: Date, d2: Date) -> Bool {
       return Calendar.current.isDate(d1, inSameDayAs: d2)
    }
    
    func formateDate(date: Date, dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: date)
    }
    
    func seperator(_ fv: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0;
        
        return formatter.string(from: NSNumber(value: fv))!
    }
}

struct WorkoutstatisticView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutStatisticView(isScreenShotSheet: .constant(false))
    }
}

enum WorkoutActivityTab:String, Codable, CaseIterable, Identifiable {
    var id: Self { self }
    case workouts = "Workouts"
    case steps = "Steps"
    case distance = "Distanz"
}
extension Int {
    func secondsToHoursMinutesSeconds() -> (String, String, String) {
        let hour = String(format: "%02d", abs(self / 3600))
        let minute = String(format: "%02d", abs( (self % 3600) / 60 ) )
        let second = String(format: "%02d", abs( (self % 3600) % 60 ) )
        return (hour, minute, second)
    }
}
