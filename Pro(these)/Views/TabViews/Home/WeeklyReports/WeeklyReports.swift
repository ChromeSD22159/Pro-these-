//
//  WeeklyReports.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 14.08.23.
//

import SwiftUI

struct WeeklyReports: View {

    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @FetchRequest private var allReports: FetchedResults<Report>

    init(background: Color) {
        _allReports = FetchRequest<Report>(
            sortDescriptors: [NSSortDescriptor(key: "created", ascending: false)]
        )
    }
    
    var body: some View {
        ZStack {
            Background()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // MARK: - Page Header
                    Header("All Weekly Reports")
                        .padding(.bottom)
                    
                    VStack(spacing: 6) {
                        ForEach(allReports.indices, id: \.self) { report in
                            ReportItem(allReports[report], index: report)
                                .padding(.horizontal)
                        }
                    }
                    
                } // VStack
                
            } // ScrollView
            
        } // ZStack
        .onAppear {
            
            allReports.map({
                print($0)
            })

        }
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
    
    func ReportItem(_ report: Report, index: Int) -> some View {
        VStack(spacing: 0) {
           
            WeeklyReportDiscloser(report: report, index: index)
            
        }
        .background(.ultraThinMaterial.opacity(0.4))
        .cornerRadius(10)
    }
}

struct WeeklyReportDiscloser: View {
    @EnvironmentObject var themeManager: ThemeManager

    var managedObjectContext = PersistenceController.shared.container.viewContext

    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    private var dateString: String {
        report.created?.dateFormatte(date: "dd.MM.yyyy", time: "").date ?? Date().dateFormatte(date: "dd.MM.yyyy", time: "").date
    }
    
    private var timeString: String {
        report.created?.dateFormatte(date: "", time: "HH:mm").time ?? Date().dateFormatte(date: "", time: "hh:mm").time
    }
    
    private var index: Int
    
    private var report: Report
    
    @FetchRequest private var allReports: FetchedResults<Report>

    // MARK: STATES
    @State var tabSize: CGSize = .zero
    
    @State var stepsTotalThisWeek = 0
    @State var distanceTotalThisWeek = 0
    @State var wearingTimeTotalThisWeek = 0
    
    
    @State var stepsTotalLastWeek = 0
    @State var distanceTotalLastWeek = 0
    @State var wearingTimeTotalLastWeek = 0
    
    @State private var revealDetails = false
    
    init(@ObservedObject report: Report, index: Int) {
        _allReports = FetchRequest<Report>(
            sortDescriptors: [NSSortDescriptor(key: "created", ascending: false)]
        )
        
        self.report = report
        
        self.index = index
    }

