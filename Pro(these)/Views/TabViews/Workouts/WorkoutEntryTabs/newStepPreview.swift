//
//  newStepPreview.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 13.07.23.
//

import SwiftUI
import Charts
import GoogleMobileAds

struct newStepPreview: View {
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var vm: WorkoutStatisticViewModel
    
    @EnvironmentObject var themeManager: ThemeManager
    
    @StateObject var healthStore = HealthStoreProvider()
    
    @State var currentDate: Date = Date()
    
    @State var currentWeek: [DateValue] = []

    @State var StoredCollection: [ChartData] = []
    
    @State var StoredWorkouts: [ChartData] = []
    
    @State var totelStepsThisWeek: Int = 0
    
    @State var totelWearingThisWeek: Int = 0
    
    @State var totelStepDistanceThisWeek: Int = 0

    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    private var currentWeekFormatted: String {
        let first = currentWeek.first?.date.dateFormatte(date: "dd.MM", time: "").date ?? ""
        let last = currentWeek.last?.date.dateFormatte(date: "dd.MM.yy", time: "").date ?? ""
        return first + " - " + last
    }
    
    
    var maxValue: Double {
        let values = self.StoredCollection.map { $0.value }
        return values.max() ?? 0
    }
    
    var daysLeft: Int {
        let values = self.StoredCollection.count
        return 7 - values
    }
    
    @State var avgStepsThisWeek: Int = 0
    
    @State var avgStepsLastWeek: Int = 0
    
    @State private var end = 0.0
    
    @State var week: [DateValue] = []
    
    @State var selectedDate: Date = Date()
    
    @State var sheet = false
    
    @State var calendarSheet = false
    
    @State var CalendarSheetStartDate = Date()
    
    // FIXME: -
    @State var interstitial: GADInterstitialAd?
    
    @State var loadingState: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            let size = geo.size.width

