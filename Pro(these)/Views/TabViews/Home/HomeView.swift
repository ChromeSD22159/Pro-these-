//
//  HomeView.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 27.04.23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var tabManager: TabManager
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var adsViewModel: AdsViewModel
    @EnvironmentObject var entitlementManager: EntitlementManager
    @State var isPresentWebView = false
    @State var link: URL = URL(string: "https://www.prothese.pro/kontakt/")!
    @EnvironmentObject var themeManager: ThemeManager
    
    @FetchRequest var allLiners: FetchedResults<Liner>
    
    @FetchRequest var allProthesis: FetchedResults<Prothese>
    
    var hasProthesesWithMaintance: Bool {
        let prothesen = self.allProthesis.filter({
            $0.hasMaintage
        })
        
        return prothesen.count > 0 ? true : false
    }
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @State var tabSizeAmputeeCounter: CGSize = .zero
    
    @State var tabSizeMoodTrend: CGSize = .zero
    
    @State var tabSizeStepTrend: CGSize = .zero
    
    @State var tabSizePainTrend: CGSize = .zero
    
    @State var tabSizeStepTargetReached: CGSize = .zero
    
    @State var tabSizeWearingCounter: CGSize = .zero
    
    private var filter: [String] {
        var filter = ["All", "Prosthesis", "Amputee", "Moods", "Pains" , "Trends", "Steps"]
        
        filter.sort { (lhs: String, rhs: String) -> Bool in
            return lhs < rhs
        }
        
        return filter
    }
    
    private var filterTranslate: [LocalizedStringKey] = ["All", "Prosthesis", "Amputee", "Moods", "Pains" , "Trends", "Steps"]
    
    @State var currentFilter = "All"
    
    init() {
        _allLiners = FetchRequest<Liner>(
            sortDescriptors: []
        )
        
        _allProthesis = FetchRequest<Prothese>(
            sortDescriptors: []
        )
    }
    
    @AppStorage("showAmputeeCountdown") var showAmputeeCountdown: Bool = true
    @AppStorage("showLiner") var showLiner: Bool = true
    @AppStorage("showProthesen") var showProthesen: Bool = false
    
    @AppStorage("showWearingToday") var showWearingToday: Bool = true
    @AppStorage("showWearingWeek") var showWearingWeek: Bool = true
    @AppStorage("showWearingAvarage") var showWearingAvarage: Bool = true
    @AppStorage("showWearingCounter") var showWearingCounter: Bool = true
    
    @AppStorage("showFeelingDiagram") var showFeelingDiagram: Bool = true
    @AppStorage("showFeelingProthesenDiagram") var showFeelingProthesenDiagram: Bool = true
    @AppStorage("showFeelingTabView") var showFeelingTabView: Bool = true
    
    @AppStorage("showPainDiagram") var showPainDiagram: Bool = true
    @AppStorage("showPainProtheseDiagram") var showPainProtheseDiagram: Bool = true
    @AppStorage("showPainTabView") var showPainTabView: Bool = true
    
    @AppStorage("showWeeklyReports") var showWeeklyReports: Bool = true
    
    @StateObject static var handlerStates = HandlerStates.shared
    
    @State var allNotifications: [UNNotificationRequest] = []
    
    @AppStorage("showReportSheet", store: AppConfig.store) var showReportSheet = false
    
    var body: some View {
        VStack(spacing: 20){
            
            header()

            if !appConfig.hasPro {
                Button(action: {
                    withAnimation(.easeInOut) {
                        tabManager.ishasProFeatureSheet.toggle()
                    }
                }, label: {
                    freeTrailCard(currentTheme: currentTheme)
                })
            }
            
            ScrollView(.horizontal, showsIndicators: false, content: {
                HStack(spacing: 10) {
                    
                    MenuButton()

                    ForEach(filter.indices, id: \.self) { index in
                        Button(action: {
                            withAnimation(.easeInOut) {
                                currentFilter = "all"
                                currentFilter = LocalizedStringKey(filter[index]).stringKey!
                            }
                        }, label: {
                            Text(LocalizedStringKey(filter[index]))
                                .font(.caption)
                                .foregroundColor(currentFilter == filter[index] ? currentTheme.text : currentTheme.textGray)
                                .padding()
                        })
                        .background(.ultraThinMaterial) // currentFilter == filter[index] ? .ultraThinMaterial.opacity(1) : 
                        .cornerRadius(15)
                        .padding(.trailing, index == (filter.count - 1) ? 20 : 0)
                    }
                }
                
                Spacer()
            })
            .frame(height: 45)
            
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 15) {

                   
                    
                    Group {
                        CountDownTabView()
                            .show(currentFilter == "All" && showAmputeeCountdown || currentFilter == "Amputee")
                        
                        LinerInAppWidget()
                            .show(AppTrailManager.hasProOrFreeTrail)
                            .show(currentFilter == "All" && showLiner || currentFilter == "Prosthesis")
                        
                        ProthesenMaintainceInAppWidget()
                            .show(AppTrailManager.hasProOrFreeTrail)
                            .show(hasProthesesWithMaintance)
                            .show(currentFilter == "All" && showProthesen || currentFilter == "Prosthesis")
                    }

                    Group {
                        StepDiagram(weeks: 7, hightlightColor: currentTheme.hightlightColor)
                            .show(currentFilter == "All" || currentFilter == "Steps")
                        
                        StepsToday(background: currentTheme.hightlightColor)
                            .show(currentFilter == "All" || currentFilter == "Steps")
                        
                        StepsAvarage(background: currentTheme.hightlightColor)
                            .show(currentFilter == "All" || currentFilter == "Steps")
                        
                        StepTrendTabView()
                            .show(AppTrailManager.hasProOrFreeTrail)
                            .show(currentFilter == "All" || currentFilter == "Steps" || currentFilter == "Trends")
                    
                        StepReachedTabView()
                            .show(AppTrailManager.hasProOrFreeTrail)
                            .show(currentFilter == "All" || currentFilter == "Steps")
                    }

                    Group {
                        WearingToday(background: currentTheme.hightlightColor)
                            .show(currentFilter == "All" && showWearingToday || currentFilter == "Prosthesis")
                        
                        WearingWeek(background: currentTheme.hightlightColor)
                            .show(currentFilter == "All" && showWearingWeek || currentFilter == "Prosthesis")
                        
                        WearingAvarage(background: currentTheme.hightlightColor)
                            .show(currentFilter == "All" && showWearingAvarage || currentFilter == "Prosthesis")
                    }
                    
                    ProthesenWearingCounterTabView()
                        .show(AppTrailManager.hasProOrFreeTrail)
                        .show(currentFilter == "All" && showWearingCounter || currentFilter == "Prosthesis")
                    
                    Group {
                        
                        
                        FeelingDiagram()
                            .show(AppTrailManager.hasProOrFreeTrail)
                            .show(currentFilter == "All" && showFeelingDiagram || currentFilter == "Moods")
                        
                        FeelingProthesenDiagram()
                            .show(AppTrailManager.hasProOrFreeTrail)
                            .show(currentFilter == "All" && showFeelingProthesenDiagram || currentFilter == "Prosthesis" || currentFilter == "Moods")
                        
                        FeelingTabView()
                            .show(AppTrailManager.hasProOrFreeTrail)
                            .show(currentFilter == "All" && showFeelingTabView || currentFilter == "Moods" || currentFilter == "Trends")
                    }
                    
                    Group {
                        PainDiagram()
                            .show(AppTrailManager.hasProOrFreeTrail)
                            .show(currentFilter == "All" && showPainDiagram || currentFilter == "Pains")
                        
                        PainProtheseDiagram()
                            .show(AppTrailManager.hasProOrFreeTrail)
                            .show(currentFilter == "All" && showPainProtheseDiagram || currentFilter == "Prosthesis" || currentFilter == "Pains")
                        
                        PainTabView()
                            .show(AppTrailManager.hasProOrFreeTrail)
                            .show(currentFilter == "All" && showPainTabView || currentFilter == "Pains" || currentFilter == "Trends")
                        
                    }
                    
                    Group {
                        WeeklyReportsWidget(background: currentTheme.hightlightColor)
                            .show(currentFilter == "All" && showWeeklyReports)
                        
                        VStack {
                            
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 10)
                    }
                    
                    /*
                    Group {
                        ProFeaturesCard().show(appConfig.hasPro ? false : true)
                        DeveloperCard().show(appConfig.hasPro ? false : true)
                    }
                    */
                }
                
            }
            
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                PushNotificationManager().getAllPendingNotifications(debug: false) { note in
                    DispatchQueue.main.async {
                        allNotifications.append(note)
                    }
                }
            })
        }
    }

    func MenuButton() -> some View {
        Menu(content: {
            
            Menu("Prosthesis & Liners", content: {
                Toggle("Prosthesis maintenance", isOn: $showProthesen.animation()).show(AppTrailManager.hasProOrFreeTrail)
                Toggle("Prosthesis liner", isOn: $showLiner.animation()).show(AppTrailManager.hasProOrFreeTrail)
            })
            
           

            Menu("Prosthesis wearing time", content: {
                Toggle("Today's wearing time", isOn: $showWearingToday.animation())
                Toggle("The weekly wear time", isOn: $showWearingWeek.animation())
                Toggle("Average wearing time this week", isOn: $showWearingAvarage.animation())
                Toggle("Worn prostheses", isOn: $showWearingCounter.animation())
            })
            
            Menu("Moods", content: {
                Toggle("Mood Chart", isOn: $showFeelingDiagram.animation()).show(AppTrailManager.hasProOrFreeTrail)
                Toggle("Prostheses Mood Chart", isOn: $showFeelingProthesenDiagram.animation()).show(AppTrailManager.hasProOrFreeTrail)
                Toggle("Weekly Mood Trend", isOn: $showFeelingTabView.animation()).show(AppTrailManager.hasProOrFreeTrail)
            })
            
            Menu("Pains", content: {
                Toggle("Pain Chart", isOn: $showPainDiagram.animation()).show(AppTrailManager.hasProOrFreeTrail)
                Toggle("Prostheses Pain Chart", isOn: $showPainProtheseDiagram.animation()).show(AppTrailManager.hasProOrFreeTrail)
                Toggle("Weekly Pain Trend", isOn: $showPainTabView.animation()).show(AppTrailManager.hasProOrFreeTrail)
            })
            
            Group {
                Toggle("Amputee day counter", isOn: $showAmputeeCountdown.animation())
                Toggle("Weekly reports", isOn: $showWeeklyReports.animation()).show(AppTrailManager.hasProOrFreeTrail)
            }
        }, label: {
            Image(systemName: "gear")
                .font(.caption)
                .padding()
        })
        .foregroundColor(currentTheme.text)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .padding(.leading, 20)
    }
    
    func removeUnusedNotifications() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            let _ = self.allNotifications.map({ note in
                let ident = note.identifier

                let liner = self.allLiners.map({ $0.linerID ?? "NOID" })
                
                let prothesen = self.allProthesis.map({ $0.protheseID ?? "NOID" })
                
                guard !liner.contains(ident) else {
                    return false
                }
                
                guard !prothesen.contains(ident) else {
                    return false
                }
                
                guard !ident.contains("PROTHESE_") else {
                    return false
                }
                
                guard !note.content.body.contains("an appointment")  else {
                    return false
                }

                return false
            })
        })
    }
    
    func debugNotes() -> some View {
        ForEach(allNotifications, id: \.self) { notification in
            VStack {
                HStack{
                    Text("\(notification.content.title)")
                        .font(.body.bold())
                    
                    Spacer()
                }
                
                HStack{
                    Text("\(notification.content.body)")
                    Spacer()
                }
                
                HStack{
                    Text("(\(notification.identifier))")
                        .font(.caption2)
                    
                    Spacer()
                    
                    Button(action: {
                        PushNotificationManager().removeNotification(identifier: notification.identifier)
                    }, label: {
                        Image(systemName: "trash")
                            .padding()
                    })
                }
            }
            .padding()
            .background(.ultraThinMaterial)
        }
    }
    
    @ViewBuilder
    func header() -> some View {
        HStack(){
            VStack(spacing: 2){
                sayHallo(name: appConfig.username)
                    .font(.title2)
                    .foregroundColor(currentTheme.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Your progress and activities at a glance.")
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
                
                
                Image(systemName: "gearshape")
                    .foregroundColor(currentTheme.text)
                    .font(.title3)
                    .onTapGesture {
                        tabManager.isSettingSheet.toggle()
                    }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func StepTrendTabView() -> some View {
        TabView {
            StepTrend(weeks: (10,4), background: currentTheme.hightlightColor)
                .homeScrollCardStyle(currentTheme: currentTheme)
                .saveSize(in: $tabSizeStepTrend)
                .tag(1)
            
            StepTrend(weeks: (5,2), background: currentTheme.hightlightColor)
                .homeScrollCardStyle(currentTheme: currentTheme)
                .saveSize(in: $tabSizeStepTrend)
                .tag(2)
            
            StepTrend(weeks: (3,1), background: currentTheme.hightlightColor)
                .homeScrollCardStyle(currentTheme: currentTheme)
                .saveSize(in: $tabSizeStepTrend)
                .tag(3)
        }
        .frame(height: tabSizeStepTrend.height + 80)
        .tabViewStyle(.page)
        .padding(.vertical, -20)
        .padding(.top, -20)
    }
    
    @ViewBuilder
    func ProthesenWearingCounterTabView() -> some View {
        TabView {
            ProthesenWearingCounter(type: .week)
                .saveSize(in: $tabSizeWearingCounter)
                .tag(1)
            
            ProthesenWearingCounter(type: .twoWeeks)
                .saveSize(in: $tabSizeWearingCounter)
                .tag(2)
            
            ProthesenWearingCounter(type: .month)
                .saveSize(in: $tabSizeWearingCounter)
                .tag(3)
        }
        .frame(height: tabSizeWearingCounter.height + 80)
        .tabViewStyle(.page)
        .padding(.vertical, -20)
        .padding(.top, -20)
    }
 
    @ViewBuilder
    func StepReachedTabView() -> some View {
        TabView {
            StepTargetReached(startDate: Date(), durationDays: 7, background: currentTheme.hightlightColor).show(currentFilter == "All" || currentFilter == "Steps")
                .homeScrollCardStyle(currentTheme: currentTheme)
                .saveSize(in: $tabSizeStepTargetReached)
                .tag(1)
            
            StepTargetReached(startDate: Date(), durationDays: 30, background: currentTheme.hightlightColor).show(currentFilter == "All" || currentFilter == "Steps")
                .homeScrollCardStyle(currentTheme: currentTheme)
                .saveSize(in: $tabSizeStepTargetReached)
                .tag(2)
            
            StepTargetReached(startDate: Date(), durationDays: 60, background: currentTheme.hightlightColor).show(currentFilter == "All" || currentFilter == "Steps")
                .homeScrollCardStyle(currentTheme: currentTheme)
                .saveSize(in: $tabSizeStepTargetReached)
                .tag(3)
        }
        .frame(height: tabSizeStepTargetReached.height + 80)
        .tabViewStyle(.page)
        .padding(.vertical, -20)
        .padding(.top, -20)
    }

    @ViewBuilder
    func CountDownTabView() -> some View {
        TabView {
            AmputeeCountDowndateComponents(background: currentTheme.hightlightColor)
                .homeScrollCardStyle(currentTheme: currentTheme)
                .saveSize(in: $tabSizeAmputeeCounter)
                .tag(1)
            
            AmputeeCountDownDays(background: currentTheme.hightlightColor)
                .homeScrollCardStyle(currentTheme: currentTheme)
                .saveSize(in: $tabSizeAmputeeCounter)
                .tag(2)
        }
        .frame(height: tabSizeAmputeeCounter.height + 80)
        .tabViewStyle(.page)
        .padding(.vertical, -20)
        .padding(.top, -20)
    }
    
    @ViewBuilder
    func FeelingTabView() -> some View {
        TabView {
            FeelingTrend(trendTyp: .week)
                .homeScrollCardStyle(currentTheme: currentTheme)
                .saveSize(in: $tabSizeMoodTrend)
                .tag(1)
            
            FeelingTrend(trendTyp: .month)
                .homeScrollCardStyle(currentTheme: currentTheme)
                .saveSize(in: $tabSizeMoodTrend)
                .tag(2)
        }
        .frame(height: tabSizeMoodTrend.height + 80)
        .tabViewStyle(.page)
        .padding(.vertical, -20)
        .padding(.top, -20)
    }
    
    @ViewBuilder
    func PainTabView() -> some View {
        TabView {
            PainTrend(trendTyp: .week)
                .homeScrollCardStyle(currentTheme: currentTheme)
                .saveSize(in: $tabSizePainTrend)
                .tag(1)
            
            PainTrend(trendTyp: .month)
                .homeScrollCardStyle(currentTheme: currentTheme)
                .saveSize(in: $tabSizePainTrend)
                .tag(2)
        }
        .frame(height: tabSizePainTrend.height + 80)
        .tabViewStyle(.page)
        .padding(.vertical, -20)
        .padding(.top, -20)
    }
    
    @ViewBuilder
    func DeveloperCard() -> some View {
        VStack(alignment: .center, spacing: 20){
            Image("Develper")
                .resizable()
                .scaledToFit()
                .tag("V1")
                .padding(.horizontal)
            
            Text("Supporter subscription")
            //Text("Deine Meinung ist gefragt!")
                .font(.title3.bold())
                .foregroundColor(currentTheme.text)
            
           Text("With the subscription you support the continuous development of the prosthesis app! \n at €9.99 per year!")
                .foregroundColor(currentTheme.text)
                .font(.callout)
                .multilineTextAlignment(.center)
            
            
            if !entitlementManager.hasPro {
                Button("Get your premium subscription!") {
                    tabManager.ishasProFeatureSheet.toggle()
                }
                .padding(6)
                .frame(maxWidth: .infinity)
                .background(currentTheme.hightlightColor)
                .foregroundColor(currentTheme.textBlack)
                .cornerRadius(20)
            } else {
                Button("You have the premium subscription!") {
                    tabManager.ishasProFeatureSheet.toggle()
                }
                .padding(6)
                .frame(maxWidth: .infinity)
                .background(currentTheme.hightlightColor)
                .foregroundColor(currentTheme.textBlack)
                .cornerRadius(20)
                .disabled(true)
            }
            
        }
        .homeScrollCardStyle(currentTheme: currentTheme)
    }
    
    @ViewBuilder
    func ProFeaturesCard() -> some View {
        VStack(alignment: .center, spacing: 20){
            Image("GetProProthesePNG")
                .resizable()
                .scaledToFit()
                .tag("V1")
                .padding(.horizontal)
            
            Text("ProFeature and ProWidgets")
                .font(.title3.bold())
                .foregroundColor(currentTheme.text)
            
           Text("With an upgrade to the premium \n version, the app gets even better!")
                .foregroundColor(currentTheme.text)
                .font(.callout)
                .multilineTextAlignment(.center)
            
            if !entitlementManager.hasPro {
                Button("Get your premium subscription!") {
                    tabManager.ishasProFeatureSheet.toggle()
                }
                .padding(6)
                .frame(maxWidth: .infinity)
                .background(currentTheme.hightlightColor)
                 .foregroundColor(currentTheme.textBlack)
                .cornerRadius(20)
            } else {
                Button("You have the premium subscription!") {
                    tabManager.ishasProFeatureSheet.toggle()
                }
                .padding(6)
                .frame(maxWidth: .infinity)
                .background(currentTheme.hightlightColor)
                 .foregroundColor(currentTheme.textBlack)
                .cornerRadius(20)
                .disabled(true)
            }
            
        }
        .homeScrollCardStyle(currentTheme: currentTheme)
    }
}

struct ScrollItem: Identifiable {
    var id: String { titel }
    let titel: String
    var bg: Color
    
    static let sampleItems = [
        ScrollItem(titel: "asd", bg: .red),
        ScrollItem(titel: "eer", bg: .orange),
    ]
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Theme.blue.gradientBackground(nil).ignoresSafeArea()
            
            VStack{
                HomeView()
                    .environmentObject(AppConfig())
                    .environmentObject(TabManager())
                    .environmentObject(HealthStorage())
                    .environmentObject(PushNotificationManager())
                    .environmentObject(EventManager())
                    .environmentObject(MoodCalendar())
                    .environmentObject(WorkoutStatisticViewModel())
                    .environmentObject(PainViewModel())
                    .environmentObject(StateManager())
                    .environmentObject(EntitlementManager())
                    .defaultAppStorage(UserDefaults(suiteName: "group.FK.Pro-these-")!)
                    .colorScheme(.dark)
            }
        }
    }
}

struct SaveSize: ViewModifier {
    
    @Binding var size: CGSize
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear // we just want the reader to get triggered, so let's use an empty color
                        .onAppear {
                            size = proxy.size
                        }
                }
            )
    }
}

struct HomeScrollCardStyle: ViewModifier {
    
    var currentTheme: Theme
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(currentTheme.text)
            .padding()
            .background(.ultraThinMaterial.opacity(0.4))
            .cornerRadius(20)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
    }
}

struct ShowView: ViewModifier {
    
    var state: Bool
    
    func body(content: Content) -> some View {
        if state {
            content
        }
    }
}

extension View {
    func saveSize(in size: Binding<CGSize>) -> some View {
        modifier(SaveSize(size: size))
    }
    
    func homeScrollCardStyle(currentTheme: Theme) -> some View {
        modifier(HomeScrollCardStyle(currentTheme: currentTheme))
    }

    func show(_ state: Bool) -> some View {
        modifier(ShowView(state: state))
    }
}