    var body: some View {
        
        DisclosureGroup(isExpanded: $revealDetails, content: {
            VStack(spacing: 15) {
                HStack(spacing: 25) {
                    Image("figure.prothese")
                        .font(.title3.bold())
             
                    VStack(alignment: .leading) {
                        Text("\(stepsTotalThisWeek / 7 ) Steps")
                            .font(.footnote.bold())
                            .foregroundColor(currentTheme.text)
                        
                        Text("⌀ Steps")
                            .font(.caption2)
                            .foregroundColor(currentTheme.textGray)
                    }
                    
                    Spacer()

                    let AvgSteps = percent(this: Int32(stepsTotalThisWeek / 7) , last: Int32(stepsTotalLastWeek / 7))
                    
                    Text("\(AvgSteps.sign) \(AvgSteps.percent)%")
                        .font(.caption2.bold())
                        .foregroundColor(AvgSteps.sign == "+" ? .green : .red)
                    
                    
                }
                .padding(15)
                .background(Material.ultraThinMaterial.opacity(0.2))
                .cornerRadius(20)
                
                HStack(spacing: 25) {
                    Image("prothese.below")
                        .font(.title3.bold())
                        .flipHorizontal()
                    
                    VStack(alignment: .leading) {
                        
                        let (h,m,_) = Int(wearingTimeTotalThisWeek).secondsToHoursMinutesSeconds
                        Text("\(h) hrs. \(m) mins.")
                            .font(.footnote.bold())
                            .foregroundColor(currentTheme.text)
                        
                        Text("Total Wearingtime")
                            .font(.caption2)
                            .foregroundColor(currentTheme.textGray)
                    }
                    
                    Spacer()
                    
                    let wearingTimeTotal = percent(this: Int32(wearingTimeTotalThisWeek) , last: Int32(wearingTimeTotalLastWeek))
                    
                    Text("\(wearingTimeTotal.sign) \(abs(wearingTimeTotal.percent))%")
                        .font(.caption2.bold())
                        .foregroundColor(wearingTimeTotal.sign == "+" ? .green : .red)
                }
                .padding(15)
                .background(Material.ultraThinMaterial.opacity(0.4))
                .cornerRadius(20)
                
                HStack(spacing: 25) {
                    Image("prothese.below")
                        .font(.title3.bold())
                        .flipHorizontal()
                    
                    VStack(alignment: .leading) {
                        let (h,m,_) = Int(wearingTimeTotalThisWeek / 7).secondsToHoursMinutesSeconds
                        Text("\(h) hrs. \(m) mins.")
                            .font(.footnote.bold())
                            .foregroundColor(currentTheme.text)
                        
                        Text("⌀ Wearingtime")
                            .font(.footnote)
                            .foregroundColor(currentTheme.textGray)
                    }
                    
                    Spacer()
                    
                    let wearingTimeAvg = percent(this: Int32(wearingTimeTotalThisWeek / 7) , last: Int32(wearingTimeTotalLastWeek / 7))
                    
                    Text("\(wearingTimeAvg.sign) \(wearingTimeAvg.percent)%")
                        .font(.caption2.bold())
                        .foregroundColor(wearingTimeAvg.sign == "+" ? .green : .red)
                }
                .padding(15)
                .background(Material.ultraThinMaterial.opacity(0.2))
                .cornerRadius(20)
                
                HStack(spacing: 25) {
                    Image("distance")
                        .font(.title3.bold())

                    
                    VStack(alignment: .leading) {
                        Text("\(String(format: "%.2f", Double(distanceTotalThisWeek) / 1000 )) km")
                            .font(.footnote.bold())
                        
                        Text("Total Distance")
                            .font(.footnote)
                            .foregroundColor(currentTheme.textGray)
                    }
                    
                    Spacer()
                    
                    let distanceTotal = percent(this: Int32(distanceTotalThisWeek) ,last: Int32(distanceTotalLastWeek) )
                    
                    Text("\(distanceTotal.sign) \(distanceTotal.percent)%")
                        .font(.caption2.bold())
                        .foregroundColor(distanceTotal.sign == "+" ? .green : .red)
                }
                .padding(15)
                .background(Material.ultraThinMaterial.opacity(0.4))
                .cornerRadius(20)
                
                ReportFeeldingProtheseDiagram(startDate: report.startOfWeek ?? Date(), endDate: report.endOfWeek ?? Date())
                
                ReportPainProtheseDiagram(startDate: report.startOfWeek ?? Date(), endDate: report.endOfWeek ?? Date())

                /*
                HStack {
                    Spacer()
                    Button("Delete") {
                        do {
                            managedObjectContext.delete(report)
                            try? managedObjectContext.save()
                        }
                    }
                }
                 */
                
            }
            .padding(.vertical, 10)
        }, label: {
            VStack {
                HStack {
                    Text("Weekly report")
                        .font(.headline.bold())
                        .foregroundColor(currentTheme.text)
                    
                    Spacer()
                    
                    Text("generated: \(dateString) \(timeString)")
                        .font(.caption2.bold())
                        .foregroundColor(currentTheme.text)
                }
                
                if AppConfig.shared.adsDebug {
                    HStack {
                        Text(String(UInt(bitPattern: ObjectIdentifier(report))))
                            .font(.caption2.bold())
                            .foregroundColor(currentTheme.textGray)
                        
                        Spacer()
                    }
                }
               
            }
        })
        .padding()
        .onAppear {
            loadData(start: report.startOfWeek ?? Date(), end: report.endOfWeek ?? Date())

            let last = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: report.startOfWeek ?? Date())!.startEndOfWeek
            
            loadLastWeekData(start: last.start, end: last.end)

            if index == 0 {
                self.revealDetails = false
            } else {
                self.revealDetails = false
            }
        }
    }
    
    func percent(this: Int32, last: Int32) -> (sign: String, percent: Int) {
        
        guard last + this != 0 else {
            return (sign: "=", percent: Int(0))
        }
        
        guard last != 0 else {
            let diff = Double(0) - Double(this)
            
            let percent = 100 / diff * diff
            
            return (sign: "+", percent: Int(percent))
        }
        
        let diff = Double(last) - Double(this)
        
        let percent = 100 / Double(last) * diff
        
        if diff == 0 {
            return (sign: "=" , percent: Int(percent))
        } else {
            return (sign: percent.sign == .minus ? "+" : "-" , percent: abs(Int(percent)))
        }
        
        
    }

    private func loadData(start: Date, end: Date) {
        let week =  DateInterval(start: start, end: end)
        
        HealthStoreProvider().queryWeekCountbyType(week: week, type: .stepCount, completion: { stepCount in
            DispatchQueue.main.async {
                stepsTotalThisWeek = stepCount.data.map { Int($0.value) }.reduce(0, +)
            }
        })
        
        // Total DistanzesSteps
        HealthStoreProvider().queryWeekCountbyType(week: week, type: .distanceWalkingRunning, completion: { distanceCount in
            DispatchQueue.main.async {
                distanceTotalThisWeek = distanceCount.data.map { Int($0.value) }.reduce(0, +)
            }
        })
        
        // Total WearingTimes
        HealthStoreProvider().getWorkouts(week: week, workout: .default()) { workouts in
            DispatchQueue.main.async {
                let totalWorkouts = workouts.data.map({ workout in
                    return Int(workout.value)
                }).reduce(0, +)
                
                wearingTimeTotalThisWeek = totalWorkouts
            }
        }
    }
    
    private func loadLastWeekData(start: Date, end: Date) {
        let week =  DateInterval(start: start, end: end)
        
        HealthStoreProvider().queryWeekCountbyType(week: week, type: .stepCount, completion: { stepCount in
            DispatchQueue.main.async {
                stepsTotalLastWeek = stepCount.data.map { Int($0.value) }.reduce(0, +)
            }
        })
        
        // Total DistanzesSteps
        HealthStoreProvider().queryWeekCountbyType(week: week, type: .distanceWalkingRunning, completion: { distanceCount in
            DispatchQueue.main.async {
                distanceTotalLastWeek = distanceCount.data.map { Int($0.value) }.reduce(0, +)
            }
        })
        
        // Total WearingTimes
        HealthStoreProvider().getWorkouts(week: week, workout: .default()) { workouts in
            DispatchQueue.main.async {
                let totalWorkouts = workouts.data.map({ workout in
                    return Int(workout.value)
                }).reduce(0, +)
                
                wearingTimeTotalLastWeek = totalWorkouts
            }
        }
    }
}