            ZStack {

                ScrollView(showsIndicators: false, content: {
                    VStack(spacing: 20) {
                        
                        // MARK: - Infomation
                        VStack(alignment: .leading, spacing: 12) {
                            
                            HStack(spacing: 0){
                                Spacer()
                                HStack(spacing: 6) {
                                    Image("figure.steps")
                                        .font(size < 400 ? .headline : .title3)
                                        .foregroundColor(currentTheme.hightlightColor)
                                    
                                    Text("**\(totelStepsThisWeek)**")
                                        .font(size < 400 ? .headline : .title3).fontWeight(.bold)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding(.leading)
                                .frame(width:size / 3.5)
                                
                                HStack(spacing: 6) {
                                    Image("distance")
                                        .font(size < 400 ? .headline : .title3)
                                        .foregroundColor(currentTheme.hightlightColor)
                                    
                                    Text("**\( String(format: "%.1f", Double(totelStepDistanceThisWeek) / 1000) )km**")
                                        .font(size < 400 ? .headline : .title3).fontWeight(.bold)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding(.horizontal)
                                .frame(width:size / 3.5)
                                
                                HStack(spacing: 6) {
                                    Image("figure.prothese")
                                        .font(size < 400 ? .headline : .title3)
                                        .foregroundColor(currentTheme.hightlightColor)
                                    
                                    let (h,m,_) = totelWearingThisWeek.secondsToHoursMinutesSeconds
                                    Text("**\(h):\(m)h**")
                                        .font(size < 400 ? .headline : .title3).fontWeight(.bold)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding(.trailing)
                                .frame(width:size / 3.5)
                                
                                Spacer()
                            }
                            .padding(.top)
                            
                            HStack {
                                Spacer()
                                
                                if calcDiffSteps().string == "mehr" {
                                    Text("You walked an average of \(avgStepsThisWeek) steps per day this week. These are \(calcDiffSteps().steps) steps more as last week.")
                                        .font(.subheadline)
                                } else {
                                    Text("You walked an average of \(avgStepsThisWeek) steps per day this week. That's  \(calcDiffSteps().steps) fewer steps than last week.")
                                        .font(.subheadline)
                                }
                                
                                
                                
                                Spacer()
                            }
                            .padding(.bottom)
                            
                        }
                        .background(.ultraThinMaterial.opacity(0.4))
                        .cornerRadius(15)
                        .foregroundColor(currentTheme.text)
                        .transaction { transaction in
                            transaction.animation = nil
                        }
                        .padding(.horizontal)
                        .padding(.top)
  
                        Spacer()
                        
                        VStack(spacing: 20) {
                            // MARK: - Control
                            HStack(spacing: 40) {
                                HStack {
                                    Button(action: {
                                        calendarSheet.toggle()
                                    }, label: {
                                        VStack(spacing: 5) {
                                            HStack(spacing: 5) {
                                                Label("Week: **\(currentWeekFormatted)**", systemImage: "calendar")
                                                    .font(size < 400 ? .footnote : .body)
                                                    .foregroundColor(currentTheme.text)
                                                
                                                Image(systemName: "arrowtriangle.down.fill")
                                                    .foregroundColor(currentTheme.text)
                                                    .labelStyle(.iconOnly)
                                                
                                                Spacer()
                                            }
                                            .padding(.vertical)
                                        }
                                    })
                                }
                                
                                HStack {
                                    Button(action: {
                                        currentDate = Calendar.current.date(byAdding: .day, value: -7, to: currentDate)!
                                        withAnimation(.easeInOut(duration: 2)) {
                                            self.end = 1
                                        }
                                    }, label: {
                                        Image(systemName: "chevron.left")
                                            .foregroundColor(currentTheme.text)
                                            .font(.title3)
                                            .padding([.vertical,.leading])
                                            .padding(.trailing, 5)
                                    })
                                    
                                    Button(action: {
                                        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: currentDate)!
                                        if !Calendar.current.isDateInNextWeek(nextWeek) {
                                            currentDate = Calendar.current.date(byAdding: .day, value: 7, to: currentDate)!
                                            withAnimation(.easeInOut(duration: 2)) {
                                                self.end = 1
                                            }
                                        }
                                       
                                    }, label: {
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(!Calendar.current.isDateInNextWeek(Calendar.current.date(byAdding: .day, value: 7, to: currentDate)!) ? currentTheme.text : currentTheme.textGray)
                                            .font(.title3)
                                            .padding([.vertical,.trailing])
                                            .padding(.leading, 5)
                                    })
                                }
                            }
                            .padding(.horizontal)
                            .transaction { transaction in
                                transaction.animation = nil
                            }
                            // MARK: - Chart
                            
                            VStack {
                                ZStack(alignment: .bottom) {
                                    dashedLine(value: Double(avgStepsThisWeek), color: currentTheme.textGray, text: "AVG")
                                        .opacity(appConfig.showAvgStepsOnChartBackground ? 1 : 0)
                                    
                                    dashedLine(value: Double(appConfig.targetSteps), color: currentTheme.hightlightColor, text: "target")
                                        .opacity(appConfig.showTargetStepsOnChartBackground ? 1 : 0)
                                    
                                    HStack(spacing: 0) {
                                        ForEach($currentWeek.indices, id: \.self) { int in
                                            Pro_these_.dateCapsul(date: currentWeek[int], index: Double(int), weeklySteps: StoredCollection, isShowingSheet: $sheet, avg: avgStepsThisWeek, loadingState: $loadingState)
                                                .frame(width: size / 7)
                                        }
                                    }
                                }
                                .foregroundColor(currentTheme.text)
                                .frame(maxWidth: .infinity, maxHeight: 300)
                                
                                HStack(spacing: 5) {
                                    Spacer()
                                    HStack{
                                        Text("- -")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundStyle(currentTheme.hightlightColor)
                                        
                                        
                                        Text(LocalizedStringKey("\( appConfig.targetSteps ) daily step goal"))
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundStyle(currentTheme.hightlightColor)
                                    }
                                    
                                    Spacer()
                                    Spacer()
                                    
                                    HStack{
                                        Text("- -")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundStyle(currentTheme.textGray)
                                                                                
                                        Text(LocalizedStringKey("⌀ \( Int(avgStepsThisWeek) ) steps a day this week"))
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundStyle(currentTheme.textGray)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical)
                            }
                        }
                        
                        Spacer()
                    }
                })
                
                // FIXME: - LOADING SHEET
                if loadingState {
                    LoadingScreen()
                }
            }
            .frame(width: size)
            .blurredSheet(.init(Material.ultraThinMaterial), show: $calendarSheet, onDismiss: {
                
            }) {
                calendarSheetBody(binding: $calendarSheet, currentDate: $currentDate)
            }
            .onAppear {
                withAnimation( .easeInOut ) {
                    currentWeek = extractWeek()
                    getSteps(week: DateInterval(start: Date().startOfWeek(), end: Date().endOfWeek!))
                }
            }
            .onChange(of: currentDate, perform: { newDate in
                withAnimation( .easeInOut ) {
                    currentWeek = extractWeek()
                    getSteps(week: DateInterval(start: newDate.startOfWeek(), end: newDate.endOfWeek!))
                }
            })
            
        }
    }

    @ViewBuilder
    func LoadingScreen() -> some View {
        ZStack {
            currentTheme.textBlack.opacity(0.8)
            
            VStack {
                ProgressView()
                    .scaleEffect(3, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: currentTheme.hightlightColor))
            }
        }
    }
    
    func calcDiffSteps() -> (steps: Int, string: String) {
        let calc:Double = Double(self.avgStepsThisWeek -  self.avgStepsLastWeek)
        return (steps: abs(Int(calc)), string: calc.sign == .minus ? "weniger" : "mehr")
    }
    
    func extractWeek() -> [DateValue] {
        var days: [DateValue] = []
        for i in 0...6 {
            days.append(
                DateValue(
                    day: Calendar.current.date(byAdding: .day, value: i, to: self.currentDate.startOfWeek())! > Date() ? -1 : 0,
                    date: Calendar.current.date(byAdding: .day, value: i, to: self.currentDate.startOfWeek())!
                )
            )
        }
        
        return days
    }
    
    func getSteps(week: DateInterval ) {
        // Total Steps
        healthStore.queryWeekCountbyType(week: week, type: .stepCount, completion: { stepCount in
            DispatchQueue.main.async {
                self.StoredCollection = stepCount.data
                self.avgStepsThisWeek = stepCount.avg
                self.totelStepsThisWeek = stepCount.data.map { Int($0.value) }.reduce(0, +)
            }
        })
        
        // Total DistanzesSteps
        healthStore.queryWeekCountbyType(week: week, type: .distanceWalkingRunning, completion: { distanceCount in
            DispatchQueue.main.async {
                self.totelStepDistanceThisWeek = distanceCount.data.map { Int($0.value) }.reduce(0, +)
            }
        })
        
        // Total WearingTimes
        healthStore.getWorkouts(week: week, workout: .default()) { workouts in
            DispatchQueue.main.async {
                let totalWorkouts = workouts.data.map({ workout in
                    return Int(workout.value)
                }).reduce(0, +)
                
                self.totelWearingThisWeek = totalWorkouts
            }
        }

        healthStore.getWorkouts(week: week, workout: .default(), completion: { workouts in
            DispatchQueue.main.async {
                self.StoredWorkouts = workouts.data
            }
        })
        
        // lastweek
        let lastweekDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: week.start)!
        healthStore.queryWeekCountbyType(week: DateInterval(start: lastweekDate.startOfWeek(), end: lastweekDate.endOfWeek!), type: .stepCount, completion: { stepCount in
            DispatchQueue.main.async {
                self.avgStepsLastWeek = stepCount.avg
            }
        })
    }
    
    func Map() -> some View {
        
        Chart {
            
            RuleMark(y: .value("Average", avgStepsThisWeek ) )
                .foregroundStyle(currentTheme.hightlightColor)
                .lineStyle(StrokeStyle(lineWidth: 0.5, dash: [8]))
                .annotation(position: .automatic, alignment: .leading, spacing: 10) {
                    Text("⌀ \(avgStepsThisWeek)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(currentTheme.hightlightColor)
                }
            
            ForEach(StoredWorkouts, id: \.id) { day in
                AreaMark(x: .value("date", day.date), y: .value("value", day.value))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        .linearGradient(
                            colors: [
                                currentTheme.accentColor.opacity(0),
                                currentTheme.accentColor.opacity(0.1),
                                currentTheme.accentColor.opacity(0.5)
                            ],
                            startPoint: .bottom,
                            endPoint: .top)
                    )
                
                LineMark(x: .value("date", day.date), y: .value("value", day.value))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        .linearGradient(
                            colors: [
                                currentTheme.hightlightColor.opacity(0.5),
                                currentTheme.text.opacity(1)
                            ],
                            startPoint: .bottom,
                            endPoint: .top)
                    )
                    .lineStyle(.init(lineWidth: 5))
                    
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(range: .plotDimension(padding: 30))
        .chartXScale(range: .plotDimension(padding: 30))
        .frame(maxHeight: 250)
        .animation(Animation.easeInOut(duration: 0.7), value: StoredCollection)
    }
    
    func dashedLine(value: Double, color: Color, text: String) -> some View {
        let m = Int(self.maxValue) < appConfig.targetSteps ? Double(appConfig.targetSteps) : self.maxValue
        let calc = (getPercent(input: value, max: m) - 10)
        return VStack(spacing: 10) {
            Spacer()
            
            Line()
               .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
               .foregroundColor(color)
               .frame(height: 1)
               .frame(maxWidth: .infinity)
            
            VStack {
               // let _ = print("percentHeight: \(calc)")
            }
            .frame(height: calc > 0 ? calc : 0 )
            
            Text("")
                .font(.caption2)
            
            Text("")
                .font(.caption.bold())
        }
        .animation(
            .interpolatingSpring(
                stiffness: 150,
                damping: 25
            ),
            value: value
        )
    }
    
    private func getPercent(input: Double, max: Double) -> CGFloat {
        return 200 / max * input
    }
    
}

struct dateCapsul: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    @EnvironmentObject var ads: AdsViewModel
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @StateObject var healthStore = HealthStoreProvider()
    
    private var date: DateValue
    
    private var index: Double
    
    private var avg: Int
    
    private var weeklySteps: [ChartData]
    
    private var maxValue: Double {
        let values = self.weeklySteps.map { $0.value }
        return values.max() ?? 0
    }
    
    @Binding private var isShowingSheet: Bool
    
    @Binding private var loadingState: Bool
    
    @EnvironmentObject var appConfig: AppConfig
    
    @FetchRequest var fetchRequestFeeling: FetchedResults<Feeling>
    
    @FetchRequest var fetchRequestPain: FetchedResults<Pain>
    
    @State var sheet = false
    
    @State var sheetHeight:CGFloat = 150
    
    @State var hourlySteps:[StepsByHour] = []
    
    init(date: DateValue, index: Double, weeklySteps: [ChartData], isShowingSheet: Binding<Bool>, avg: Int, loadingState: Binding<Bool>) {
        self.date = date
        self.index = index
        self.weeklySteps = weeklySteps
        self.avg = avg
        self._isShowingSheet = isShowingSheet
        self._loadingState = loadingState
        _fetchRequestFeeling = FetchRequest<Feeling>(
            sortDescriptors: [],
            predicate: NSPredicate(
                format: "(date >= %@) AND (date <= %@)", self.date.date.startEndOfDay().start as CVarArg,  self.date.date.startEndOfDay().end as CVarArg
            )
        )
        
        _fetchRequestPain = FetchRequest<Pain>(
            sortDescriptors: [],
            predicate: NSPredicate(
                format: "(date >= %@) AND (date <= %@)", self.date.date.startEndOfDay().start as CVarArg,  self.date.date.startEndOfDay().end as CVarArg
            )
        )
    }
    
    func capsulHeight(day: ChartData) -> CGFloat {
        let percent = getPercent(input: day.value, max: Int(self.maxValue) < appConfig.targetSteps ? Double(appConfig.targetSteps) : self.maxValue)
        return percent < 35 ? 35 : percent
    }
    
    var body: some View {

            if let day = weeklySteps.filter({ Calendar.current.isDate(date.date, inSameDayAs: $0.date) }).first {
                VStack(alignment: .center, spacing: 10) {
                    ZStack(alignment: .bottom) {
                        Capsule()
                            .frame(width: 30, height: 250)
                            .foregroundColor(currentTheme.text.opacity(0.1))
                            .padding(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(sheet ? currentTheme.textGray : .clear, lineWidth: 1)
                            )
                        
                        Capsule()
                            .frame(width: 30, height: capsulHeight(day: day) )
                            .foregroundColor(currentTheme.text)
                            .padding(5)
                            .animation(
                                .interpolatingSpring(
                                    stiffness: 150,
                                    damping: 25
                                )
                                .delay(index/20),
                                value: day.value
                            )
                        
                        VStack(spacing: 6) {
                            if let pain = fetchRequestPain.first {
                                HStack(spacing: 1) {
                                    Image(systemName: "bolt.fill")
                                        .font(.caption2)
                                        .foregroundColor(currentTheme.text)
                                    
                                    Text(String(pain.painIndex))
                                        .font(.footnote.bold())
                                        .foregroundColor(currentTheme.text)
                                }
                                .blendMode(.difference)
                            }
                            
                            if let feeling = fetchRequestFeeling.first {
                                Image("chart_bar_" + feeling.name! )
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(Circle())
                                    .frame(width: 20, height: 20 )
                            }
                        }
                        .padding(.bottom, 12)
                    }
                    
                    Text( String(format: "%.0f", Double(day.value)) )
                        .font(.caption2)
                    
                    Text(String(day.date.dateFormatte(date: "dd.MM", time: "").date ))
                        .font(.caption.bold())
                }
                .onTapGesture {
                    // FIXME: - LOADING SHEET
                    withAnimation(.easeIn) {
                        loadingState = true
                    }
                    
                    healthStore.readHourlyTotalStepCount(date: day.date) { data in
                        DispatchQueue.main.async {
                            self.hourlySteps = data
                            sheet = true
                            isShowingSheet = true
                            withAnimation(.easeOut) {
                                loadingState = false
                            }
                        }
                    }
                }
                .blurredSheet(
                    .init(.ultraThinMaterial),
                    show: $sheet,
                    onDismiss: {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            if !AppConfig.shared.hasPro {
                                   ads.showInterstitial.toggle()
                            }
                        })
                        
                        withAnimation(.easeOut(duration: 0.25)) {
                            isShowingSheet = false
                            sheet = false
                        }
                    }, content: {
                        
                        ZStack(content: {
                            
                            VStack(spacing: 20){
                                HStack{
                                    Text(day.date.dateFormatte(date: "dd.MM.yyyy", time: "").date)
                                        .font(.headline.bold())
                                        .foregroundColor(currentTheme.text)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        withAnimation(.easeOut(duration: 0.25)) {
                                            sheet = false
                                            isShowingSheet = false
                                            
                                            
                                           
                                        }
                                    }, label: {
                                        Image(systemName: "xmark")
                                            .font(.headline.bold())
                                            .foregroundColor(currentTheme.text)
                                    })
                                }
                                .offset(y: -20)
                                
                                dailyStepsSheets(date: day.date, sheetHeight: $sheetHeight, hourlySteps: hourlySteps)
                            }
                            .padding(.horizontal)
                            
                        })
                        .presentationDetents([.height(sheetHeight)])
                        .presentationDragIndicator(.visible)
                        
                    }
                )

            } else {
                VStack(alignment: .center, spacing: 10) {
                    ZStack(alignment: .bottom) {
                        
                        Capsule()
                            .frame(width: 30, height: 250)
                            .foregroundColor(currentTheme.text.opacity(0.1))
                            .padding(5)
                        
                        Capsule()
                            .frame(width: 30, height: 0)
                            .foregroundColor(currentTheme.text)
                            .padding(5)
                    }
                    
                    Text( "0" )
                        .font(.caption2)
                    
                    Text(String(date.date.dateFormatte(date: "dd.MM", time: "").date ))
                        .font(.caption.bold())
                }
            }
        
    }

    private func getPercent(input: Double, max: Double) -> CGFloat {
        return 200 / max * input
    }
}

struct dailyStepsSheets: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var themeManager: ThemeManager
    
    @EnvironmentObject var ads: AdsViewModel
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    var date: Date
    
    @Binding var sheetHeight: CGFloat
    
    @StateObject var healthStore = HealthStoreProvider()
    
    @State var stepCount: Double = 0
    @State var distanceCount: Double = 0
    @State var workoutSeconds: Double = 0
    @State var walkingAsymmetryPercentage: Double = 0
    
    var hourlySteps:[StepsByHour]
    
    @State var snapsheet = false
    
    var body: some View {
        VStack(spacing: 20){
            
            HStack(spacing: 10) {
                Spacer()
                
                Button(action: {
                    snapsheet.toggle()
                }, label: {
                    Image(systemName: "square.and.arrow.up")
                        .padding(10)
                })
            }
            
            HStack{
                // Steps
                VStack(alignment: .leading, spacing: 5) {
                    HStack{
                        Image("figure.steps")
                            .font(.largeTitle)
                        
                        // selected Values
                        VStack(alignment: .leading) {
                            Text(String(format: "%.0f", stepCount))
                                .font(.title2).fontWeight(.bold)
                            
                            Text("Steps")
                                .font(.subheadline)
                        }
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                // Distanz
                VStack(alignment: .leading, spacing: 5) {
                    HStack{
                        Image("distance")
                            .font(.largeTitle)
                        
                        // selected Values
                        VStack(alignment: .leading) {
                            Text(String(format: "%.1f", (distanceCount / 1000) ) + "km")
                                .font(.title2).fontWeight(.bold)
                            
                            Text("Distance")
                                .font(.subheadline)
                        }
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                // Tragezeit
                VStack(alignment: .leading, spacing: 5) {
                    HStack{
                        Image("figure.prothese")
                            .font(.largeTitle)
                        
                        // selected Values
                        VStack(alignment: .leading) {
                            let (h,m,_) = Int(workoutSeconds).secondsToHoursMinutesSeconds
                            Text("\(h):\(m)h")
                                .font(.title2).fontWeight(.bold)
                            
                            Text("Wearing time")
                                .font(.subheadline)
                        }
                        
                        Spacer()
                    }
                }
            }
            .foregroundColor(currentTheme.text)
            
            HStack {
                HourlyStepsChart()
            }
            .foregroundColor(currentTheme.text)
            
            /*
            if !AppConfig.shared.hasPro {
                AdsManager.AdBannerView(adUnitID: AdsManager.GoogleAds.banner.blockID(type: AppConfig.shared.adsDebug ? .test : .product )  , height: 50, width: nil )
                    .frame(height: 50)
            }
             */
        }
        .blurredSheet(.init(.ultraThinMaterial), show: $snapsheet, onDismiss: {
            // Show InterstitialSheet if not Pro
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                if !AppConfig.shared.hasPro {
                       ads.showInterstitial.toggle()
                }
            })
        }, content: {
            SnapShotView(sheet: $snapsheet, steps: stepCount, distance: "\( String(format: "%.1f", distanceCount / 1000 ) )km", date: Date())
        })
        .onAppear {
            healthStore.queryDayCountbyType(date: date, type: .stepCount) { steps in
                DispatchQueue.main.async {
                    self.stepCount = steps
                }
            }
            healthStore.queryDayCountbyType(date: date, type: .distanceWalkingRunning) { steps in
                DispatchQueue.main.async {
                    self.distanceCount = steps
                }
            }
            healthStore.getWorkoutsByDate(date: date, workout: .default(), completion: { seconds in
                DispatchQueue.main.async {
                    self.workoutSeconds = seconds
                }
            })
        }
        .background(GeometryReader { gp -> Color in
           DispatchQueue.main.async {
               self.sheetHeight = gp.size.height + 35 + 35
           }
            return Color.clear
       })
    }
    
    @ViewBuilder
    func HourlyStepsChart() -> some View {
        Chart {
            ForEach(hourlySteps, id: \.start) { day in
                AreaMark(x: .value("date", day.start), y: .value("value", day.count))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        .linearGradient(
                            colors: [
                                currentTheme.accentColor.opacity(0),
                                currentTheme.accentColor.opacity(0.1),
                                currentTheme.accentColor.opacity(0.5)
                            ],
                            startPoint: .bottom,
                            endPoint: .top)
                    )
                
                LineMark(x: .value("date", day.start), y: .value("value", day.count))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        .linearGradient(
                            colors: [
                                currentTheme.text.opacity(0.5),
                                currentTheme.hightlightColor.opacity(0.5)
                            ],
                            startPoint: .bottom,
                            endPoint: .top)
                    )
                    .lineStyle(.init(lineWidth: 3))
            }
            
        }
        .chartYScale(range: .plotDimension(padding: 10))
        .chartXScale(range: .plotDimension(padding: 10))
        .frame(maxHeight: 150)
    }
}

struct calendarSheetBody: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @Binding var binding: Bool
    
    @Binding var currentDate: Date
    
    @State var date = Date()
    
    @State var months: [(date: Date, name: String)] = []
    
    @State var weeks: [(start: Date, end: Date)] = []
    
    @State var disable = true
    
    var body: some View {
        VStack(spacing: 20) {
            // YEAR CHANGER
            HStack {
                Button(action: {
                    date = Calendar.current.date(byAdding: .year, value: -1, to: date)!
                    weeks.removeAll()
                }, label: {
                    Image(systemName: "chevron.left")
                        .font(.title3.bold())
                        .foregroundColor(currentTheme.text)
                        .padding()
                })
                .transaction { transaction in
                    transaction.animation = nil
                }
                
                Text(date.dateFormatte(date: "yyyy", time: "").date)
                    .font(.title3.bold())
                    .foregroundColor(currentTheme.text)
                    .transaction { transaction in
                        transaction.animation = nil
                    }
                
                Button(action: {
                    let nextYear = Calendar.current.date(byAdding: .year, value: +1, to: date)!
                    
                    if !Calendar.current.isDateInNextYear(nextYear) {
                        date = Calendar.current.date(byAdding: .year, value: +1, to: date)!
                        weeks.removeAll()
                    }
                }, label: {
                    Image(systemName: "chevron.right")
                        .font(.title3.bold())
                        .foregroundColor(!Calendar.current.isDateInNextYear(Calendar.current.date(byAdding: .year, value: +1, to: date)!) ? currentTheme.text : currentTheme.textGray )
                        .padding()
                })
                .transaction { transaction in
                    transaction.animation = nil
                }
            }
            .padding(.top)
            .transaction { transaction in
                transaction.animation = nil
            }
            
            
            // MONTHS CHANGER
            if weeks.count == 0 {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4) , spacing: 12) {
                    ForEach(months, id: \.date) { month in
                        
                        Button(action: {
                            date = month.date
                            
                            withAnimation(.spring()) {
                                self.weeks = extractWeeks(date: month.date)
                            }
                        }, label: {
                            HStack {
                                
                                Spacer()
                                
                                Text("\(month.date.dateFormatte(date: "MMM", time: "").date)" ) //\(month.name.prefix(3)).
                                    .font(.caption.bold())
                                    .foregroundColor(currentTheme.text)
                                
                                Spacer()
                            }
                            .padding()
                            .disabled(month.date > Date())
                            .background(isSameMonth(d1: date, d2: month.date) ? currentTheme.primary :  month.date > Date() ? currentTheme.text.opacity(0.05) : currentTheme.text.opacity(0.25)   )
                            .cornerRadius(20)
                            .frame(maxWidth: .infinity)
                        })
                        
                    }
                }
                .padding(.horizontal)
            }
            
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(weeks, id: \.start) { week in
                    
                    Button(action: {
                        if week.start == date {
                            weeks.removeAll()
                        } else {
                            
                            if week.start < Date() {
                                date = week.start
                                currentDate = date
                                binding = false
                            }
                            
                        }
                    }, label: {
                        HStack {
                            
                            Spacer()
                            
                            Text(week.start.dateFormatte(date: "dd.MM.", time: "").date + "-" + week.end.dateFormatte(date: "dd.MM.", time: "").date)
                                .font(.caption.bold())
                                .foregroundColor(currentTheme.text)
                            
                            Spacer()
                        }
                        .padding()
                        .disabled(week.start > Date())
                        .background(isSameWeek(d1: date, d2: week.start) ? currentTheme.primary : week.start > Date() ? currentTheme.text.opacity(0.05) : currentTheme.text.opacity(0.25))
                        .cornerRadius(20)
                        .frame(maxWidth: .infinity)
                    })
                    
                }
            }
            .padding(.horizontal)
            
            HStack {
                Button(action: {
                    weeks.removeAll(keepingCapacity: true)
                }, label: {
                    Text("Reset")
                        .foregroundColor(currentTheme.text)
                        .padding()
                })
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                
                Button(action: {
                    withAnimation(.spring()) {
                        currentDate = Date()
                        binding = false
                    }
                }, label: {
                    Text("Today")
                        .foregroundColor(currentTheme.text)
                        .padding()
                })
                .background(.ultraThinMaterial)
                .cornerRadius(20)
            }
            
            Spacer()
        }
        .onAppear{
            months = extractMonts()
        }
        .onChange(of: date, perform: { newDate in
            months = extractMonts()
        })
        .presentationDetents([.height(450)])
        .presentationDragIndicator(.visible)
    }
    
    func extractMonts() -> [(date: Date, name: String)] {
        var dates: [(date: Date, name: String)] = []
        // this year
        let year = Calendar.current.component(.year, from: self.date)
        // first day of this year
        if let firstOfthisYear = Calendar.current.date(from: DateComponents(year: year, month: 1, day: 1)) {
            for i in 0..<12 {
                let month = Calendar.current.date(byAdding: .month, value: i, to: firstOfthisYear)
                
                dates.append((date: month!, name: month?.dateFormatte(date: "MMMM", time: "").date ?? ""))
            }
        }
        
        return dates
    }
    
    func extractWeeks(date: Date) -> [(start: Date, end: Date)] {
        
        let today = Calendar.current.startOfDay(for: date)

        let firstOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: today))!

        var weeks: [(start: Date, end: Date)] = []

        for i in 0...5 {
            let week = Calendar.current.date(byAdding: .weekOfMonth, value: i, to: firstOfMonth)!
            if Calendar.current.isDate(firstOfMonth, equalTo: week, toGranularity: .month) {
           
                print(Calendar.current.date(byAdding: .minute, value: -1, to: week.endOfWeek!)!)
                weeks.append(
                    (
                        start: week.startOfWeek(),
                        end: Calendar.current.date(byAdding: .minute, value: -1, to: week.endOfWeek!)!
                    )
                )
            }
        }
        
        return weeks
    }
    
    func isSameMonth(d1: Date, d2: Date) -> Bool {
        return Calendar.current.isDate(d1, equalTo: d2, toGranularity: .month) ? true : false
    }
    
    func isSameWeek(d1: Date, d2: Date) -> Bool {
        return Calendar.current.isDate(d1, equalTo: d2, toGranularity: .weekOfMonth) ? true : false
    }
}

struct newStepPreview_Previews: PreviewProvider {
    static var previews: some View {
        newStepPreview()
            .environmentObject(AppConfig())
            .environmentObject(WorkoutStatisticViewModel())
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}
